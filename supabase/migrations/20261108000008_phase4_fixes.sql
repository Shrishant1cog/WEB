-- Migration: 20261108000008_phase4_fixes
-- Phase 4 Blocker Fixes
--
-- Fixes:
-- 1. Duplicate assignment constraint enforcement (Issue 2)
-- 2. team_id nullable for solo matches (Issue 4)
-- 3. Results ON CONFLICT behavior clarification (Issue 6 - test alignment)

-- ============================================
-- 1. Fix duplicate assignment constraint enforcement
-- ============================================
-- The assign_match_entries RPC currently uses ON CONFLICT DO NOTHING which
-- silently ignores duplicates. It should raise an explicit error.

CREATE OR REPLACE FUNCTION public.assign_match_entries(
    p_match_id UUID,
    p_registration_ids UUID[],
    p_slots INTEGER[] DEFAULT NULL,
    p_seeds INTEGER[] DEFAULT NULL,
    p_sides TEXT[] DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_idx INTEGER;
    v_slot INTEGER;
    v_seed INTEGER;
    v_side TEXT;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'scheduled' THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    IF p_registration_ids IS NULL OR array_length(p_registration_ids, 1) = 0 THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Validate each registration
    FOR v_idx IN 1..array_length(p_registration_ids, 1) LOOP
        SELECT * INTO v_reg FROM public.tournament_registrations
        WHERE id = p_registration_ids[v_idx] FOR SHARE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;
        IF v_reg.tournament_id <> v_m.tournament_id THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;
        IF v_reg.status <> 'confirmed' THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;

        -- Check max_entries if set
        IF v_m.max_entries IS NOT NULL THEN
            DECLARE
                v_current_count INTEGER;
            BEGIN
                SELECT count(*) INTO v_current_count
                FROM public.match_entries
                WHERE match_id = p_match_id;
                IF v_current_count + array_length(p_registration_ids, 1) > v_m.max_entries THEN
                    RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = 'P0001';
                END IF;
            END;
        END IF;

        -- Check for duplicate assignment BEFORE insert
        IF EXISTS (
            SELECT 1 FROM public.match_entries
            WHERE match_id = p_match_id AND registration_id = p_registration_ids[v_idx]
        ) THEN
            RAISE EXCEPTION 'ENTRY_ALREADY_ASSIGNED' USING ERRCODE = 'P0001';
        END IF;

        -- Determine slot/seed/side
        v_slot := CASE WHEN p_slots IS NOT NULL AND v_idx <= array_length(p_slots, 1)
                      THEN p_slots[v_idx] ELSE v_idx END;
        v_seed := CASE WHEN p_seeds IS NOT NULL AND v_idx <= array_length(p_seeds, 1)
                      THEN p_seeds[v_idx] ELSE v_idx END;
        v_side := CASE WHEN p_sides IS NOT NULL AND v_idx <= array_length(p_sides, 1)
                      THEN p_sides[v_idx] ELSE NULL END;

        -- Insert match entry (no ON CONFLICT needed since we checked above)
        INSERT INTO public.match_entries (match_id, registration_id, slot, seed, side, assigned_by)
        VALUES (p_match_id, p_registration_ids[v_idx], v_slot, v_seed, v_side, v_uid);

        PERFORM public.log_audit(v_uid, 'match.entry_assigned', 'match_entry', NULL, NULL,
            jsonb_build_object(
                'match_id', p_match_id,
                'registration_id', p_registration_ids[v_idx],
                'slot', v_slot,
                'seed', v_seed,
                'side', v_side
            )
        );
    END LOOP;
END;
$$;

-- ============================================
-- 2. Make team_id nullable in results for solo matches
-- ============================================
-- Solo matches don't have teams. Results should be linked via registration_id.
-- The unique constraint is on (match_id, registration_id), so team_id can be NULL.

ALTER TABLE public.results
    ALTER COLUMN team_id DROP NOT NULL;

-- Add check constraint to ensure at least one of team_id or registration_id is set
-- (for backward compatibility with legacy team-based results)
ALTER TABLE public.results
    ADD CONSTRAINT results_team_or_registration
    CHECK (team_id IS NOT NULL OR registration_id IS NOT NULL);

-- Update save_result_draft to set team_id from registration's team_id for squad matches,
-- NULL for solo matches (registration.team_id is NULL for solo)
-- The existing save_result_draft already uses registration_id for the unique constraint.
-- We just need to ensure team_id is set appropriately for backward compatibility.

-- Drop and recreate save_result_draft with team_id handling
DROP FUNCTION IF EXISTS public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION public.save_result_draft(
    p_match_id UUID,
    p_registration_id UUID,
    p_rank INTEGER,
    p_kills INTEGER DEFAULT 0,
    p_placement_points INTEGER DEFAULT 0,
    p_kill_points INTEGER DEFAULT 0,
    p_total_points INTEGER DEFAULT 0,
    p_scoring_snapshot JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_team_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('in_progress', 'completed') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
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

    -- Get tournament scoring config
    DECLARE v_t public.tournaments%ROWTYPE;
    BEGIN
        SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    END;

    -- Get team_id from registration for squad matches (NULL for solo)
    v_team_id := v_reg.team_id;

    INSERT INTO public.results (
        match_id, registration_id, team_id, rank, kills,
        placement_points, kill_points, total_points,
        scoring_rules_snapshot, status
    ) VALUES (
        p_match_id, p_registration_id, v_team_id, p_rank, p_kills,
        p_placement_points, p_kill_points, p_total_points,
        p_scoring_snapshot, 'draft'
    )
    ON CONFLICT (match_id, registration_id) DO UPDATE SET
        rank = EXCLUDED.rank,
        kills = EXCLUDED.kills,
        placement_points = EXCLUDED.placement_points,
        kill_points = EXCLUDED.kill_points,
        total_points = EXCLUDED.total_points,
        scoring_rules_snapshot = EXCLUDED.scoring_rules_snapshot,
        team_id = EXCLUDED.team_id,
        status = 'draft';

    PERFORM public.log_audit(v_uid, 'result.draft_saved', 'result', NULL, NULL,
        jsonb_build_object(
            'match_id', p_match_id,
            'registration_id', p_registration_id,
            'rank', p_rank,
            'kills', p_kills,
            'total_points', p_total_points
        )
    );
END;
$$;

-- ============================================
-- 3. Grant EXECUTE on updated functions
-- ============================================
REVOKE ALL ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) TO authenticated;