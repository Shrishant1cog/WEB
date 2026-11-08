-- Migration: 20261108000020_phase5_fcm_phase3_triggers
--
-- Phase 5 — Update Phase 3 notification triggers to request push delivery
--
-- The Phase 3 triggers call create_notification with 5 or 7 arguments.
-- They need to be updated to pass push_requested = true for push-worthy notifications.

-- ============================================
-- 1. Tournament cancelled notification
-- ============================================
DROP TRIGGER IF EXISTS trg_notify_tournament_cancelled ON public.tournaments;
DROP FUNCTION IF EXISTS public.notify_tournament_cancelled();

CREATE OR REPLACE FUNCTION public.notify_tournament_cancelled()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.status = 'cancelled' AND OLD.status <> 'cancelled' THEN
        FOR v_uid IN SELECT r.user_id FROM public.tournament_registrations r
            WHERE r.tournament_id = NEW.id AND r.status IN ('confirmed', 'waitlisted')
            UNION
            SELECT tem.user_id FROM public.tournament_registrations r
            JOIN public.tournament_entry_members tem ON tem.entry_id = r.id
            WHERE r.tournament_id = NEW.id AND r.status IN ('confirmed', 'waitlisted')
        LOOP
            PERFORM public.create_notification(
                v_uid,
                'tournament_cancelled',
                'Tournament cancelled',
                NEW.title || ' has been cancelled.',
                jsonb_build_object('tournament_id', NEW.id),
                'system',
                format('tournament_cancelled:%s:%s', NEW.id, v_uid),
                TRUE  -- push_requested
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_tournament_cancelled
    AFTER UPDATE ON public.tournaments
    FOR EACH ROW EXECUTE FUNCTION public.notify_tournament_cancelled();

-- ============================================
-- 2. Registration confirmed/waitlisted notification
-- ============================================
DROP TRIGGER IF EXISTS trg_notify_registration ON public.tournament_registrations;
DROP FUNCTION IF EXISTS public.notify_registration();

CREATE OR REPLACE FUNCTION public.notify_registration()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID;
    v_tournament_title TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT title INTO v_tournament_title FROM public.tournaments WHERE id = NEW.tournament_id;

        PERFORM public.create_notification(
            NEW.user_id,
            CASE WHEN NEW.status = 'confirmed' THEN 'registration_confirmed' ELSE 'registration_waitlisted' END,
            CASE WHEN NEW.status = 'confirmed' THEN 'Registration confirmed' ELSE 'Added to waitlist' END,
            format('Your %s for %s is %s.', 
                CASE WHEN NEW.entry_type = 'team' THEN 'team registration' ELSE 'registration' END,
                v_tournament_title,
                CASE WHEN NEW.status = 'confirmed' THEN 'confirmed' ELSE 'waitlisted' END),
            jsonb_build_object('tournament_id', NEW.tournament_id, 'entry_id', NEW.id, 'entry_type', NEW.entry_type),
            'registration',
            format('registration:%s:%s:%s', NEW.tournament_id, NEW.id, NEW.status),
            TRUE  -- push_requested
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_registration
    AFTER INSERT ON public.tournament_registrations
    FOR EACH ROW EXECUTE FUNCTION public.notify_registration();

-- ============================================
-- 3. Waitlist promoted notification (already updated in migration 19, but ensure it's correct)
-- ============================================
-- Already handled in migration 19

-- ============================================
-- 4. Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';