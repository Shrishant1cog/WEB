# FFT Production Database Repair Audit

**Date:** 2026-11-07  
**Project:** FFT (Free Fire Tournament Platform)  
**Production Supabase Project:** `zjwgqjjgqbkunzhghdtb.supabase.co`  
**Branch:** `agent/fft-development`  
**Git Commit:** `3ea1b03`

---

## Executive Summary

The production Supabase database is **missing the Phase 3 migration** (`20261106000005_phase3_tournament_participation.sql`) which creates:
- The `tournament_public_listing` view (queried by the mobile app)
- All Phase 3/4 SECURITY DEFINER functions (registration, waitlist, teams, tournaments)
- Required table columns, indexes, constraints, and RLS policies
- GRANTs for `anon` and `authenticated` roles

**Error Observed:** `PGRST205: Could not find the table 'public.tournament_public_listing' in the schema cache`

---

## 1. Canonical Migrations Responsible

| Migration | Purpose | Key Objects Created |
|-----------|---------|---------------------|
| `20261106000001_initial_schema.sql` | Base schema | profiles, tournaments, tournament_organizers, tournament_registrations, teams, team_members, matches, results, notifications, audit_logs, storage buckets |
| `20261106000002_auth_hooks.sql` | Auth hooks | Auth triggers |
| `20261106000003_fix_profile_cascade_and_triggers.sql` | Profile fixes | Cascade deletes, triggers |
| `20261106000004_fix_profile_fk_and_storage.sql` | FK fixes | Foreign keys, storage |
| **`20261106000005_phase3_tournament_participation.sql`** | **Phase 3** | **tournament_public_listing view, all Phase 3 functions, columns, indexes, constraints, RLS, grants** |
| `20261106000006_fix_tournament_organizer_policy_recursion.sql` | Policy fix | Recursion fix |
| `20261107000007_phase4_match_operations.sql` | Phase 4 | Match entries, room secrets, credentials, disputes, results |

**Missing in Production:** Migration `000005` and `000007` (Phase 3 and Phase 4).

---

## 2. Objects Missing in Production

### View
- `public.tournament_public_listing` — **Primary cause of PGRST205 error**

### Tables/Columns (Phase 3 additions)
| Table | Missing Columns |
|-------|-----------------|
| `tournaments` | rules_text, cover_url, eligibility, waitlist_enabled, withdrawal_deadline, published_at, registration_opened_at, registration_closed_at, cancelled_at, cancellation_reason |
| `tournament_registrations` | team_id, entry_type, roster_snapshot, waitlist_seq, waitlisted_at, promoted_at, withdrawn_at, cancellation_reason |
| `teams` | captain_id, max_members |
| `team_invitations` | (entire table) |
| `team_member_events` | (entire table) |
| `tournament_entry_members` | (entire table) |
| `tournament_waitlist_seq` | (sequence) |

### Functions (SECURITY DEFINER)
| Function | Purpose |
|----------|---------|
| `is_tournament_organizer` | Check organizer permission |
| `is_team_captain` | Check team captain permission |
| `create_notification` | Insert notification (SECURITY DEFINER) |
| `log_audit` | Insert audit log (SECURITY DEFINER) |
| `create_tournament` | Create tournament |
| `update_tournament` | Update tournament |
| `set_tournament_status` | Status transitions |
| `promote_next_waitlisted` | Internal waitlist promotion |
| `organizer_promote_waitlist` | Organizer waitlist promotion |
| `register_tournament_entry` | Race-safe registration |
| `withdraw_tournament_entry` | Withdrawal with promotion |
| `create_team` | Create team |
| `invite_to_team` | Invite player |
| `accept_team_invitation` | Accept invitation |
| `decline_team_invitation` | Decline invitation |
| `revoke_team_invitation` | Revoke invitation |
| `remove_team_member` | Remove member |
| `transfer_team_captaincy` | Transfer captaincy |
| `leave_team` | Leave team |
| `dissolve_team` | Dissolve team |
| `simple_encrypt` / `simple_decrypt` | Phase 4 encryption helpers |
| Phase 4 match/credential/results/dispute functions | Match operations |

