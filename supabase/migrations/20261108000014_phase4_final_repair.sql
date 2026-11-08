-- Migration: 20261108000014_phase4_final_repair
--
-- Phase 4 acceptance repairs. This migration is additive; it does not edit
-- already-applied migrations.
--
-- Fixes:
--   1. assign_match_entries: batch capacity computation, duplicate detection,
--      null/empty array handling, atomic validation, and deterministic
--      serialization of concurrent assignments for the same match.
--   2. save_result_draft: protect the result lifecycle. Drafts may only be
--      created or updated while the result is still a draft. Provisional,
--      disputed and finalized results are immutable from this RPC.
--   3. is_team_staff: derive the identity from auth.uid() so callers cannot
--      check (or grant) another user's team privileges, and narrow EXECUTE.
--   4. Restore member read access to team history without re-introducing RLS
--      recursion (the recursive team_members policy is gone).

-- ============================================
-- 1. assign_match_entries
-- ============================================
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
    v_batch_count INTEGER;
    v_distinct_count INTEGER;
    v_existing_count INTEGER;
    v_slot INTEGER;
    v_seed INTEGER;
    v_side TEXT;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    -- Serialize all assignment attempts for this match. The second concurrent
    -- caller blocks here, then re-reads committed entries below, so capacity
    -- can never be exceeded by parallel requests.
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

    -- NULL and empty arrays are both rejected. cardinality() also handles
    -- arrays that array_length() cannot inspect (e.g. '{}').
    v_batch_count := COALESCE(cardinality(p_registration_ids), 0);
    IF v_batch_count = 0 THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    IF EXISTS (
        SELECT 1 FROM unnest(p_registration_ids) AS rid WHERE rid IS NULL
    ) THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Duplicate IDs inside one submitted batch are a client error, not a
    -- partially valid batch.
    SELECT count(DISTINCT rid) INTO v_distinct_count
    FROM unnest(p_registration_ids) AS rid;
    IF v_distinct_count <> v_batch_count THEN
        RAISE EXCEPTION 'DUPLICATE_ENTRY_IN_BATCH' USING ERRCODE = '22023';
    END IF;

    -- Validate every registration before writing anything. The whole function
    -- is one transaction, so a later failure rolls the batch back.
    FOR v_idx IN 1..v_batch_count LOOP
        SELECT * INTO v_reg
        FROM public.tournament_registrations
        WHERE id = p_registration_ids[v_idx]
        FOR SHARE;

        IF NOT FOUND
           OR v_reg.tournament_id <> v_m.tournament_id
           OR v_reg.status <> 'confirmed' THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;
    END LOOP;

    -- Reject any registration that already has an entry in this match.
    IF EXISTS (
        SELECT 1
        FROM public.match_entries
        WHERE match_id = p_match_id
          AND registration_id = ANY(p_registration_ids)
    ) THEN
        RAISE EXCEPTION 'ENTRY_ALREADY_ASSIGNED' USING ERRCODE = 'P0001';
    END IF;

    -- Capacity is existing committed entries plus the complete new batch,
    -- computed exactly once (not per loop iteration).
    IF v_m.max_entries IS NOT NULL THEN
        SELECT count(*) INTO v_existing_count
        FROM public.match_entries
        WHERE match_id = p_match_id;

        IF v_existing_count + v_batch_count > v_m.max_entries THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = 'P0001';
        END IF;
    END IF;

    FOR v_idx IN 1..v_batch_count LOOP
        v_slot := CASE WHEN p_slots IS NOT NULL AND v_idx <= cardinality(p_slots)
                      THEN p_slots[v_idx] ELSE v_idx END;
        v_seed := CASE WHEN p_seeds IS NOT NULL AND v_idx <= cardinality(p_seeds)
                      THEN p_seeds[v_idx] ELSE v_idx END;
        v_side := CASE WHEN p_sides IS NOT NULL AND v_idx <= cardinality(p_sides)
                      THEN p_sides[v_idx] ELSE NULL END;

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

REVOKE ALL ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) TO authenticated;

