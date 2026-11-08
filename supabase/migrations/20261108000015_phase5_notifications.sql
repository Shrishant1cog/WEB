-- Migration: 20261108000015_phase5_notifications
--
-- Phase 5 — Notification persistence, preferences, event generation and
-- push-delivery queueing.
--
-- Design notes:
--   * Notifications are written only by SECURITY DEFINER functions/triggers.
--     Direct INSERT for clients is removed (the Phase 1 policy allowed any
--     caller to forge notifications for any user).
--   * Delivery is decoupled: a notification row is committed first, then a
--     push row is queued. External FCM failures never roll back application
--     state, and failed pushes can be retried without duplicating the in-app
--     notification (dedupe_key unique index).
--   * Scheduled notifications cover future events such as credential release.

-- ============================================
-- 1. Extend notifications
-- ============================================
ALTER TABLE public.notifications
    ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'system',
    ADD COLUMN IF NOT EXISTS dedupe_key TEXT,
    ADD COLUMN IF NOT EXISTS in_app_visible BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS push_requested BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'notifications_category_check'
          AND conrelid = 'public.notifications'::regclass
    ) THEN
        ALTER TABLE public.notifications
            ADD CONSTRAINT notifications_category_check
            CHECK (category IN (
                'registration', 'waitlist', 'match', 'credentials',
                'result', 'dispute', 'announcement', 'moderation',
                'system'
            ));
    END IF;
END;
$$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_notifications_dedupe
    ON public.notifications (dedupe_key)
    WHERE dedupe_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
    ON public.notifications (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_category
    ON public.notifications (user_id, category, created_at DESC);

-- Clients may read and mark their own notifications through RPCs only.
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark own notifications read" ON public.notifications;

REVOKE INSERT, UPDATE, DELETE ON public.notifications FROM anon, authenticated;
GRANT SELECT ON public.notifications TO authenticated;

-- Defense in depth: only read_at may ever change on an existing notification.
CREATE OR REPLACE FUNCTION public.protect_notification_content()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.user_id IS DISTINCT FROM OLD.user_id
       OR NEW.type IS DISTINCT FROM OLD.type
       OR NEW.title IS DISTINCT FROM OLD.title
       OR NEW.body IS DISTINCT FROM OLD.body
       OR NEW.data IS DISTINCT FROM OLD.data
       OR NEW.category IS DISTINCT FROM OLD.category
       OR NEW.dedupe_key IS DISTINCT FROM OLD.dedupe_key
       OR NEW.in_app_visible IS DISTINCT FROM OLD.in_app_visible
       OR NEW.push_requested IS DISTINCT FROM OLD.push_requested
       OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
        RAISE EXCEPTION 'NOTIFICATION_IMMUTABLE' USING ERRCODE = '42501';
    END IF;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_notification_content ON public.notifications;
CREATE TRIGGER trg_protect_notification_content
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.protect_notification_content();

-- ============================================
-- 2. Per-event notification preferences
-- ============================================
CREATE TABLE IF NOT EXISTS public.notification_preferences (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    in_app BOOLEAN NOT NULL DEFAULT TRUE,
    push BOOLEAN NOT NULL DEFAULT TRUE,
    email BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, category),
    CONSTRAINT notification_preferences_category_check CHECK (category IN (
        'registration', 'waitlist', 'match', 'credentials',
        'result', 'dispute', 'announcement', 'moderation', 'system'
    ))
);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users read own notification preferences"
    ON public.notification_preferences FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users insert own notification preferences"
    ON public.notification_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users update own notification preferences"
    ON public.notification_preferences FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE ON public.notification_preferences TO authenticated;

-- Defaults: every category is on for in-app and push, off for email.
CREATE OR REPLACE FUNCTION public.notification_preference_enabled(
    p_user_id UUID,
    p_category TEXT,
    p_channel TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT COALESCE((
        SELECT CASE p_channel
            WHEN 'in_app' THEN np.in_app
            WHEN 'push' THEN np.push
            WHEN 'email' THEN np.email
            ELSE FALSE
        END
        FROM public.notification_preferences np
        WHERE np.user_id = p_user_id AND np.category = p_category
    ), p_channel IN ('in_app', 'push'));
$$;

DROP FUNCTION IF EXISTS public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB);

