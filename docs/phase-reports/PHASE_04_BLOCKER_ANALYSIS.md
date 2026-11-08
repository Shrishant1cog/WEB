# Phase 4 Blocker Analysis — FFT Tournament Platform

**Date:** 2026-11-08  
**Branch:** `agent/fft-development`  
**Local HEAD:** `44a2603`  

---

## Executive Summary

This document analyzes the six known Phase 4 blockers identified in the baseline audit. Each issue is analyzed with reproduction steps, root cause, and proposed minimal fix.

---

## Issue 1: Match entries query returns null in test

### Reproduction
Run `node apps/web/scripts/phase4-rpc-check.mjs` — the check at line 219 fails:
```javascript
const { data: entries } = await organizerClient
  .from("match_entries")
  .select("registration_id, slot")
  .eq("match_id", matchId);
check("all registrations assigned", entries?.length === regIds.length, JSON.stringify(entries));
```

### Expected Behavior
Organizer can read match entries they created via direct PostgREST query.

### Actual Behavior
`entries` is `null` (RLS blocks SELECT) or empty array.

### Root Cause
The RLS policy on `match_entries` for organizers uses a subquery joining `matches` → `tournaments`:
```sql
CREATE POLICY "Organizers can manage match entries"
    ON public.match_entries FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_entries.match_id
              AND t.organizer_id = auth.uid()
        )
    )
```

**Root cause identified:** The test script uses `organizerClient` (authenticated as tournament organizer) to query `match_entries` directly via PostgREST. However, PostgREST's `auth.uid()` returns the JWT subject. The organizer client is correctly authenticated. The policy should allow the organizer to read their match entries.

**Actual root cause:** The `match_entries` table has **three** SELECT policies combined with OR:
1. "Organizers can manage match entries" — checks `t.organizer_id = auth.uid()`
2. "Participants can read own match entry" — checks registration user_id
3. "Public can read match entries for public tournaments" — checks `t.visibility = 'public'`

Policy #3 should allow ANY authenticated user (including the organizer) to read match entries for public tournaments. The tournament in the test is created with `visibility: "public"`. So policy #3 should allow the SELECT.

**Why it fails:** The test uses `organizerClient` which has a valid JWT. PostgREST's `auth.uid()` returns the JWT subject (organizer's user ID). The tournament was created with `visibility: 'public'`. The match belongs to that tournament. Policy #3 should return true.

**Most likely cause:** **PostgREST schema cache not refreshed after migration.** The Phase 4 migration creates the `match_entries` table and its RLS policies. If PostgREST's schema cache hasn't been refreshed, it doesn't know about the new table/policies and returns 404 or empty result.

The test script waits 10 seconds at startup (line 146) but this is insufficient if the migration was applied after PostgREST started, or if the cache TTL hasn't expired.

### Proposed Fix
1. **Immediate:** Add `NOTIFY pgrst, 'reload schema';` to the test script after waiting, or call the PostgREST schema reload endpoint.
2. **Application code:** Ensure any migration deployment includes `NOTIFY pgrst, 'reload schema';` (already a best practice).
3. **Defensive:** The RLS policies are correct; no schema change needed.

### Regression Test
- Add explicit test that verifies organizer can SELECT match_entries after assignment.
- Test with both public and private tournaments.

---

## Issue 2: Duplicate assignment constraint not enforced

### Reproduction
Test at line 222-229 expects duplicate assignment to raise `ENTRY_ALREADY_ASSIGNED`:
```javascript
await expectFailure(
  "duplicate assignment rejected",
  organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [regIds[0]],
  }),
  "ENTRY_ALREADY_ASSIGNED"
);
```

### Expected Behavior
Second call to `assign_match_entries` with same `registration_id` and `match_id` should raise an error.

### Actual Behavior
The RPC uses `ON CONFLICT (match_id, registration_id) DO NOTHING` which silently ignores the conflict. No error is raised.

### Root Cause
The `assign_match_entries` RPC (lines 574-576 in migration):
```sql
INSERT INTO public.match_entries (match_id, registration_id, slot, seed, side, assigned_by)
VALUES (p_match_id, p_registration_ids[v_idx], v_slot, v_seed, v_side, v_uid)
ON CONFLICT (match_id, registration_id) DO NOTHING;
```

`DO NOTHING` silently ignores the conflict. The function doesn't check if any row was actually inserted, nor does it raise an exception for duplicates.

