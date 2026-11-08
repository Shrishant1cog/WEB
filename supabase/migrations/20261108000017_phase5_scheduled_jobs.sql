-- Migration: 20261108000017_phase5_scheduled_jobs
--
-- Phase 5 — Scheduled background processing via pg_cron
--
-- This migration enables pg_cron extension and sets up scheduled jobs for:
--   1. process_scheduled_notifications - processes future notifications (e.g. credential release)
--   2. claim_notification_delivery - claims and processes FCM push delivery queue
--
-- Both jobs run every minute. They use FOR UPDATE SKIP LOCKED to avoid
-- duplicate processing and are safe to run concurrently.

-- Enable pg_cron extension (requires superuser, run once per project)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- CREATE EXTENSION IF NOT EXISTS pg_net; -- for HTTP requests if needed

-- NOTE: The extension creation is commented out because it requires superuser
-- privileges. On Supabase, enable pg_cron via the Dashboard or CLI:
--   supabase extensions enable pg_cron
-- Then uncomment and run the cron job definitions below.

-- ============================================
-- 1. Scheduled notifications processor (runs every minute)
-- ============================================
-- SELECT cron.schedule(
--     'process-scheduled-notifications',
--     '* * * * *', -- every minute
--     $$ SELECT public.process_scheduled_notifications(100); $$
-- );

-- ============================================
-- 2. FCM delivery queue processor (runs every minute)
-- ============================================
-- SELECT cron.schedule(
--     'process-fcm-delivery-queue',
--     '* * * * *', -- every minute
--     $$ SELECT public.claim_notification_delivery(50); $$
-- );

-- ============================================
-- 3. Cleanup old processed deliveries (runs daily at 3 AM)
-- ============================================
-- SELECT cron.schedule(
--     'cleanup-notification-delivery-queue',
--     '0 3 * * *', -- daily at 3 AM
--     $$
--     DELETE FROM public.notification_delivery_queue
--     WHERE status IN ('sent', 'dead')
--       AND updated_at < NOW() - INTERVAL '7 days';
--     $$
-- );

-- ============================================
-- 4. Cleanup old scheduled notifications (runs daily at 4 AM)
-- ============================================
-- SELECT cron.schedule(
--     'cleanup-scheduled-notifications',
--     '0 4 * * *', -- daily at 4 AM
--     $$
--     DELETE FROM public.scheduled_notifications
--     WHERE processed_at IS NOT NULL
--       AND processed_at < NOW() - INTERVAL '30 days';
--     $$
-- );

-- ============================================
-- Helper: Unschedule all Phase 5 cron jobs (for removal)
-- ============================================
-- SELECT cron.unschedule('process-scheduled-notifications');
-- SELECT cron.unschedule('process-fcm-delivery-queue');
-- SELECT cron.unschedule('cleanup-notification-delivery-queue');
-- SELECT cron.unschedule('cleanup-scheduled-notifications');

-- ============================================
-- Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';