CREATE OR REPLACE FUNCTION public.create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_body TEXT,
    p_data JSONB,
    p_category TEXT,
    p_dedupe_key TEXT
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
        WHEN p_type LIKE 'announcement%' THEN 'announcement'
        WHEN p_type LIKE 'moderation%' OR p_type LIKE 'abuse%' THEN 'moderation'
        ELSE 'system'
    END);

    v_in_app := public.notification_preference_enabled(p_user_id, v_category, 'in_app');
    v_push := public.notification_preference_enabled(p_user_id, v_category, 'push');

    -- If the user has disabled both channels there is nothing to persist.
    IF NOT v_in_app AND NOT v_push THEN
        RETURN NULL;
    END IF;

    INSERT INTO public.notifications (
        user_id, type, title, body, data, category, dedupe_key,
        in_app_visible, push_requested
    ) VALUES (
        p_user_id, p_type, p_title, p_body, COALESCE(p_data, '{}'::jsonb),
        v_category, p_dedupe_key, v_in_app, v_push
    )
    ON CONFLICT (dedupe_key) WHERE dedupe_key IS NOT NULL DO NOTHING
    RETURNING id INTO v_id;

    IF v_id IS NULL AND p_dedupe_key IS NOT NULL THEN
        SELECT id INTO v_id FROM public.notifications WHERE dedupe_key = p_dedupe_key;
    END IF;

    RETURN v_id;
END;
$$;

-- Backwards-compatible 5-argument entry point for existing Phase 3/4 callers.
-- An exact-arity function is preferred over the defaulted 7-argument version.
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
    SELECT public.create_notification(p_user_id, p_type, p_title, p_body, p_data, NULL, NULL);
$$;

REVOKE ALL ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB) FROM PUBLIC, anon, authenticated;

