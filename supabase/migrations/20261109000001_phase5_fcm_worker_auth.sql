-- Migration: 20261109000001_phase5_fcm_worker_auth
--
-- Phase 5 — Secure FCM worker authentication via Supabase Vault
--
-- This migration:
--   1. Creates a helper function to retrieve the FCM worker API key from Vault
--   2. The key is stored as 'fcm_worker_key' in Vault (not a JWT)
--   3. The cron job fetches the key via the helper function
--
-- DEPLOYMENT: After running this migration, store the service_role key in Vault:
--   SELECT vault.create_secret('fcm_worker_key', '<service_role_key>');
--
-- KEY REQUIREMENTS:
--   - The key is the Supabase service_role key (from Dashboard > Settings > API)
--   - This is an opaque API key (not a JWT), used directly as Bearer token
--   - The Edge Function validates by using the key to make a Supabase admin call
--   - The service_role key never expires

-- ============================================
-- 1. Vault helper function to retrieve API key
-- ============================================
CREATE OR REPLACE FUNCTION public.get_fcm_worker_key()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_key TEXT;
BEGIN
    -- Retrieve the API key from Vault using the decrypted_secrets view
    -- The secret must be created separately: SELECT vault.create_secret('fcm_worker_key', '<service_role_key>');
    SELECT secret INTO v_key
    FROM vault.decrypted_secrets
    WHERE name = 'fcm_worker_key';
    
    IF v_key IS NULL THEN
        RAISE EXCEPTION 'FCM worker key not configured in Vault. Run: SELECT vault.create_secret(''fcm_worker_key'', ''<service_role_key>'');'
            USING ERRCODE = '55000';
    END IF;
    
    RETURN v_key;
END;
$$;

REVOKE ALL ON FUNCTION public.get_fcm_worker_key() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_fcm_worker_key() TO service_role;

-- ============================================
-- 2. Wrapper function for cron job (returns JSON for pg_net)
-- ============================================
CREATE OR REPLACE FUNCTION public.get_fcm_worker_auth_header()
RETURNS JSONB
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT jsonb_build_object(
        'Authorization', 'Bearer ' || public.get_fcm_worker_key(),
        'Content-Type', 'application/json'
    );
$$;

REVOKE ALL ON FUNCTION public.get_fcm_worker_auth_header() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_fcm_worker_auth_header() TO service_role;

-- ============================================
-- 3. Reload schema
-- ============================================
NOTIFY pgrst, 'reload schema';