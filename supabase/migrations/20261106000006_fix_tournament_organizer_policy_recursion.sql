-- Migration: 20261106000006_fix_tournament_organizer_policy_recursion
--
-- Corrective Phase 3 migration. Migration 1 created the policy
-- "Tournament owner can manage organizers" on public.tournament_organizers
-- with a subquery over public.tournament_organizers itself. PostgreSQL
-- rejects that with:
--
--   ERROR: infinite recursion detected in policy for relation "tournament_organizers"
--
-- The failure surfaced for every authenticated user whose request touched a
-- policy that references tournament_organizers (own profile updates,
-- tournament_registrations reads, tournament_entry_members reads).
--
-- Correction strategy (least privilege, no RLS disabled):
--   * The policy is re-expressed against the tournament owner recorded on
--     public.tournaments, so evaluating it never re-enters the
--     tournament_organizers policies.
--   * Only the tournament owner may manage organizer rows, exactly as before.
--   * Public.tournaments policies do not reference tournament_organizers,
--     so the new subquery cannot introduce a second recursion path.
--   * The helper functions used by policies/RPCs stay SECURITY DEFINER with a
--     fixed search_path, and their EXECUTE privilege is narrowed from PUBLIC
--     to the authenticated role.

-- ============================================
-- 1. Break the recursive policy
-- ============================================
DROP POLICY IF EXISTS "Tournament owner can manage organizers" ON public.tournament_organizers;

CREATE POLICY "Tournament owner can manage organizers"
    ON public.tournament_organizers FOR ALL
    USING (
        EXISTS (
            SELECT 1
            FROM public.tournaments t
            WHERE t.id = tournament_organizers.tournament_id
              AND t.organizer_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.tournaments t
            WHERE t.id = tournament_organizers.tournament_id
              AND t.organizer_id = auth.uid()
        )
    );