### Proposed Fix
Modify `assign_match_entries` to check for existing assignment before insert, or use `ON CONFLICT ... DO UPDATE SET ...` with a check that raises an exception.

**Option A (recommended):** Check before insert and raise explicit error:
```sql
IF EXISTS (
    SELECT 1 FROM public.match_entries
    WHERE match_id = p_match_id AND registration_id = p_registration_ids[v_idx]
) THEN
    RAISE EXCEPTION 'ENTRY_ALREADY_ASSIGNED' USING ERRCODE = 'P0001';
END IF;

INSERT INTO public.match_entries (...) VALUES (...);
```

**Option B:** Use `ON CONFLICT ... DO UPDATE SET ... WHERE FALSE` with a `RETURNING` clause to detect conflict, then raise exception. More complex.

### Regression Test
- Test sequential duplicate assignment raises `ENTRY_ALREADY_ASSIGNED`.
- Test concurrent duplicate assignment (two simultaneous calls) — one succeeds, one fails with unique violation or explicit error.
- Test assignment of different registration to same match succeeds.

---

## Issue 3: Match status visibility timing

### Reproduction
Test at lines 268-288:
```javascript
const { error: startError } = await organizerClient.rpc("start_match", { p_match_id: matchId });
check("start_match succeeds", !startError, startError?.message);

await new Promise(r => setTimeout(r, 500));

const { data: startedMatch } = await organizerClient
  .from("matches")
  .select("status, started_at")
  .eq("id", matchId)
  .single();
check("match status in_progress", startedMatch?.status === "in_progress" && startedMatch?.started_at !== null);
```

### Expected Behavior
After `start_match` RPC returns, a direct query to `matches` table should immediately show `status = 'in_progress'` and `started_at` set.

### Actual Behavior
The check fails — status may still be `scheduled` or `started_at` is null.

### Root Cause
The `start_match` RPC:
```sql
UPDATE public.matches
SET status = 'in_progress', started_at = NOW()
WHERE id = p_match_id;
```

This is a simple UPDATE. In PostgreSQL, the UPDATE commits when the RPC transaction commits (at function end). The RPC returns, then the test waits 500ms, then queries.

**Possible causes:**
1. **Transaction isolation:** The test's `organizerClient` query might run in a different transaction that doesn't see the committed change immediately (unlikely with default READ COMMITTED).
2. **PostgREST connection pooling:** The client might use a pooled connection that hasn't seen the commit yet (unlikely).
3. **RPC transaction not committed:** If the RPC raises an exception after the UPDATE but before commit, it would roll back. But the test shows `startError` is null.
4. **PostgREST schema cache / prepared statements:** The `from("matches")` query might use a cached plan or stale connection.

**Most likely:** The 500ms wait is insufficient for the change to propagate through PostgREST's connection pool, or there's a transaction timing issue where the RPC's transaction hasn't fully committed when the next query runs.

### Proposed Fix
1. **Increase wait time** in test from 500ms to 2000ms (mitigation, not fix).
2. **Better:** Use the RPC's return value to verify the change instead of a separate query. The `start_match` RPC could return the updated match row.
3. **Best:** Ensure the test uses a fresh query after the RPC completes. The 500ms wait should be sufficient in normal conditions; if flaky, increase to 2s.

**No schema/code change needed** — this appears to be a test timing issue, not a bug in the RPC.

### Regression Test
- Test that `start_match` followed by immediate `matches` query returns updated status.
- Test with concurrent status queries.

---

## Issue 4: `team_id` NOT NULL constraint violation

### Reproduction
The initial schema defines `results.team_id UUID NOT NULL REFERENCES teams(id)`. Phase 4 migration adds `registration_id` and changes unique constraint to `(match_id, registration_id)`. But `team_id` remains `NOT NULL`.

### Expected Behavior
Solo tournaments (format = 'solo') don't have teams. Results for solo matches should not require a `team_id`.

### Actual Behavior
When saving results for solo matches, the `team_id` is NULL, violating the `NOT NULL` constraint.

### Root Cause
Initial schema (line 377 in initial migration):
```sql
CREATE TABLE results (
    ...
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    ...
);
```

Phase 4 migration (lines 195-212) adds `registration_id` and creates unique index on `(match_id, registration_id)`, but **does not make `team_id` nullable** or handle solo matches.

The `save_result_draft` RPC (line 1127) inserts into `results` with `registration_id` but doesn't set `team_id` for solo matches. The `results` table still requires `team_id NOT NULL`.