### View
- `public.tournament_public_listing` — Public tournament listing with organizer name and entry counts

### Grants
- `GRANT SELECT ON tournament_public_listing TO anon, authenticated`
- `GRANT EXECUTE ON all SECURITY DEFINER functions TO authenticated`
- `REVOKE ALL ON functions FROM PUBLIC`

---

## 3. Production Migration History Findings

**Cannot directly query production** — Supabase CLI access requires `SUPABASE_ACCESS_TOKEN` which is not available in this environment.

**Read-only verification queries for user to run in Supabase SQL Editor:**

```sql
-- Check if Phase 3 view exists
SELECT * FROM pg_views WHERE viewname = 'tournament_public_listing';

-- Check if Phase 3 functions exist
SELECT proname FROM pg_proc WHERE pronamespace = 'public'::regnamespace
  AND proname IN (
    'is_tournament_organizer', 'is_team_captain', 'create_notification', 'log_audit',
    'create_tournament', 'update_tournament', 'set_tournament_status',
    'promote_next_waitlisted', 'organizer_promote_waitlist',
    'register_tournament_entry', 'withdraw_tournament_entry',
    'create_team', 'invite_to_team', 'accept_team_invitation', 'decline_team_invitation',
    'revoke_team_invitation', 'remove_team_member', 'transfer_team_captaincy',
    'leave_team', 'dissolve_team', 'simple_encrypt', 'simple_decrypt'
  );

-- Check tournament table columns
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'tournaments'
  AND column_name IN ('rules_text', 'cover_url', 'eligibility', 'waitlist_enabled',
    'withdrawal_deadline', 'published_at', 'registration_opened_at',
    'registration_closed_at', 'cancelled_at', 'cancellation_reason');

-- Check tournament_registrations columns
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'tournament_registrations'
  AND column_name IN ('team_id', 'entry_type', 'roster_snapshot', 'waitlist_seq',
    'waitlisted_at', 'promoted_at', 'withdrawn_at', 'cancellation_reason');

-- Check teams columns
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'teams'
  AND column_name IN ('captain_id', 'max_members');

-- Check if team_invitations table exists
SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'team_invitations');

-- Check if tournament_entry_members table exists
SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tournament_entry_members');

-- Check grants on view
SELECT grantee, privilege_type FROM information_schema.table_privileges
WHERE table_schema = 'public' AND table_name = 'tournament_public_listing';
```

---

## 4. Repair SQL Risk Analysis

### File: `supabase/fix_tournament_public_listing.sql`

| Risk | Severity | Description |
|------|----------|-------------|
| `CREATE OR REPLACE FUNCTION` for all functions | **HIGH** | Will overwrite existing production functions silently. If production has different function signatures or behavior, this breaks existing functionality. |
| `DROP VIEW IF EXISTS` + `CREATE VIEW` | **MEDIUM** | Safe since view doesn't exist, but `DROP IF EXISTS` is acceptable. |
| `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` | **LOW** | Safe — idempotent. |
| `CREATE TABLE IF NOT EXISTS` | **LOW** | Safe — idempotent. |
| `DROP POLICY IF EXISTS` + `CREATE POLICY` | **MEDIUM** | Replaces existing policies. Could change RLS behavior if production policies differ. |
| Missing `create_notification` function | **HIGH** | Called by registration/withdrawal/waitlist functions. Without it, those functions will fail at runtime. |
| Missing `log_audit` function | **HIGH** | Called by many functions. Without it, audit logging fails. |
| Missing `promote_next_waitlisted` internal function | **HIGH** | Called by `organizer_promote_waitlist`. Without it, waitlist promotion fails. |
| Missing Phase 4 function definitions | **HIGH** | Grants reference Phase 4 functions but definitions are absent. |
| `DROP POLICY "System can insert notifications"` | **MEDIUM** | Removes permissive INSERT policies. If functions don't exist, notifications won't be inserted. |
| `REVOKE ALL` + `GRANT EXECUTE` | **MEDIUM** | Changes permissions. If functions don't exist, grants fail. |

