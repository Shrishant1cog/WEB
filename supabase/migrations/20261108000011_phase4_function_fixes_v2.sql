-- Migration: 20261108000010_phase4_function_fixes.sql
-- Phase 4 Function Fixes
--
-- Fixes:
-- 1. get_match_credentials: Check tournament_entry_members for squad participants
-- 2. Ensure all functions are properly granted and visible

-- ============================================
-- 1. Fix get_match_credentials to support squad participants
-- ============================================
-- The current function only checks if the user is the registrant (r.user_id = v_uid).
-- For squad matches, team members are in tournament_entry_members, not the registrant.
-- Update to also check tournament_entry_members.

CREATE OR REPLACE FUNCTION public.get_match_credentials(p_match_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_secret public.match_room_secrets%ROWTYPE;
    v_key_name TEXT := 'match_cred_key_v1';
    v_key TEXT;
    v_room_id TEXT;
    v_room_pw TEXT;
    v_granted BOOLEAN;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    -- Get match
    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    -- Get secret
    SELECT * INTO v_secret FROM public.match_room_secrets WHERE match_id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'CREDENTIALS_NOT_SET' USING ERRCODE = 'P0002';
    END IF;

    -- Check release time
    IF v_secret.released_at IS NULL AND v_secret.release_at > NOW() THEN
        -- Not yet released
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, NULL, false, v_secret.release_at
        );
        RAISE EXCEPTION 'CREDENTIALS_NOT_RELEASED' USING ERRCODE = 'P0001';
    END IF;

    -- Verify user has confirmed registration assigned to this match
    -- Check both direct registrant and team members via tournament_entry_members
    SELECT r.* INTO v_reg
    FROM public.tournament_registrations r
    JOIN public.match_entries me ON me.registration_id = r.id
    WHERE me.match_id = p_match_id
      AND r.status = 'confirmed'
      AND (
          r.user_id = v_uid
          OR EXISTS (
              SELECT 1 FROM public.tournament_entry_members tem
              WHERE tem.entry_id = r.id AND tem.user_id = v_uid
          )
      )
    LIMIT 1;

    IF NOT FOUND THEN
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, NULL, false, v_secret.release_at
        );
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = '42501';
    END IF;

    -- Check match not cancelled
    IF v_m.status = 'cancelled' THEN
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, v_reg.id, false, v_secret.release_at
        );
        RAISE EXCEPTION 'CREDENTIALS_NOT_RELEASED' USING ERRCODE = 'P0001';
    END IF;

    -- Mark as released if first access after release_at
    IF v_secret.released_at IS NULL AND v_secret.release_at <= NOW() THEN
        UPDATE public.match_room_secrets SET released_at = NOW() WHERE match_id = p_match_id;
    END IF;

    -- Decrypt credentials
    v_key := 'dev-match-cred-key-v1-change-in-production'; -- In production: vault.decrypted_secrets

    v_room_id := public.simple_decrypt(v_secret.room_id_ciphertext, v_key);
    v_room_pw := public.simple_decrypt(v_secret.room_password_ciphertext, v_key);

    -- Log successful access
    INSERT INTO public.match_credential_access (
        match_id, user_id, registration_id, access_granted, release_at
    ) VALUES (
        p_match_id, v_uid, v_reg.id, true, v_secret.release_at
    );

    PERFORM public.log_audit(v_uid, 'match.credentials_accessed', 'match_credentials', p_match_id, NULL,
        jsonb_build_object('registration_id', v_reg.id)
    );

    RETURN jsonb_build_object(
        'room_id', v_room_id,
        'room_password', v_room_pw,
        'match_id', p_match_id,
        'match_status', v_m.status
    );
END;
$$;

-- ============================================
-- 2. Re-grant EXECUTE on all Phase 4 functions to ensure visibility
-- ============================================
REVOKE ALL ON FUNCTION public.get_match_credentials(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_match_credentials(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) TO authenticated;

REVOKE ALL ON FUNCTION public.assign_dispute_moderator(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assign_dispute_moderator(UUID, UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.finalize_match_results(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.finalize_match_results(UUID) TO authenticated;

-- ============================================
-- 3. Fix submit_dispute function signature to match expected order
-- ============================================
-- The function exists but PostgREST cache may have stale signature.
-- Re-create to ensure correct signature is cached.

DROP FUNCTION IF EXISTS public.submit_dispute(UUID, UUID, TEXT, TEXT[]);

CREATE OR REPLACE FUNCTION public.submit_dispute(
    p_match_id UUID,
    p_registration_id UUID,
    p_reason TEXT,
    p_evidence_paths TEXT[] DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_dispute_id UUID;
    v_t public.tournaments%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    -- Check if match is completed (dispute window starts after match completion)
    IF v_m.status <> 'completed' THEN
        RAISE EXCEPTION 'DISPUTE_WINDOW_CLOSED' USING ERRCODE = 'P0001';
    END IF;

    -- Check dispute window
    IF v_m.ended_at IS NOT NULL AND v_m.ended_at + (v_t.dispute_window_hours || ' hours')::INTERVAL < NOW() THEN
        RAISE EXCEPTION 'DISPUTE_WINDOW_CLOSED' USING ERRCODE = 'P0001';
    END IF;

    SELECT * INTO v_reg FROM public.tournament_registrations
    WHERE id = p_registration_id AND tournament_id = v_m.tournament_id AND status = 'confirmed'
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Verify registration is assigned to this match
    IF NOT EXISTS (
        SELECT 1 FROM public.match_entries
        WHERE match_id = p_match_id AND registration_id = p_registration_id
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = 'P0002';
    END IF;

    -- Verify submitter is part of the registration roster
    IF NOT EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = (
            SELECT id FROM public.tournament_registrations WHERE id = p_registration_id
        ) AND user_id = v_uid
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = '42501';
    END IF;

    -- Check for existing active dispute
    IF EXISTS (
        SELECT 1 FROM public.disputes
        WHERE match_id = p_match_id
          AND registration_id = p_registration_id
          AND status IN ('submitted', 'under_review')
    ) THEN
        RAISE EXCEPTION 'DISPUTE_ALREADY_EXISTS' USING ERRCODE = 'P0001';
    END IF;

    INSERT INTO public.disputes (
        match_id, registration_id, submitted_by, reason, evidence_paths
    ) VALUES (
        p_match_id, p_registration_id, v_uid, p_reason, p_evidence_paths
    ) RETURNING id INTO v_dispute_id;

    PERFORM public.log_audit(v_uid, 'dispute.submitted', 'dispute', v_dispute_id, NULL,
        jsonb_build_object('match_id', p_match_id, 'registration_id', p_registration_id)
    );

    RETURN v_dispute_id;
END;
$$;

-- Re-grant
REVOKE ALL ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) TO authenticated;

-- ============================================
-- 4. Re-grant all Phase 4 functions
-- ============================================
REVOKE ALL ON FUNCTION public.get_match_credentials(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_match_credentials(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) TO authenticated;

REVOKE ALL ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) TO authenticated;

REVOKE ALL ON FUNCTION public.assign_dispute_moderator(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assign_dispute_moderator(UUID, UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.finalize_match_results(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.finalize_match_results(UUID) TO authenticated;