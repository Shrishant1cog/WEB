-- Migration: 20261109000001_phase5_fcm_worker_auth
--
-- Phase 5 — Secure FCM worker authentication via Supabase Vault
--
-- This migration:
--   1. Creates a helper function to retrieve the FCM worker JWT from Vault
--   2. The JWT is stored as a secret in Vault (not in this migration)
--   3. The cron job fetches the JWT via the helper function
--
-- DEPLOYMENT: After running this migration, store the JWT in Vault:
--   SELECT vault.create_secret('fcm_worker_jwt', '<jwt-token>');
--
-- JWT REQUIREMENTS:
--   - role: 'service_role'
--   - aud: 'fcm-worker'
--   - iss: '{SUPABASE_URL}/auth/v1'
--   - exp: far future (e.g., 10 years) or rotate periodically
--   - Generate using Supabase service_role key (not exposed to cron)

-- ============================================
-- 1. Vault helper function
-- ============================================
CREATE OR REPLACE FUNCTION public.get_fcm_worker_jwt()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_jwt TEXT;
BEGIN
    -- Retrieve the JWT from Vault
    -- The secret must be created separately: SELECT vault.create_secret('fcm_worker_jwt', '<jwt>');
    SELECT vault.decrypt_secret('fcm_worker_jwt') INTO v_jwt;
    
    IF v_jwt IS NULL THEN
        RAISE EXCEPTION 'FCM worker JWT not configured in Vault'
            USING ERRCODE = '55000';
    END IF;
    
    RETURN v_jwt;
END;
$$;

REVOKE ALL ON FUNCTION public.get_fcm_worker_jwt() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_fcm_worker_jwt() TO service_role;

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
        'Authorization', 'Bearer ' || public.get_fcm_worker_jwt(),
        'Content-Type', 'application/json'
    );
$$;

REVOKE ALL ON FUNCTION public.get_fcm_worker_auth_header() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_fcm_worker_auth_header() TO service_role;

-- ============================================
-- 3. Reload schema
-- ============================================
NOTIFY pgrst, 'reload schema';