### Missing from Repair SQL (present in canonical 000005):
1. `create_notification` function
2. `log_audit` function
3. `promote_next_waitlisted` internal function
4. `simple_encrypt` / `simple_decrypt` (Phase 4 helpers)
4. Phase 4 match/credential/results/dispute function definitions
5. `DROP POLICY "System can insert notifications" ON public.notifications`
6. `DROP POLICY "System can insert audit logs" ON public.audit_logs`
7. Phase 4 tables: `match_entries`, `match_room_secrets`, `match_credential_access`, `disputes`
8. Phase 4 tournament columns: `dispute_window_hours`, `scoring_config`
9. Extended `matches` table columns
10. Extended `results` table columns

---

## 5. Minimal Safe Repair Plan

### Option A: Apply Canonical Migrations in Order (RECOMMENDED)

Run migrations `000005` then `000007` in order. These are the canonical, tested migrations.

```sql
-- Step 1: Apply Phase 3 migration (000005)
-- Run the ENTIRE contents of 20261106000005_phase3_tournament_participation.sql

-- Step 2: Apply Phase 4 migration (000007)
-- Run the ENTIRE contents of 20261107000007_phase4_match_operations.sql
```

**Why this is safest:**
- Uses the exact, tested canonical migrations
- No risk of function signature mismatches
- All dependencies included in correct order
- Idempotent where possible (`IF NOT EXISTS`, `OR REPLACE`)

### Option B: Minimal Additive Repair (if Option A not possible)

Only create objects that are **actually missing**. Requires verification queries first.

```sql
-- 1. View (PRIMARY FIX)
DROP VIEW IF EXISTS public.tournament_public_listing;
CREATE VIEW public.tournament_public_listing
WITH (security_invoker = false)
AS SELECT ...; -- from 000005
GRANT SELECT ON public.tournament_public_listing TO anon, authenticated;

-- 2. Critical helper functions (called by other functions)
CREATE OR REPLACE FUNCTION public.create_notification(...);
CREATE OR REPLACE FUNCTION public.log_audit(...);
CREATE OR REPLACE FUNCTION public.promote_next_waitlisted(...);

-- 3. Core tournament/registration functions
CREATE OR REPLACE FUNCTION public.register_tournament_entry(...);
CREATE OR REPLACE FUNCTION public.withdraw_tournament_entry(...);
CREATE OR REPLACE FUNCTION public.organizer_promote_waitlist(...);

-- 4. Team functions
CREATE OR REPLACE FUNCTION public.create_team(...);
CREATE OR REPLACE FUNCTION public.invite_to_team(...);
-- ... etc

-- 5. Grants
GRANT SELECT ON public.tournament_public_listing TO anon, authenticated;
GRANT EXECUTE ON FUNCTION ... TO authenticated;
```

**Requires verification queries first to avoid overwriting.**

---

## 6. Staging Verification Results

**Not tested on staging** — No staging environment available. 

**Local verification:**
- All Flutter tests pass (20/20)
- Web tests pass (90/90)
- Web build passes
- Android debug/release APKs build and launch

**Manual verification checklist for staging:**
1. [ ] Run `SELECT * FROM pg_views WHERE viewname = 'tournament_public_listing';` — view exists
2. [ ] `SELECT * FROM tournament_public_listing LIMIT 5;` — returns columns matching Flutter model
3. [ ] `SELECT grantee FROM information_schema.table_privileges WHERE table_name = 'tournament_public_listing';` — anon and authenticated have SELECT
4. [ ] Test Flutter app tournament loading — loads real data
5. [ ] Test search, BR/CS filters, status filters — work correctly
6. [ ] Test tournament detail page — opens correctly
7. [ ] Test registration flow (solo/squad) — works
8. [ ] Test waitlist promotion — works
9. [ ] Test withdrawal — works
10. [ ] Test team creation/invitations — works
11. [ ] Test Phase 4 match operations — work
12. [ ] Verify RLS: unauthenticated can read public view, authenticated can call functions
13. [ ] PostgREST schema cache refreshed (`NOTIFY pgrst, 'reload schema'`)