-- ============================================
-- 2. save_result_draft
-- ============================================
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
    v_result public.results%ROWTYPE;
    v_team_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    -- Lock the match first. Every result mutation uses this same lock order,
    -- so a concurrent publish/finalize cannot race the state check below.
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

    IF NOT EXISTS (
        SELECT 1 FROM public.match_entries
        WHERE match_id = p_match_id AND registration_id = p_registration_id
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = 'P0002';
    END IF;

    v_team_id := v_reg.team_id;

    SELECT * INTO v_result
    FROM public.results
    WHERE match_id = p_match_id AND registration_id = p_registration_id
    FOR UPDATE;

    IF FOUND THEN
        -- The draft RPC is not a publishing path. Once a result has moved past
        -- draft, any attempt to overwrite it is rejected and no data changes.
        IF v_result.status <> 'draft' THEN
            RAISE EXCEPTION 'RESULT_NOT_EDITABLE' USING ERRCODE = 'P0001';
        END IF;

        UPDATE public.results SET
            rank = p_rank,
            kills = p_kills,
            placement_points = p_placement_points,
            kill_points = p_kill_points,
            total_points = p_total_points,
            scoring_rules_snapshot = p_scoring_snapshot,
            team_id = v_team_id
        WHERE id = v_result.id
          AND status = 'draft';
    ELSE
        INSERT INTO public.results (
            match_id, registration_id, team_id, rank, kills,
            placement_points, kill_points, total_points,
            scoring_rules_snapshot, status
        ) VALUES (
            p_match_id, p_registration_id, v_team_id, p_rank, p_kills,
            p_placement_points, p_kill_points, p_total_points,
            p_scoring_snapshot, 'draft'
        );
    END IF;

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

REVOKE ALL ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) TO authenticated;

-- ============================================
-- 3. is_team_staff
-- ============================================
-- The old two-argument signature accepted a caller-supplied user id, which
-- allowed any authenticated client to probe another user's team role. The
-- identity now comes exclusively from auth.uid().
--
-- Drop the dependent policies and the old overload first: a one-argument call
-- would otherwise be ambiguous while both overloads exist.
DROP POLICY IF EXISTS "Team staff can manage members" ON public.team_members;
DROP POLICY IF EXISTS "Team members can read team history" ON public.team_member_events;

DROP FUNCTION IF EXISTS public.is_team_staff(UUID, UUID);

CREATE OR REPLACE FUNCTION public.is_team_staff(p_team_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT COALESCE(auth.uid() IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.team_members
        WHERE team_id = p_team_id
          AND user_id = auth.uid()
          AND role IN ('owner', 'captain')
    ), false);
$$;

CREATE POLICY "Team staff can manage members"
    ON public.team_members FOR ALL
    USING (public.is_team_staff(team_id))
    WITH CHECK (public.is_team_staff(team_id));

CREATE POLICY "Team members can read team history"
    ON public.team_member_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.teams t
            WHERE t.id = team_member_events.team_id
              AND (t.is_public = true OR t.owner_id = auth.uid() OR t.captain_id = auth.uid())
        )
        OR EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE tm.team_id = team_member_events.team_id
              AND tm.user_id = auth.uid()
        )
        OR public.is_team_staff(team_member_events.team_id)
    );

REVOKE ALL ON FUNCTION public.is_team_staff(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_team_staff(UUID) TO authenticated;

-- ============================================
-- 4. finalize_match_results
-- ============================================
-- The Phase 4 migration declared v_assigned_count inside a nested DECLARE
-- block but referenced it outside, so finalization always failed with
-- "column v_assigned_count does not exist". Recreate the function with the
-- variable in the function-level scope.
CREATE OR REPLACE FUNCTION public.finalize_match_results(p_match_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_pending_disputes INTEGER;
    v_provisional_count INTEGER;
    v_assigned_count INTEGER;
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

    IF v_m.status <> 'completed' THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    SELECT count(*) INTO v_pending_disputes
    FROM public.disputes
    WHERE match_id = p_match_id AND status IN ('submitted', 'under_review');
    IF v_pending_disputes > 0 THEN
        RAISE EXCEPTION 'CANNOT_FINALIZE_PENDING_DISPUTES' USING ERRCODE = 'P0001';
    END IF;

    SELECT count(*) INTO v_provisional_count
    FROM public.results
    WHERE match_id = p_match_id AND status = 'provisional';

    SELECT count(*) INTO v_assigned_count
    FROM public.match_entries
    WHERE match_id = p_match_id;

    IF v_provisional_count < v_assigned_count THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.results
    SET status = 'finalized', finalized_at = NOW(), finalized_by = v_uid
    WHERE match_id = p_match_id AND status = 'provisional';

    PERFORM public.log_audit(v_uid, 'result.finalized', 'result', NULL, NULL,
        jsonb_build_object('match_id', p_match_id)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.finalize_match_results(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.finalize_match_results(UUID) TO authenticated;

-- ============================================
-- 5. Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';
