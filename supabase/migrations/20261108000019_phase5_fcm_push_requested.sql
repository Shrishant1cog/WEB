-- Migration: 20261108000019_phase5_fcm_push_requested
--
-- Phase 5 — Add push_requested parameter to create_notification and update triggers
--
-- The create_notification function needs a push_requested parameter so that
-- notification triggers can request push delivery for specific notification types.
-- The 5-arg wrapper is kept for backward compatibility.

-- ============================================
-- 1. Update 7-argument create_notification to accept push_requested
-- ============================================
DROP FUNCTION IF EXISTS public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_body TEXT,
    p_data JSONB,
    p_category TEXT,
    p_dedupe_key TEXT,
    p_push_requested BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_category TEXT;
    v_in_app BOOLEAN;
    v_push BOOLEAN;
    v_id UUID;
BEGIN
    IF p_user_id IS NULL OR p_title IS NULL OR p_type IS NULL THEN
        RAISE EXCEPTION 'INVALID_NOTIFICATION' USING ERRCODE = '22023';
    END IF;

    v_category := COALESCE(p_category, CASE
        WHEN p_type LIKE 'registration%' OR p_type LIKE '%registration%' THEN 'registration'
        WHEN p_type LIKE 'waitlist%' OR p_type LIKE '%waitlist%' THEN 'waitlist'
        WHEN p_type LIKE 'match_%' OR p_type LIKE '%match%' THEN 'match'
        WHEN p_type LIKE 'credential%' OR p_type LIKE '%credential%' THEN 'credentials'
        WHEN p_type LIKE 'result%' OR p_type LIKE '%result%' THEN 'result'
        WHEN p_type LIKE 'dispute%' OR p_type LIKE '%dispute%' THEN 'dispute'
        WHEN p_type LIKE 'announcement%' OR p_type LIKE '%announcement%' THEN 'announcement'
        WHEN p_type LIKE 'moderator%' OR p_type LIKE '%moderator%' THEN 'moderation'
        ELSE 'system'
    END);

    -- Respect user preferences (in_app always true if user has no pref override)
    SELECT COALESCE(in_app, TRUE), COALESCE(push, TRUE)
    INTO v_in_app, v_push
    FROM public.notification_preferences
    WHERE user_id = p_user_id AND category = v_category;

    -- If no preference row exists, defaults are TRUE for both in_app and push
    IF NOT FOUND THEN
        v_in_app := TRUE;
        v_push := TRUE;
    END IF;

    -- Only request push if the notification type warrants it AND user has push enabled
    -- The trigger passes p_push_requested = true for high-priority notifications
    v_push := v_push AND p_push_requested;

    -- If user has disabled ALL channels for this category, suppress the notification entirely
    IF NOT v_in_app AND NOT v_push THEN
        RETURN NULL;
    END IF;

    INSERT INTO public.notifications (
        user_id, type, title, body, data, category, dedupe_key,
        in_app_visible, push_requested
    ) VALUES (
        p_user_id, p_type, p_title, p_body, COALESCE(p_data, '{}'::jsonb),
        v_category, p_dedupe_key, v_in_app, v_push
    ) ON CONFLICT (dedupe_key) WHERE dedupe_key IS NOT NULL DO NOTHING
    RETURNING id INTO v_id;

    -- Enqueue push delivery if requested and user has push enabled
    IF v_push THEN
        INSERT INTO public.notification_delivery_queue (notification_id, channel, device_token)
        SELECT v_id, 'push', dt.token
        FROM public.device_tokens dt
        WHERE dt.user_id = p_user_id
          AND dt.revoked_at IS NULL
        ON CONFLICT (notification_id, device_token) DO NOTHING;
    END IF;

    RETURN v_id;
END;
$$;

-- ============================================
-- 2. Update 5-argument wrapper (backward compatibility, no push)
-- ============================================
CREATE OR REPLACE FUNCTION public.create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_body TEXT,
    p_data JSONB
)
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT public.create_notification(p_user_id, p_type, p_title, p_body, p_data, NULL, NULL, FALSE);
$$;

REVOKE ALL ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB) TO authenticated;

-- ============================================
-- 3. Update triggers to pass push_requested = true for push-worthy notifications
-- ============================================

-- Match scheduled trigger
DROP TRIGGER IF EXISTS trg_notify_match_scheduled ON public.matches;
DROP FUNCTION IF EXISTS public.notify_match_scheduled();