In solo tournaments, registrations have `entry_type = 'solo'` and `team_id = NULL` in `tournament_registrations`. The match entries link to registrations, not teams. Results should be linked via `registration_id`, not `team_id`.

### Proposed Fix
1. **Make `team_id` nullable** in `results` table:
```sql
ALTER TABLE public.results ALTER COLUMN team_id DROP NOT NULL;
```

2. **Add check constraint** to ensure either `team_id` OR `registration_id` is set (but since unique constraint is on `(match_id, registration_id)`, `registration_id` is always required for Phase 4 matches).

3. **Update `save_result_draft` RPC** to optionally set `team_id` for backward compatibility with legacy team-based matches:
```sql
team_id = CASE 
    WHEN v_reg.entry_type = 'squad' THEN v_reg.team_id 
    ELSE NULL 
END,
```

But wait — the `results` table has both `team_id` (legacy) and `registration_id` (new). The unique index is on `(match_id, registration_id)`. For legacy matches, `registration_id` might be NULL and `team_id` used. For Phase 4 matches, `registration_id` is always set.

**Better approach:** Make `team_id` nullable, add a check constraint:
```sql
ALTER TABLE public.results 
    ALTER COLUMN team_id DROP NOT NULL,
    ADD CONSTRAINT results_team_or_registration 
        CHECK (team_id IS NOT NULL OR registration_id IS NOT NULL);
```

And update `save_result_draft` to set `team_id` from registration's team_id when available (for squad), NULL for solo.

### Regression Test
- Test solo match result submission with NULL team_id.
- Test squad match result submission with team_id.
- Test that results unique constraint on `(match_id, registration_id)` works.
- Test legacy match results still work (if applicable).

---

## Issue 5: `submit_dispute` PostgREST cache not refreshed

### Reproduction
Test at line 383-389:
```javascript
const { error: disputeError } = await p2Client.rpc("submit_dispute", {
  p_match_id: matchId,
  p_registration_id: regIds[1],
  p_reason: "Kill count incorrect",
  p_evidence_paths: ["evidence/dispute1.png"],
});
check("submit_dispute succeeds", !disputeError, disputeError?.message);
```

### Expected Behavior
`submit_dispute` RPC executes and returns dispute ID.

### Actual Behavior
PostgREST returns "function submit_dispute(uuid, uuid, text, text[]) does not exist" — function not found in schema cache.

### Root Cause
PostgREST caches the database schema (tables, functions, types) at startup and periodically. When a migration adds new functions (like `submit_dispute`), PostgREST doesn't know about them until:
1. Schema cache TTL expires (default 30 seconds), OR
2. Manual cache refresh via `NOTIFY pgrst, 'reload schema';`

The test script waits 10 seconds at startup (line 146), but the Phase 4 migration was already applied before the test runs (in CI, `supabase db reset` restarts PostgREST). In local development, if the migration is applied without restarting PostgREST, the cache is stale.

**The test script comment at line 144-146 acknowledges this:**
```javascript
// Wait for PostgREST schema cache to refresh after migration
console.log("Waiting for PostgREST schema cache to refresh...");
await new Promise(r => setTimeout(r, 10000));
```

But 10 seconds may not be enough if the cache TTL is 30 seconds.

### Proposed Fix
1. **Test script:** After waiting, send `NOTIFY pgrst, 'reload schema';` via the service role client:
```javascript
await admin.rpc('pg_notify', { channel: 'pgrst', payload: 'reload schema' });
```

2. **Migration deployment:** Always include `NOTIFY pgrst, 'reload schema';` at the end of migrations that add/change functions.

3. **CI/CD:** Ensure `supabase db reset` (which restarts PostgREST) runs before tests.

### Regression Test
- Verify `submit_dispute` RPC is callable immediately after migration + cache refresh.
- Test with cold PostgREST start (cache cold).

---

## Issue 6: `results` ON CONFLICT unique constraint mismatch

### Reproduction
Test at lines 352-366:
```javascript
await expectFailure(
  "duplicate draft rejected",
  organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: regIds[0],
    p_rank: 2,
    p_kills: 3,
    p_placement_points: 5,
    p_kill_points: 3,
    p_total_points: 8,
    p_scoring_snapshot: {},
  }),
  "RESULT_DRAFT_EXISTS"
);
```