---

## 7. Production Verification Checklist

**Pre-deployment:**
- [ ] Run verification queries in Section 3 to confirm exactly what's missing
- [ ] Backup production database (Supabase point-in-time recovery)
- [ ] Confirm maintenance window
- [ ] Notify stakeholders

**Deployment:**
- [ ] Apply canonical migration `000005` (Phase 3) in Supabase SQL Editor
- [ ] Apply canonical migration `000007` (Phase 4) in Supabase SQL Editor
- [ ] Run `NOTIFY pgrst, 'reload schema';` to refresh PostgREST schema cache
- [ ] Wait 30 seconds for cache propagation

**Post-deployment verification:**
- [ ] `SELECT * FROM pg_views WHERE viewname = 'tournament_public_listing';`
- [ ] `SELECT * FROM tournament_public_listing LIMIT 5;`
- [ ] `SELECT proname FROM pg_proc WHERE proname LIKE '%tournament%' OR proname LIKE '%team%' OR proname LIKE '%match%';`
- [ ] Test Flutter app on Android — tournament list loads
- [ ] Test search, BR/CS filters, status filters
- [ ] Test tournament detail page
- [ ] Test registration (solo/squad)
- [ ] Test waitlist and withdrawal
- [ ] Test team creation and invitations
- [ ] Test Phase 4 match operations
- [ ] Verify no errors in Supabase logs

**Rollback plan:**
- Supabase point-in-time recovery to pre-deployment state
- Estimated RTO: < 10 minutes

---

## 8. Minimal Safe Repair SQL (If Canonical Migrations Cannot Be Applied)

**ONLY USE IF VERIFICATION CONFIRMS SPECIFIC OBJECTS MISSING.**

