-- Migration: 20261108000009_phase4_policy_fixes
-- Phase 4 Policy Fixes
--
-- Fixes:
-- 1. Infinite recursion in team_members RLS policy (Issue from regression)
-- 2. Ensure submit_dispute and other functions are properly exposed to PostgREST

-- ============================================
-- 1. Fix infinite recursion in team_members policy
-- ============================================
-- The "Owner/Captain can manage members" policy on team_members uses a
-- self-referential subquery which causes infinite recursion.
-- Replace with SECURITY DEFINER function approach.

-- Drop the problematic policy
DROP POLICY IF EXISTS "Owner/Captain can manage members" ON public.team_members;

-- Create SECURITY DEFINER function to check team captain/owner status
-- This function already exists from Phase 3: is_team_captain
-- But we need a more general "is_team_staff" function for ALL operations

CREATE OR REPLACE FUNCTION public.is_team_staff(
    p_team_id UUID,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.team_members
        WHERE team_id = p_team_id
          AND user_id = p_user_id
          AND role IN ('owner', 'captain')
    );
$$;

-- Create new policy using the function
CREATE POLICY "Team staff can manage members"
    ON public.team_members FOR ALL
    USING (public.is_team_staff(team_id, auth.uid()))
    WITH CHECK (public.is_team_staff(team_id, auth.uid()));

-- Also fix the team_member_events policy which references team_members
-- The policy "Team members can read team history" references team_members
-- This could also cause recursion. Let's use the function there too.

DROP POLICY IF EXISTS "Team members can read team history" ON public.team_member_events;

CREATE POLICY "Team members can read team history"
    ON public.team_member_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.teams t
            WHERE t.id = team_member_events.team_id
              AND (t.is_public = true OR t.owner_id = auth.uid() OR t.captain_id = auth.uid())
        )
        OR public.is_team_staff(team_member_events.team_id, auth.uid())
    );

-- ============================================
-- 2. Ensure submit_dispute and other functions are properly granted
-- ============================================
-- The submit_dispute function exists but PostgREST may not see it due to cache.
-- Re-grant EXECUTE to force cache refresh.

REVOKE ALL ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) TO authenticated;

-- Also re-grant all Phase 4 functions to ensure they're visible
REVOKE ALL ON FUNCTION public.get_match_credentials(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_match_credentials(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) TO authenticated;

REVOKE ALL ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) TO authenticated;

REVOKE ALL ON FUNCTION public.finalize_match_results(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.finalize_match_results(UUID) TO authenticated;

-- ============================================
-- 3. Notify PostgREST to reload schema
-- ============================================
-- This will be done by the test script via pg_notify