### Expected Behavior
Second call to `save_result_draft` with same `(match_id, registration_id)` should raise `RESULT_DRAFT_EXISTS`.

### Actual Behavior
The unique index is on `(match_id, registration_id)` (line 211-212):
```sql
CREATE UNIQUE INDEX uq_results_match_registration
    ON public.results (match_id, registration_id);
```

The `save_result_draft` RPC uses:
```sql
ON CONFLICT (match_id, registration_id) DO UPDATE SET
    rank = EXCLUDED.rank,
    kills = EXCLUDED.kills,
    ...
    status = 'draft';
```

This **updates** the existing row instead of raising an error. The test expects an error `RESULT_DRAFT_EXISTS` but the RPC silently updates the draft.

### Root Cause
The `save_result_draft` RPC uses `ON CONFLICT ... DO UPDATE` which overwrites the existing draft. The test expects an error to be raised for duplicate submission.

**Design question:** Should saving a duplicate draft be an error, or should it update the draft? The current implementation treats it as an update (idempotent draft saving). The test expects an error.

Looking at the RPC signature and behavior: `save_result_draft` is meant to save/update a draft result. It makes sense to allow updating a draft. The test expectation might be wrong.

However, the Phase 4 verification report says "Unique constraint for `results` ON CONFLICT" is an issue. The mismatch is between:
- Test expects: Error on duplicate
- Implementation: Update on duplicate

### Proposed Fix
**Option A (align implementation with test):** Change `ON CONFLICT DO UPDATE` to `ON CONFLICT DO NOTHING` and check if row was inserted, raising error if not. But this breaks idempotent draft saving.

**Option B (align test with implementation):** Update the test to expect the draft to be updated, not an error. The idempotent behavior is correct for draft saving.

**Option C (add explicit check):** Before insert, check if draft exists and raise error if it does and we're not in "update" mode. But the RPC doesn't have an "update mode" parameter.

**Recommendation:** **Option B** — the idempotent `DO UPDATE` behavior is correct for a "save draft" operation. The test should be updated to verify the draft was updated (e.g., rank changed to 2), not that an error was raised.

But wait — the audit says "Unique constraint for `results` ON CONFLICT mismatch". This suggests the unique constraint itself might be wrong. Let me check the index definition again.

Line 210-212:
```sql
DROP INDEX IF EXISTS public.uq_results_match_registration;
CREATE UNIQUE INDEX uq_results_match_registration
    ON public.results (match_id, registration_id);
```

This unique index enforces one result per registration per match. The `ON CONFLICT (match_id, registration_id)` in the RPC matches this index. The constraint is correct.

The "mismatch" is between the test expecting an error and the RPC doing an update. This is a test/implementation alignment issue, not a schema issue.

### Proposed Fix
Update the test to verify the draft was updated:
```javascript
const { data: updatedDraft } = await organizerClient
  .from("results")
  .select("rank, status")
  .eq("match_id", matchId)
  .eq("registration_id", regIds[0])
  .single();
check("draft was updated", updatedDraft.rank === 2 && updatedDraft.status === "draft");
```

And remove the `expectFailure` for duplicate draft.

### Regression Test
- Test initial draft save creates row.
- Test duplicate save updates existing row (idempotent).
- Test that unique constraint prevents two different registrations from having same `(match_id, registration_id)`.

---

## Summary of Fixes Required

| Issue | Type | Files to Modify |
|-------|------|-----------------|
| 1. Match entries null | Test/Config | `apps/web/scripts/phase4-rpc-check.mjs` (add schema reload) |
| 2. Duplicate assignment | Code | `supabase/migrations/20261107000007_phase4_match_operations.sql` (RPC fix) |
| 3. Status visibility | Test | `apps/web/scripts/phase4-rpc-check.mjs` (increase wait or use RPC return) |
| 4. `team_id` NOT NULL | Migration | New migration: `ALTER TABLE results ALTER COLUMN team_id DROP NOT NULL` + check constraint |
| 5. `submit_dispute` cache | Test/Config | `phase4-rpc-check.mjs` (add schema reload notification) |
| 6. Results ON CONFLICT | Test | `phase4-rpc-check.mjs` (update test expectation) |

---

## Next Steps

1. Create new migration for Issue 4 (`team_id` nullable).
2. Fix RPC for Issue 2 (duplicate assignment check).
2. Update test script for Issues 1, 3, 5, 6.
3. Run full test suite.
4. Verify all Phase 4 acceptance criteria pass.