-- ============================================
-- 3. Client-facing notification RPCs
-- ============================================
CREATE OR REPLACE FUNCTION public.mark_notification_read(p_notification_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_rows INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    UPDATE public.notifications
    SET read_at = COALESCE(read_at, NOW())
    WHERE id = p_notification_id AND user_id = v_uid;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows > 0;
END;
$$;

CREATE OR REPLACE FUNCTION public.mark_all_notifications_read()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_rows INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    UPDATE public.notifications
    SET read_at = NOW()
    WHERE user_id = v_uid AND read_at IS NULL AND in_app_visible = TRUE;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_notification_preference(
    p_category TEXT,
    p_in_app BOOLEAN,
    p_push BOOLEAN,
    p_email BOOLEAN DEFAULT FALSE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    IF p_category NOT IN (
        'registration', 'waitlist', 'match', 'credentials',
        'result', 'dispute', 'announcement', 'moderation', 'system'
    ) THEN
        RAISE EXCEPTION 'INVALID_NOTIFICATION_CATEGORY' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.notification_preferences (user_id, category, in_app, push, email)
    VALUES (v_uid, p_category, COALESCE(p_in_app, TRUE), COALESCE(p_push, TRUE), COALESCE(p_email, FALSE))
    ON CONFLICT (user_id, category) DO UPDATE
    SET in_app = EXCLUDED.in_app,
        push = EXCLUDED.push,
        email = EXCLUDED.email,
        updated_at = NOW();
END;
$$;

REVOKE ALL ON FUNCTION public.mark_notification_read(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_notification_read(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.mark_all_notifications_read() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_all_notifications_read() TO authenticated;

REVOKE ALL ON FUNCTION public.set_notification_preference(TEXT, BOOLEAN, BOOLEAN, BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_notification_preference(TEXT, BOOLEAN, BOOLEAN, BOOLEAN) TO authenticated;

-- ============================================
-- 4. Device tokens
-- ============================================
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL DEFAULT 'android',
    device_name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    CONSTRAINT device_tokens_platform_check CHECK (platform IN ('android', 'ios', 'web'))
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user
    ON public.device_tokens (user_id)
    WHERE revoked_at IS NULL;

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own device tokens" ON public.device_tokens;
CREATE POLICY "Users read own device tokens"
    ON public.device_tokens FOR SELECT
    USING (auth.uid() = user_id);

GRANT SELECT ON public.device_tokens TO authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.device_tokens FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.register_device_token(
    p_token TEXT,
    p_platform TEXT DEFAULT 'android',
    p_device_name TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF p_token IS NULL OR length(trim(p_token)) < 16 THEN
        RAISE EXCEPTION 'INVALID_DEVICE_TOKEN' USING ERRCODE = '22023';
    END IF;
    IF p_platform NOT IN ('android', 'ios', 'web') THEN
        RAISE EXCEPTION 'INVALID_DEVICE_PLATFORM' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.device_tokens (user_id, token, platform, device_name)
    VALUES (v_uid, trim(p_token), p_platform, NULLIF(trim(p_device_name), ''))
    ON CONFLICT (token) DO UPDATE
    SET user_id = EXCLUDED.user_id,
        platform = EXCLUDED.platform,
        device_name = COALESCE(EXCLUDED.device_name, public.device_tokens.device_name),
        updated_at = NOW(),
        last_seen_at = NOW(),
        revoked_at = NULL
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.remove_device_token(p_token TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_rows INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    UPDATE public.device_tokens
    SET revoked_at = NOW(), updated_at = NOW()
    WHERE token = p_token AND user_id = v_uid AND revoked_at IS NULL;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows > 0;
END;
$$;

REVOKE ALL ON FUNCTION public.register_device_token(TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.register_device_token(TEXT, TEXT, TEXT) TO authenticated;

REVOKE ALL ON FUNCTION public.remove_device_token(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_device_token(TEXT) TO authenticated;

-- ============================================
-- 5. Push delivery queue (retryable, deduplicated)
-- ============================================
CREATE TABLE IF NOT EXISTS public.notification_delivery_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    channel TEXT NOT NULL DEFAULT 'push',
    status TEXT NOT NULL DEFAULT 'pending',
    attempts INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    locked_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (notification_id, channel),
    CONSTRAINT notification_delivery_status_check CHECK (
        status IN ('pending', 'processing', 'sent', 'failed', 'dead', 'no_device')
    )
);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_due
    ON public.notification_delivery_queue (next_attempt_at)
    WHERE status IN ('pending', 'failed');

ALTER TABLE public.notification_delivery_queue ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.notification_delivery_queue FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.enqueue_push_delivery()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.push_requested THEN
        INSERT INTO public.notification_delivery_queue (notification_id, channel)
        VALUES (NEW.id, 'push')
        ON CONFLICT (notification_id, channel) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enqueue_push_delivery ON public.notifications;
CREATE TRIGGER trg_enqueue_push_delivery
    AFTER INSERT ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.enqueue_push_delivery();

-- Claim a batch of due push deliveries. Rows without an active device token
-- are closed as 'no_device' instead of blocking the queue.
CREATE OR REPLACE FUNCTION public.claim_notification_delivery(p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
    queue_id UUID,
    notification_id UUID,
    user_id UUID,
    token TEXT,
    title TEXT,
    body TEXT,
    data JSONB,
    attempts INTEGER,
    category TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.notification_delivery_queue q
    SET status = 'no_device', updated_at = NOW()
    WHERE q.status IN ('pending', 'failed')
      AND q.next_attempt_at <= NOW()
      AND NOT EXISTS (
          SELECT 1 FROM public.device_tokens dt
          WHERE dt.user_id = (SELECT n.user_id FROM public.notifications n WHERE n.id = q.notification_id)
            AND dt.revoked_at IS NULL
      );

    RETURN QUERY
    WITH due AS (
        SELECT q.id
        FROM public.notification_delivery_queue q
        JOIN public.notifications n ON n.id = q.notification_id
        WHERE q.status IN ('pending', 'failed')
          AND q.next_attempt_at <= NOW()
          AND EXISTS (
              SELECT 1 FROM public.device_tokens dt
              WHERE dt.user_id = n.user_id AND dt.revoked_at IS NULL
          )
        ORDER BY q.next_attempt_at
        LIMIT GREATEST(COALESCE(p_limit, 50), 1)
        FOR UPDATE SKIP LOCKED
    ), claimed AS (
        UPDATE public.notification_delivery_queue q
        SET status = 'processing',
            locked_at = NOW(),
            attempts = q.attempts + 1,
            updated_at = NOW()
        FROM due
        WHERE q.id = due.id
        RETURNING q.*
    )
    SELECT c.id, c.notification_id, n.user_id, dt.token, n.title, n.body, n.data,
           c.attempts, n.category
    FROM claimed c
    JOIN public.notifications n ON n.id = c.notification_id
    JOIN public.device_tokens dt
      ON dt.user_id = n.user_id AND dt.revoked_at IS NULL
    ORDER BY c.created_at;
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_notification_delivery(
    p_queue_id UUID,
    p_success BOOLEAN,
    p_error TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_attempts INTEGER;
BEGIN
    SELECT attempts INTO v_attempts
    FROM public.notification_delivery_queue
    WHERE id = p_queue_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'DELIVERY_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF p_success THEN
        UPDATE public.notification_delivery_queue
        SET status = 'sent', sent_at = NOW(), last_error = NULL, updated_at = NOW()
        WHERE id = p_queue_id;
    ELSIF v_attempts >= 5 THEN
        UPDATE public.notification_delivery_queue
        SET status = 'dead', last_error = p_error, updated_at = NOW()
        WHERE id = p_queue_id;
    ELSE
        UPDATE public.notification_delivery_queue
        SET status = 'failed',
            last_error = p_error,
            next_attempt_at = NOW() + make_interval(mins => (2 ^ v_attempts)::INTEGER),
            updated_at = NOW()
        WHERE id = p_queue_id;
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_notification_delivery(INTEGER) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.complete_notification_delivery(UUID, BOOLEAN, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_notification_delivery(INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_notification_delivery(UUID, BOOLEAN, TEXT) TO service_role;

-- ============================================
-- 6. Scheduled notifications (e.g. credential release)
-- ============================================
CREATE TABLE IF NOT EXISTS public.scheduled_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    category TEXT NOT NULL DEFAULT 'system',
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    data JSONB NOT NULL DEFAULT '{}'::jsonb,
    dedupe_key TEXT,
    scheduled_at TIMESTAMPTZ NOT NULL,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT scheduled_notifications_category_check CHECK (category IN (
        'registration', 'waitlist', 'match', 'credentials',
        'result', 'dispute', 'announcement', 'moderation', 'system'
    ))
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_scheduled_notifications_dedupe
    ON public.scheduled_notifications (dedupe_key)
    WHERE dedupe_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_scheduled_notifications_due
    ON public.scheduled_notifications (scheduled_at)
    WHERE processed_at IS NULL;

ALTER TABLE public.scheduled_notifications ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.scheduled_notifications FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.process_scheduled_notifications(p_limit INTEGER DEFAULT 100)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_row RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_row IN
        SELECT *
        FROM public.scheduled_notifications
        WHERE processed_at IS NULL AND scheduled_at <= NOW()
        ORDER BY scheduled_at
        LIMIT GREATEST(COALESCE(p_limit, 100), 1)
        FOR UPDATE SKIP LOCKED
    LOOP
        PERFORM public.create_notification(
            v_row.user_id, v_row.type, v_row.title, v_row.body,
            v_row.data, v_row.category, v_row.dedupe_key
        );
        UPDATE public.scheduled_notifications
        SET processed_at = NOW()
        WHERE id = v_row.id;
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.process_scheduled_notifications(INTEGER) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_scheduled_notifications(INTEGER) TO service_role;

-- ============================================
-- 7. Recipient helpers
-- ============================================
CREATE OR REPLACE FUNCTION public.match_notification_recipients(p_match_id UUID)
RETURNS SETOF UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    WITH assigned AS (
        SELECT me.registration_id
        FROM public.match_entries me
        WHERE me.match_id = p_match_id
    ),
    target_regs AS (
        SELECT r.id, r.user_id
        FROM public.tournament_registrations r
        WHERE r.id IN (SELECT registration_id FROM assigned)
          AND r.status = 'confirmed'
        UNION
        SELECT r.id, r.user_id
        FROM public.tournament_registrations r
        JOIN public.matches m ON m.tournament_id = r.tournament_id
        WHERE m.id = p_match_id
          AND r.status = 'confirmed'
          AND NOT EXISTS (SELECT 1 FROM assigned)
    )
    SELECT DISTINCT user_id FROM target_regs
    UNION
    SELECT DISTINCT tem.user_id
    FROM public.tournament_entry_members tem
    WHERE tem.entry_id IN (SELECT id FROM target_regs);
$$;

CREATE OR REPLACE FUNCTION public.registration_notification_recipients(p_registration_id UUID)
RETURNS SETOF UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT r.user_id
    FROM public.tournament_registrations r
    WHERE r.id = p_registration_id
    UNION
    SELECT tem.user_id
    FROM public.tournament_entry_members tem
    WHERE tem.entry_id = p_registration_id;
$$;

CREATE OR REPLACE FUNCTION public.tournament_staff_recipients(p_tournament_id UUID)
RETURNS SETOF UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT t.organizer_id
    FROM public.tournaments t
    WHERE t.id = p_tournament_id
    UNION
    SELECT o.user_id
    FROM public.tournament_organizers o
    WHERE o.tournament_id = p_tournament_id;
$$;

-- ============================================
-- 8. Event generation triggers
-- ============================================

-- 8a. Match scheduled / rescheduled
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
    IF NEW.scheduled_at IS NULL THEN
        RETURN NEW;
    END IF;
    IF TG_OP = 'UPDATE' AND NEW.scheduled_at IS NOT DISTINCT FROM OLD.scheduled_at THEN
        RETURN NEW;
    END IF;

    SELECT t.title INTO v_title FROM public.tournaments t WHERE t.id = NEW.tournament_id;
    v_when := to_char(NEW.scheduled_at AT TIME ZONE 'UTC', 'YYYY-MM-DD HH24:MI "UTC"');

    FOR v_uid IN SELECT public.match_notification_recipients(NEW.id) LOOP
        PERFORM public.create_notification(
            v_uid,
            'match_scheduled',
            'Match scheduled',
            format('%s — %s is scheduled for %s.', v_title, COALESCE(NEW.round_name, 'Match'), v_when),
            jsonb_build_object(
                'match_id', NEW.id,
                'tournament_id', NEW.tournament_id,
                'scheduled_at', NEW.scheduled_at
            ),
            'match',
            format('match_scheduled:%s:%s:%s', NEW.id, v_uid, NEW.scheduled_at)
        );
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_match_scheduled ON public.matches;
CREATE TRIGGER trg_notify_match_scheduled
    AFTER INSERT OR UPDATE OF scheduled_at ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.notify_match_scheduled();

-- 8b. Credential release (scheduled for the configured release instant)
CREATE OR REPLACE FUNCTION public.schedule_credential_release_notifications()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
    v_match public.matches%ROWTYPE;
BEGIN
    SELECT * INTO v_match FROM public.matches WHERE id = NEW.match_id;
    IF NOT FOUND OR v_match.scheduled_at IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT t.title INTO v_title FROM public.tournaments t WHERE t.id = v_match.tournament_id;

    FOR v_uid IN SELECT public.match_notification_recipients(NEW.match_id) LOOP
        INSERT INTO public.scheduled_notifications (
            user_id, category, type, title, body, data, dedupe_key, scheduled_at
        ) VALUES (
            v_uid,
            'credentials',
            'credentials_released',
            'Room credentials released',
            format('Room details for %s — %s are now available.', v_title, COALESCE(v_match.round_name, 'Match')),
            jsonb_build_object(
                'match_id', NEW.match_id,
                'tournament_id', v_match.tournament_id,
                'release_at', NEW.release_at
            ),
            format('credentials_released:%s:%s', NEW.match_id, v_uid),
            NEW.release_at
        )
        ON CONFLICT (dedupe_key) WHERE dedupe_key IS NOT NULL DO NOTHING;
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_schedule_credential_release ON public.match_room_secrets;
CREATE TRIGGER trg_schedule_credential_release
    AFTER INSERT OR UPDATE OF release_at ON public.match_room_secrets
    FOR EACH ROW EXECUTE FUNCTION public.schedule_credential_release_notifications();

-- 8c. Result publication / finalization
CREATE OR REPLACE FUNCTION public.notify_result_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
    v_match public.matches%ROWTYPE;
    v_type TEXT;
    v_heading TEXT;
    v_body TEXT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.status IS NOT DISTINCT FROM OLD.status THEN
        RETURN NEW;
    END IF;
    IF NEW.status NOT IN ('provisional', 'finalized') THEN
        RETURN NEW;
    END IF;
    IF NEW.registration_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT * INTO v_match FROM public.matches WHERE id = NEW.match_id;
    SELECT t.title INTO v_title FROM public.tournaments t WHERE t.id = v_match.tournament_id;

    IF NEW.status = 'provisional' THEN
        v_type := 'result_published';
        v_heading := 'Provisional results published';
        v_body := format('Results for %s — %s are provisional. The dispute window is open.',
                         v_title, COALESCE(v_match.round_name, 'Match'));
    ELSE
        v_type := 'result_finalized';
        v_heading := 'Results finalized';
        v_body := format('Results for %s — %s are now final.',
                         v_title, COALESCE(v_match.round_name, 'Match'));
    END IF;

    FOR v_uid IN SELECT public.registration_notification_recipients(NEW.registration_id) LOOP
        PERFORM public.create_notification(
            v_uid,
            v_type,
            v_heading,
            v_body,
            jsonb_build_object(
                'match_id', NEW.match_id,
                'registration_id', NEW.registration_id,
                'status', NEW.status
            ),
            'result',
            format('%s:%s:%s', v_type, NEW.match_id, NEW.registration_id)
        );
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_result_status ON public.results;
CREATE TRIGGER trg_notify_result_status
    AFTER INSERT OR UPDATE OF status ON public.results
    FOR EACH ROW EXECUTE FUNCTION public.notify_result_status();

-- 8d. Dispute submitted / status changed
CREATE OR REPLACE FUNCTION public.notify_dispute_events()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_title TEXT;
    v_match public.matches%ROWTYPE;
BEGIN
    SELECT * INTO v_match FROM public.matches WHERE id = NEW.match_id;
    SELECT t.title INTO v_title FROM public.tournaments t WHERE t.id = v_match.tournament_id;

    IF TG_OP = 'INSERT' THEN
        FOR v_uid IN SELECT public.tournament_staff_recipients(v_match.tournament_id) LOOP
            PERFORM public.create_notification(
                v_uid,
                'dispute_submitted',
                'New dispute submitted',
                format('A dispute was submitted for %s — %s.', v_title, COALESCE(v_match.round_name, 'Match')),
                jsonb_build_object(
                    'dispute_id', NEW.id,
                    'match_id', NEW.match_id,
                    'registration_id', NEW.registration_id
                ),
                'dispute',
                format('dispute_submitted:%s:%s', NEW.id, v_uid)
            );
        END LOOP;
        RETURN NEW;
    END IF;

    IF NEW.status IS DISTINCT FROM OLD.status
       OR NEW.moderator_id IS DISTINCT FROM OLD.moderator_id
       OR NEW.resolution IS DISTINCT FROM OLD.resolution THEN
        PERFORM public.create_notification(
            NEW.submitted_by,
            'dispute_updated',
            'Dispute update',
            format('Your dispute for %s — %s is now %s.', v_title, COALESCE(v_match.round_name, 'Match'), NEW.status),
            jsonb_build_object(
                'dispute_id', NEW.id,
                'match_id', NEW.match_id,
                'status', NEW.status,
                'moderator_id', NEW.moderator_id
            ),
            'dispute',
            format('dispute_updated:%s:%s', NEW.id, NEW.status)
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_dispute_insert ON public.disputes;
CREATE TRIGGER trg_notify_dispute_insert
    AFTER INSERT ON public.disputes
    FOR EACH ROW EXECUTE FUNCTION public.notify_dispute_events();

DROP TRIGGER IF EXISTS trg_notify_dispute_update ON public.disputes;
CREATE TRIGGER trg_notify_dispute_update
    AFTER UPDATE OF status, moderator_id, resolution ON public.disputes
    FOR EACH ROW EXECUTE FUNCTION public.notify_dispute_events();

-- ============================================
-- 9. Tournament announcements
-- ============================================
CREATE TABLE IF NOT EXISTS public.tournament_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    pinned BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT tournament_announcements_title_check CHECK (char_length(title) BETWEEN 1 AND 120),
    CONSTRAINT tournament_announcements_body_check CHECK (char_length(body) BETWEEN 1 AND 4000)
);

CREATE INDEX IF NOT EXISTS idx_tournament_announcements_tournament
    ON public.tournament_announcements (tournament_id, pinned DESC, published_at DESC);

ALTER TABLE public.tournament_announcements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tournament participants read announcements" ON public.tournament_announcements;
CREATE POLICY "Tournament participants read announcements"
    ON public.tournament_announcements FOR SELECT
    USING (
        public.is_tournament_organizer(tournament_id, auth.uid())
        OR EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.tournament_id = tournament_announcements.tournament_id
              AND r.user_id = auth.uid()
              AND r.status IN ('confirmed', 'waitlisted')
        )
        OR EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            JOIN public.tournament_entry_members tem ON tem.entry_id = r.id
            WHERE r.tournament_id = tournament_announcements.tournament_id
              AND tem.user_id = auth.uid()
              AND r.status IN ('confirmed', 'waitlisted')
        )
        OR EXISTS (
            SELECT 1 FROM public.tournaments t
            WHERE t.id = tournament_announcements.tournament_id
              AND t.status IN ('published', 'registration_open', 'registration_closed', 'in_progress', 'completed')
              AND t.visibility = 'public'
        )
    );

REVOKE INSERT, UPDATE, DELETE ON public.tournament_announcements FROM anon, authenticated;
GRANT SELECT ON public.tournament_announcements TO authenticated;

CREATE OR REPLACE FUNCTION public.create_tournament_announcement(
    p_tournament_id UUID,
    p_title TEXT,
    p_body TEXT,
    p_pinned BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;
    IF p_title IS NULL OR char_length(trim(p_title)) < 1 OR char_length(trim(p_title)) > 120 THEN
        RAISE EXCEPTION 'INVALID_ANNOUNCEMENT' USING ERRCODE = '22023';
    END IF;
    IF p_body IS NULL OR char_length(trim(p_body)) < 1 OR char_length(trim(p_body)) > 4000 THEN
        RAISE EXCEPTION 'INVALID_ANNOUNCEMENT' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.tournament_announcements (tournament_id, author_id, title, body, pinned)
    VALUES (p_tournament_id, v_uid, trim(p_title), trim(p_body), COALESCE(p_pinned, FALSE))
    RETURNING id INTO v_id;

    PERFORM public.log_audit(v_uid, 'tournament.announcement_published', 'tournament_announcement', v_id,
        NULL, jsonb_build_object('tournament_id', p_tournament_id, 'pinned', COALESCE(p_pinned, FALSE)));

    RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.create_tournament_announcement(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_tournament_announcement(UUID, TEXT, TEXT, BOOLEAN) TO authenticated;

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
            format('announcement:%s:%s', NEW.id, v_uid)
        );
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_announcement_published ON public.tournament_announcements;
CREATE TRIGGER trg_notify_announcement_published
    AFTER INSERT ON public.tournament_announcements
    FOR EACH ROW EXECUTE FUNCTION public.notify_announcement_published();

-- ============================================
-- 10. Reload PostgREST schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';
