-- Migration: 20261108000018_phase5_fcm_per_device_queue
--
-- Phase 5 — Fix FCM delivery queue for per-device delivery
--
-- The original notification_delivery_queue had one row per notification (UNIQUE on notification_id, channel).
-- For FCM, each device token needs its own delivery row with independent status, retries, and token handling.
--
-- Changes:
--   1. Add device_token column to notification_delivery_queue
--   2. Change UNIQUE constraint to (notification_id, device_token)
--   3. Update enqueue_push_delivery trigger to create one row per active device token
--   4. Update claim_notification_delivery to work with per-device rows
--   5. Update complete_notification_delivery (no change needed, works by queue_id)

-- ============================================
-- 1. Add device_token column and update constraints
-- ============================================
ALTER TABLE public.notification_delivery_queue
    ADD COLUMN IF NOT EXISTS device_token TEXT;

-- Drop old unique constraint and create new one per device
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'notification_delivery_queue_notification_id_channel_key'
    ) THEN
        ALTER TABLE public.notification_delivery_queue
            DROP CONSTRAINT notification_delivery_queue_notification_id_channel_key;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'notification_delivery_queue_notification_id_device_token_key'
    ) THEN
        ALTER TABLE public.notification_delivery_queue
            ADD CONSTRAINT notification_delivery_queue_notification_id_device_token_key
            UNIQUE (notification_id, device_token);
    END IF;
END $$;

-- Index for efficient lookups by device token
CREATE INDEX IF NOT EXISTS idx_notification_delivery_queue_device_token
    ON public.notification_delivery_queue (device_token)
    WHERE status IN ('pending', 'failed', 'processing');

-- ============================================
-- 2. Update enqueue trigger to create one row per active device token
-- ============================================
CREATE OR REPLACE FUNCTION public.enqueue_push_delivery()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.push_requested THEN
        -- Get all active device tokens for this user
        INSERT INTO public.notification_delivery_queue (notification_id, channel, device_token)
        SELECT NEW.id, 'push', dt.token
        FROM public.device_tokens dt
        WHERE dt.user_id = NEW.user_id
          AND dt.revoked_at IS NULL
        ON CONFLICT (notification_id, device_token) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enqueue_push_delivery ON public.notifications;
CREATE TRIGGER trg_enqueue_push_delivery
    AFTER INSERT ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.enqueue_push_delivery();

-- ============================================
-- 3. Update claim_notification_delivery for per-device rows
-- ============================================
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
    -- Rows without an active device token are closed as 'no_device'
    UPDATE public.notification_delivery_queue q
    SET status = 'no_device', updated_at = NOW()
    WHERE q.status IN ('pending', 'failed')
      AND q.next_attempt_at <= NOW()
      AND NOT EXISTS (
          SELECT 1 FROM public.device_tokens dt
          WHERE dt.token = q.device_token
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
              WHERE dt.token = q.device_token
                AND dt.revoked_at IS NULL
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
    SELECT c.id, c.notification_id, n.user_id, c.device_token as token, n.title, n.body, n.data,
           c.attempts, n.category
    FROM claimed c
    JOIN public.notifications n ON n.id = c.notification_id
    ORDER BY c.created_at;
END;
$$;

-- ============================================
-- 4. Update claim function permissions
-- ============================================
REVOKE ALL ON FUNCTION public.claim_notification_delivery(INTEGER) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_notification_delivery(INTEGER) TO service_role;

-- ============================================
-- 5. Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';