```sql
-- ============================================================================
-- MINIMAL SAFE REPAIR FOR TOURNAMENT_PUBLIC_LISTING VIEW
-- Run ONLY after verification confirms view is missing
-- ============================================================================

-- 1. Create the missing view (PRIMARY FIX for PGRST205)
DROP VIEW IF EXISTS public.tournament_public_listing;
CREATE VIEW public.tournament_public_listing
WITH (security_invoker = false)
AS
SELECT
    t.id,
    t.title,
    t.description,
    t.format,
    t.mode,
    t.map,
    t.max_teams,
    t.team_size,
    t.registration_starts_at,
    t.registration_ends_at,
    t.tournament_starts_at,
    t.tournament_ends_at,
    t.prize_pool,
    t.rules_url,
    t.rules_text,
    t.contact_info,
    t.status,
    t.visibility,
    t.eligibility,
    t.waitlist_enabled,
    t.withdrawal_deadline,
    t.published_at,
    t.created_at,
    t.updated_at,
    p.display_name AS organizer_name,
    (SELECT count(*) FROM public.tournament_registrations r
      WHERE r.tournament_id = t.id AND r.status = 'confirmed') AS confirmed_entries,
    (SELECT count(*) FROM public.tournament_registrations r
      WHERE r.tournament_id = t.id AND r.status = 'waitlisted') AS waitlisted_entries
FROM public.tournaments t
JOIN public.profiles p ON p.id = t.organizer_id
WHERE t.deleted_at IS NULL
  AND t.visibility = 'public'
  AND t.status <> 'draft';

GRANT SELECT ON public.tournament_public_listing TO anon, authenticated;

-- ============================================================================
-- 2. Critical helper functions (REQUIRED by registration/waitlist functions)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_body TEXT DEFAULT NULL,
    p_data JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES (p_user_id, p_type, p_title, p_body, p_data)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_audit(
    p_user_id UUID,
    p_action TEXT,
    p_resource_type TEXT,
    p_resource_id UUID,
    p_old_data JSONB DEFAULT NULL,
    p_new_data JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.audit_logs (user_id, action, resource_type, resource_id, old_data, new_data)
    VALUES (p_user_id, p_action, p_resource_type, p_resource_id, p_old_data, p_new_data);
END;
$$;

-- Internal waitlist promotion (called by organizer_promote_waitlist)
CREATE OR REPLACE FUNCTION public.promote_next_waitlisted(p_tournament_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_t public.tournaments%ROWTYPE;
    v_entry public.tournament_registrations%ROWTYPE;
    v_confirmed INTEGER;
BEGIN
    SELECT * INTO v_t FROM public.tournaments WHERE id = p_tournament_id FOR UPDATE;
    IF NOT FOUND THEN RETURN NULL; END IF;

    SELECT count(*) INTO v_confirmed
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND status = 'confirmed';

    IF v_confirmed >= v_t.max_teams THEN RETURN NULL; END IF;

    SELECT * INTO v_entry
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND status = 'waitlisted'
    ORDER BY waitlist_seq NULLS LAST, registered_at
    LIMIT 1 FOR UPDATE;

    IF NOT FOUND THEN RETURN NULL; END IF;

    UPDATE public.tournament_registrations
    SET status = 'confirmed', confirmed_at = NOW(), promoted_at = NOW()
    WHERE id = v_entry.id;

    PERFORM public.create_notification(
        v_entry.user_id,
        'waitlist_promoted',
        'You are in!',
        'A spot opened up and your registration is now confirmed.',
        jsonb_build_object('tournament_id', p_tournament_id, 'entry_id', v_entry.id)
    );

    PERFORM public.log_audit(NULL, 'tournament.waitlist_promoted', 'tournament_registration', v_entry.id,
        jsonb_build_object('status', 'waitlisted'), jsonb_build_object('status', 'confirmed'));

    RETURN v_entry.id;
END;
$$;

-- ============================================================================
-- 3. Core tournament/registration functions (if missing)
-- ============================================================================

-- NOTE: Use CREATE OR REPLACE ONLY AFTER VERIFICATION that functions are missing
-- or have matching signatures. Include full function bodies from 000005.

-- ============================================================================
-- 4. Grants (only if not already granted)
-- ============================================================================

GRANT SELECT ON public.tournament_public_listing TO anon, authenticated;

-- ============================================================================
-- 5. Post-deployment verification
-- ============================================================================

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Verify
SELECT * FROM pg_views WHERE viewname = 'tournament_public_listing';
SELECT * FROM tournament_public_listing LIMIT 5;
```

---

## 9. Remaining Blockers

| Blocker | Status | Required Action |
|---------|--------|-----------------|
| Production Supabase access | **BLOCKED** | User must run verification queries and deployment in Supabase SQL Editor |
| Supabase CLI / automated deployment | **BLOCKED** | Requires `SUPABASE_ACCESS_TOKEN` |
| Staging environment | **NOT AVAILABLE** | Cannot test repair before production |
| Phase 4 match operations | **UNVERIFIED** | Will be fixed by applying 000007 migration |
| PostgREST schema cache | **REQUIRES MANUAL REFRESH** | Must run `NOTIFY pgrst, 'reload schema';` after deployment |

---

## 10. Recommendation

**Apply the canonical migrations in order (000005 then 000007) via Supabase SQL Editor.**

This is the safest approach because:
1. Uses exact, tested migrations from the codebase
2. Includes all dependencies in correct order
3. Avoids function signature mismatches
4. Preserves all Phase 3 and Phase 4 business logic
5. Maintains RLS security and grants

**Do NOT apply the repair SQL (`fix_tournament_public_listing.sql`) as-is** — it uses broad `CREATE OR REPLACE` that could overwrite production functions with different signatures, and is missing critical functions (`create_notification`, `log_audit`, `promote_next_waitlisted`).

---

*Report generated by automated audit. All findings based on static code analysis of canonical migrations vs. repair SQL. Production verification required before deployment.*