-- ============================================
-- 2. Narrow helper execution privileges
-- ============================================
REVOKE ALL ON FUNCTION public.is_tournament_organizer(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_tournament_organizer(UUID, UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.is_team_captain(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_team_captain(UUID, UUID) TO authenticated;

-- promote_next_waitlisted is an internal helper used by
-- withdraw_tournament_entry; it must not be directly callable by clients.
REVOKE ALL ON FUNCTION public.promote_next_waitlisted(UUID) FROM PUBLIC;

-- ============================================
-- 3. Freeze team rosters that are already registered
-- ============================================
-- A confirmed/waitlisted squad registration stores an immutable roster
-- snapshot in public.tournament_entry_members. Letting the captain remove a
-- member, transfer captaincy or leave the team while that registration is
-- live would silently make the live roster disagree with the snapshot the
-- organizers and the waitlist rely on.
--
-- public.dissolve_team already refuses this scenario with
-- TEAM_HAS_ACTIVE_REGISTRATION; the same rule is applied to the remaining
-- roster mutations.

CREATE OR REPLACE FUNCTION public.team_has_active_registration(p_team_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.tournament_registrations r
        JOIN public.tournaments t ON t.id = r.tournament_id
        WHERE r.team_id = p_team_id
          AND r.status IN ('pending', 'confirmed', 'waitlisted')
          AND t.status IN ('published', 'registration_open', 'registration_closed', 'in_progress')
    );
$$;

REVOKE ALL ON FUNCTION public.team_has_active_registration(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.team_has_active_registration(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.remove_team_member(
    p_team_id UUID,
    p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_REMOVE' USING ERRCODE = '42501';
    END IF;
    IF p_user_id = v_uid THEN
        RAISE EXCEPTION 'USE_LEAVE_TEAM' USING ERRCODE = 'P0001';
    END IF;
    IF public.team_has_active_registration(p_team_id) THEN
        RAISE EXCEPTION 'TEAM_HAS_ACTIVE_REGISTRATION' USING ERRCODE = 'P0001';
    END IF;

    DELETE FROM public.team_members WHERE team_id = p_team_id AND user_id = p_user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MEMBER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (p_team_id, v_uid, 'member_removed', p_user_id);

    PERFORM public.log_audit(v_uid, 'team.member_removed', 'team', p_team_id, NULL,
        jsonb_build_object('user_id', p_user_id));
END;
$$;

CREATE OR REPLACE FUNCTION public.transfer_team_captaincy(
    p_team_id UUID,
    p_new_captain UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_TRANSFER' USING ERRCODE = '42501';
    END IF;
    IF p_new_captain = v_uid THEN
        RETURN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = p_new_captain) THEN
        RAISE EXCEPTION 'NEW_CAPTAIN_MUST_BE_MEMBER' USING ERRCODE = 'P0001';
    END IF;
    IF public.team_has_active_registration(p_team_id) THEN
        RAISE EXCEPTION 'TEAM_HAS_ACTIVE_REGISTRATION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.teams SET owner_id = p_new_captain, captain_id = p_new_captain
    WHERE id = p_team_id;

    UPDATE public.team_members SET role = 'member'
    WHERE team_id = p_team_id AND user_id = v_uid;
    UPDATE public.team_members SET role = 'owner'
    WHERE team_id = p_team_id AND user_id = p_new_captain;

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (p_team_id, v_uid, 'captain_transferred', p_new_captain);

    PERFORM public.log_audit(v_uid, 'team.captain_transferred', 'team', p_team_id,
        jsonb_build_object('captain_id', v_uid), jsonb_build_object('captain_id', p_new_captain));
END;
$$;

CREATE OR REPLACE FUNCTION public.leave_team(p_team_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_other_members INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = v_uid) THEN
        RAISE EXCEPTION 'NOT_TEAM_MEMBER' USING ERRCODE = 'P0002';
    END IF;

    SELECT count(*) INTO v_other_members FROM public.team_members
    WHERE team_id = p_team_id AND user_id <> v_uid;

    IF public.is_team_captain(p_team_id, v_uid) AND v_other_members > 0 THEN
        RAISE EXCEPTION 'TRANSFER_CAPTAINCY_REQUIRED' USING ERRCODE = 'P0001';
    END IF;
    IF public.team_has_active_registration(p_team_id) THEN
        RAISE EXCEPTION 'TEAM_HAS_ACTIVE_REGISTRATION' USING ERRCODE = 'P0001';
    END IF;

    DELETE FROM public.team_members WHERE team_id = p_team_id AND user_id = v_uid;

    IF v_other_members = 0 THEN
        UPDATE public.teams SET deleted_at = NOW() WHERE id = p_team_id;
        INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
        VALUES (p_team_id, v_uid, 'team_dissolved', v_uid);
    ELSE
        INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
        VALUES (p_team_id, v_uid, 'member_left', v_uid);
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.remove_team_member(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.transfer_team_captaincy(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.leave_team(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.remove_team_member(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.transfer_team_captaincy(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_team(UUID) TO authenticated;

-- ============================================
-- 4. Allow roster participants to read the full roster snapshot
-- ============================================
-- The current policy only allows users to see their own row in
-- tournament_entry_members. A participant should be able to see the
-- complete roster of their entry, including the captain and other members.
-- This is safe because all users in the entry are already mutually known
-- (they're on the same team/registration).
--
-- To avoid any RLS circularity, use a SECURITY DEFINER helper that
-- checks entry membership without triggering tournament_entry_members RLS.
DROP POLICY IF EXISTS "Entry members can read own entry" ON public.tournament_entry_members;

CREATE OR REPLACE FUNCTION public.is_entry_participant(
    p_entry_id UUID,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = p_entry_id AND user_id = p_user_id
    );
$$;

REVOKE ALL ON FUNCTION public.is_entry_participant(UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_entry_participant(UUID, UUID) TO authenticated;

CREATE POLICY "Entry members can read own entry"
    ON public.tournament_entry_members FOR SELECT
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.id = tournament_entry_members.entry_id
              AND r.user_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.tournaments t
            WHERE t.id = tournament_entry_members.tournament_id
              AND t.organizer_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.tournament_organizers o
            WHERE o.tournament_id = tournament_entry_members.tournament_id
              AND o.user_id = auth.uid()
        )
        OR public.is_entry_participant(tournament_entry_members.entry_id)
    );

-- ============================================
-- 6. Break the circular policy dependency between teams and team_members
-- ============================================
-- The "Team members can read" policy on teams queries team_members,
-- which triggers team_members policies, which includes a policy that
-- queries teams, creating infinite recursion.
-- Fix by rewriting the teams policy to check ownership/captaincy directly.
DROP POLICY IF EXISTS "Team members can read" ON public.teams;
CREATE POLICY "Team members can read"
    ON public.teams FOR SELECT
    USING (
        is_public = true AND deleted_at IS NULL
        OR owner_id = auth.uid()
        OR captain_id = auth.uid()
    );

-- ============================================
-- 7. Rewrite team_members "Team members can read" to avoid any
--    residual circularity with teams policies.
-- ============================================
-- The original team_members policy checked team visibility via teams.is_public,
-- which required querying the teams table. While the new teams policy above
-- no longer queries team_members, we align both policies for consistency
-- and to prevent any future circularity if teams policies change.
DROP POLICY IF EXISTS "Team members can read" ON public.team_members;
CREATE POLICY "Team members can read"
    ON public.team_members FOR SELECT
    USING (
        auth.uid() = user_id
        OR EXISTS (
            SELECT 1 FROM public.teams t
            WHERE t.id = team_members.team_id
              AND (t.is_public = true AND t.deleted_at IS NULL
                   OR t.owner_id = auth.uid()
                   OR t.captain_id = auth.uid())
        )
    );
