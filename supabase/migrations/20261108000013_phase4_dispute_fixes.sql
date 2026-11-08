-- Migration: 20261108000013_phase4_final_fixes.sql
-- Phase 4 Final Fixes
--
-- Fixes:
-- 1. Fix duplicate dispute check in submit_dispute to use a partial unique index for concurrency safety
-- 2. Fix submit_dispute authorization to properly check tournament_entry_members
-- 3. Fix assign_dispute_moderator to properly check moderator role and conflict of interest
-- 4. Add partial unique index on disputes for active disputes
-- 5. Fix submit_dispute authorization to properly check tournament_entry_members for squad members

-- ============================================
-- 1. Add partial unique index on disputes for active disputes
-- ============================================
-- This provides database-level concurrency protection for active disputes
-- Only one active dispute (submitted/under_review) per match per registration
CREATE UNIQUE INDEX IF NOT EXISTS uq_disputes_active_per_match_registration
    ON public.disputes (match_id, registration_id)
    WHERE status IN ('submitted', 'under_review');

-- ============================================
-- 2. Fix submit_dispute - add database-level protection and fix authorization
-- ============================================
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
    -- Check both direct registrant and team members via tournament_entry_members
    IF NOT EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = p_registration_id AND user_id = v_uid
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = '42501';
    END IF;

    -- Try to insert the dispute - the unique index will prevent concurrent duplicates
    BEGIN
        INSERT INTO public.disputes (
            match_id, registration_id, submitted_by, reason, evidence_paths
        ) VALUES (
            p_match_id, p_registration_id, v_uid, p_reason, p_evidence_paths
        ) RETURNING id INTO v_dispute_id;
    EXCEPTION
        WHEN unique_violation THEN
            -- Check if it's our unique index violation
            IF EXISTS (
                SELECT 1 FROM public.disputes
                WHERE match_id = p_match_id
                  AND registration_id = p_registration_id
                  AND status IN ('submitted', 'under_review')
            ) THEN
                RAISE EXCEPTION 'DISPUTE_ALREADY_EXISTS' USING ERRCODE = 'P0001';
            ELSE
                RAISE;
            END IF;
    END;

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
-- 3. Fix assign_dispute_moderator - fix moderator conflict check
-- ============================================
-- The current check for moderator conflict looks at tournament_entry_members
-- but it should check if the moderator is part of the registration roster
-- that is involved in the dispute
DROP FUNCTION IF EXISTS public.assign_dispute_moderator(UUID, UUID);

CREATE OR REPLACE FUNCTION public.assign_dispute_moderator(
    p_dispute_id UUID,
    p_moderator_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_d public.disputes%ROWTYPE;
    v_m public.matches%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
    v_mod_reg public.tournament_registrations%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_d FROM public.disputes WHERE id = p_dispute_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'DISPUTE_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = v_d.match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_t.id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    -- Verify moderator is a tournament organizer with moderator role
    IF NOT EXISTS (
        SELECT 1 FROM public.tournament_organizers
        WHERE tournament_id = v_t.id AND user_id = p_moderator_id AND role = 'moderator'
    ) THEN
        RAISE EXCEPTION 'NOT_DISPUTE_MODERATOR' USING ERRCODE = '42501';
    END IF;

    -- Conflict of interest: moderator cannot be the submitter
    IF p_moderator_id = v_d.submitted_by THEN
        RAISE EXCEPTION 'MODERATOR_CONFLICT' USING ERRCODE = '42501';
    END IF;

    -- Conflict of interest: moderator cannot be in the registration roster
    -- Check if moderator is part of the registration roster (tournament_entry_members)
    IF EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = (
            SELECT id FROM public.tournament_registrations WHERE id = v_d.registration_id
        ) AND user_id = p_moderator_id
    ) THEN
        RAISE EXCEPTION 'MODERATOR_CONFLICT' USING ERRCODE = '42501';
    END IF;

    UPDATE public.disputes
    SET moderator_id = p_moderator_id, status = 'under_review', assigned_at = NOW()
    WHERE id = p_dispute_id;

    PERFORM public.log_audit(v_uid, 'dispute.moderator_assigned', 'dispute', p_dispute_id, NULL,
        jsonb_build_object('moderator_id', p_moderator_id)
    );
END;
$$;

-- Re-grant
REVOKE ALL ON FUNCTION public.assign_dispute_moderator(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assign_dispute_moderator(UUID, UUID) TO authenticated;