CREATE OR REPLACE FUNCTION public.notify_match_scheduled()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
    v_when TEXT;
BEGIN
    IF NEW.scheduled_at IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.scheduled_at IS DISTINCT FROM NEW.scheduled_at) THEN
        SELECT title INTO v_title FROM public.tournaments WHERE id = NEW.tournament_id;
        v_when := to_char(NEW.scheduled_at AT TIME ZONE 'UTC', 'YYYY-MM-DD HH24:MI') || ' UTC';

        FOR v_uid IN SELECT public.match_notification_recipients(NEW.id) LOOP
            PERFORM public.create_notification(
                v_uid,
                'match_scheduled',
                'Match scheduled',
                format('%s - %s is scheduled for %s.', v_title, COALESCE(NEW.round_name, 'Match'), v_when),
                jsonb_build_object('match_id', NEW.id, 'tournament_id', NEW.tournament_id),
                'match',
                format('match_scheduled:%s:%s', NEW.id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_match_scheduled
    AFTER INSERT OR UPDATE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.notify_match_scheduled();

-- Credentials released trigger
DROP TRIGGER IF EXISTS trg_notify_credentials_released ON public.match_room_secrets;
DROP FUNCTION IF EXISTS public.notify_credentials_released();

CREATE OR REPLACE FUNCTION public.notify_credentials_released()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
BEGIN
    IF NEW.released_at IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.released_at IS DISTINCT FROM NEW.released_at) THEN
        SELECT title INTO v_title FROM public.tournaments 
        WHERE id = (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id);

        FOR v_uid IN SELECT public.match_notification_recipients(NEW.match_id) LOOP
            PERFORM public.create_notification(
                v_uid,
                'credentials_released',
                'Room credentials available',
                format('Credentials for %s have been released.', v_title),
                jsonb_build_object('match_id', NEW.match_id, 'tournament_id', (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)),
                'credentials',
                format('credentials_released:%s:%s', NEW.match_id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_credentials_released
    AFTER INSERT OR UPDATE ON public.match_room_secrets
    FOR EACH ROW EXECUTE FUNCTION public.notify_credentials_released();

-- Results published trigger
DROP TRIGGER IF EXISTS trg_notify_result_published ON public.results;
DROP FUNCTION IF EXISTS public.notify_result_published();

CREATE OR REPLACE FUNCTION public.notify_result_published()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
BEGIN
    IF NEW.status = 'provisional' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM NEW.status) THEN
        SELECT title INTO v_title FROM public.tournaments 
        WHERE id = (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id);

        FOR v_uid IN SELECT public.match_notification_recipients(NEW.match_id) LOOP
            PERFORM public.create_notification(
                v_uid,
                'result_published',
                'Results published',
                format('Provisional results for %s are now available.', v_title),
                jsonb_build_object('match_id', NEW.match_id, 'result_id', NEW.id, 'tournament_id', (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)),
                'result',
                format('result_published:%s:%s:%s', NEW.match_id, NEW.id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    ELSIF NEW.status = 'finalized' AND OLD.status IS DISTINCT FROM NEW.status THEN
        SELECT title INTO v_title FROM public.tournaments 
        WHERE id = (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id);

        FOR v_uid IN SELECT public.match_notification_recipients(NEW.match_id) LOOP
            PERFORM public.create_notification(
                v_uid,
                'result_finalized',
                'Results finalized',
                format('Final results for %s are now confirmed.', v_title),
                jsonb_build_object('match_id', NEW.match_id, 'result_id', NEW.id, 'tournament_id', (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)),
                'result',
                format('result_finalized:%s:%s:%s', NEW.match_id, NEW.id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_result_published
    AFTER INSERT OR UPDATE ON public.results
    FOR EACH ROW EXECUTE FUNCTION public.notify_result_published();

-- Disputes trigger
DROP TRIGGER IF EXISTS trg_notify_dispute ON public.disputes;
DROP FUNCTION IF EXISTS public.notify_dispute();

CREATE OR REPLACE FUNCTION public.notify_dispute()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT title INTO v_title FROM public.tournaments 
        WHERE id = (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id);

        -- Notify tournament staff
        FOR v_uid IN SELECT public.tournament_staff_recipients((SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)) LOOP
            PERFORM public.create_notification(
                v_uid,
                'dispute_submitted',
                'New dispute submitted',
                format('A dispute was submitted for %s - %s.', v_title, COALESCE((SELECT round_name FROM public.matches WHERE id = NEW.match_id), 'Match')),
                jsonb_build_object('match_id', NEW.match_id, 'dispute_id', NEW.id, 'tournament_id', (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)),
                'dispute',
                format('dispute_submitted:%s:%s', NEW.match_id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    ELSIF TG_OP = 'UPDATE' AND (
        NEW.status IS DISTINCT FROM OLD.status
        OR NEW.moderator_id IS DISTINCT FROM OLD.moderator_id
        OR NEW.resolution IS DISTINCT FROM OLD.resolution
    ) THEN
        SELECT title INTO v_title FROM public.tournaments 
        WHERE id = (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id);

        PERFORM public.create_notification(
            NEW.submitted_by,
            'dispute_updated',
            'Dispute update',
            format('Your dispute for %s - %s is now %s.', v_title, COALESCE((SELECT round_name FROM public.matches WHERE id = NEW.match_id), 'Match'), NEW.status),
            jsonb_build_object('match_id', NEW.match_id, 'dispute_id', NEW.id, 'tournament_id', (SELECT tournament_id FROM public.matches WHERE id = NEW.match_id)),
            'dispute',
            format('dispute_updated:%s:%s:%s', NEW.match_id, NEW.status, NEW.submitted_by),
            TRUE  -- push_requested
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_dispute
    AFTER INSERT OR UPDATE ON public.disputes
    FOR EACH ROW EXECUTE FUNCTION public.notify_dispute();

-- Announcements trigger
DROP TRIGGER IF EXISTS trg_notify_announcement_published ON public.tournament_announcements;
DROP FUNCTION IF EXISTS public.notify_announcement_published();

CREATE OR REPLACE FUNCTION public.notify_announcement_published()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_tournament_title TEXT;
BEGIN
    SELECT title INTO v_tournament_title FROM public.tournaments WHERE id = NEW.tournament_id;

    FOR v_uid IN
        SELECT r.user_id FROM public.tournament_registrations r
        WHERE r.tournament_id = NEW.tournament_id AND r.status = 'confirmed'
        UNION
        SELECT tem.user_id
        FROM public.tournament_registrations r
        JOIN public.tournament_entry_members tem ON tem.entry_id = r.id
        WHERE r.tournament_id = NEW.tournament_id AND r.status = 'confirmed'
    LOOP
        PERFORM public.create_notification(
            v_uid,
            'announcement_published',
            CASE WHEN NEW.pinned THEN 'Pinned announcement' ELSE 'Tournament announcement' END,
            format('%s: %s', v_tournament_title, NEW.title),
            jsonb_build_object(
                'announcement_id', NEW.id,
                'tournament_id', NEW.tournament_id,
                'pinned', NEW.pinned
            ),
            'announcement',
            format('announcement_published:%s:%s:%s', NEW.id, NEW.tournament_id, v_uid),
            TRUE  -- push_requested
        );
    END LOOP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_announcement_published
    AFTER INSERT ON public.tournament_announcements
    FOR EACH ROW EXECUTE FUNCTION public.notify_announcement_published();

-- Registration triggers (waitlist promotion already exists in phase3, update to pass push_requested)
-- The registration triggers are in phase3 migration; we need to update them
DROP TRIGGER IF EXISTS trg_notify_waitlist_promoted ON public.tournament_registrations;
DROP FUNCTION IF EXISTS public.notify_waitlist_promoted();

CREATE OR REPLACE FUNCTION public.notify_waitlist_promoted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_tournament_title TEXT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.status = 'confirmed' AND OLD.status = 'waitlisted' THEN
        SELECT title INTO v_tournament_title FROM public.tournaments WHERE id = NEW.tournament_id;

        PERFORM public.create_notification(
            NEW.user_id,
            'waitlist_promoted',
            'You are in!',
            format('A spot opened up in %s and your registration is now confirmed.', v_tournament_title),
            jsonb_build_object('tournament_id', NEW.tournament_id, 'entry_id', NEW.id),
            'waitlist',
            format('waitlist_promoted:%s:%s', NEW.tournament_id, NEW.id),
            TRUE  -- push_requested
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_waitlist_promoted
    AFTER UPDATE ON public.tournament_registrations
    FOR EACH ROW EXECUTE FUNCTION public.notify_waitlist_promoted();

-- ============================================
-- 4. Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';