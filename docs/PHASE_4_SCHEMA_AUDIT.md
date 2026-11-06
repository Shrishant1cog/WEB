# Phase 4 Schema Audit

**Date:** 2026-11-07  
**Branch:** `agent/fft-development`  
**Commit:** `f9682a8`

---

## Executive Summary

The current database schema (migrations 1-6) contains **legacy match/results tables** from the initial schema that are **team-based only** and **do not support** the Phase 3 solo/squad registration model. The Phase 4 documented design expects entry-based results, encrypted room credentials, disputes, and match-entry associations — none of which exist in the applied schema.

**Discrepancy:** The `docs/architecture/DATA_MODEL.md` and `docs/architecture/WORKFLOWS.md` describe a modern schema (`match_room_secrets`, `tournament_results`, `disputes`, entry-based results) that has **not been implemented** in any migration.

---

## Current Applied Schema (Migrations 1-6)

### Migration 1: `20261106000001_initial_schema.sql`

| Table | Status | Key Issue |
|-------|--------|-----------|
| `tournaments` | ✅ Applied | Has `format`, `team_size`, `max_teams`, `visibility`, `eligibility`, `waitlist_enabled` |
| `tournament_organizers` | ✅ Applied | Per-tournament roles (owner, organizer, moderator) |
| `tournament_registrations` | ✅ Applied | Solo/squad entries with `team_members` array, `roster_snapshot`, `status` (confirmed/waitlisted/cancelled) |
| `tournament_entry_members` | ✅ Applied (Mig 5) | Immutable roster snapshots per registration |
| **`matches`** | ✅ Applied | **LEGACY: team-based only** (`team_a_id`, `team_b_id`, `winner_id` all REF teams) |
| **`results`** | ✅ Applied | **LEGACY: team-based only** (`team_id` REF teams) |
| `teams` | ✅ Applied | Has `owner_id`, `captain_id`, `max_members` |
| `team_members` | ✅ Applied | Roles: owner, captain, member |
| `team_invitations` | ✅ Applied (Mig 5) | 32-byte tokens, SHA-256 hash, expiry, rate limit |
| `team_member_events` | ✅ Applied (Mig 5) | Audit trail |
| `audit_logs` | ✅ Applied | With `log_audit` SECURITY DEFINER function |

### Migration 5: `20261106000005_phase3_tournament_participation.sql`

Added (no match-related tables):
- `tournament_entry_members` — roster snapshots
- `team_invitations` — invitations
- `team_member_events` — membership events

### Migration 6: `20261106000006_fix_tournament_organizer_policy_recursion.sql`

Corrective RLS fixes only.

---

## Documented Design vs Actual Schema

| Entity | Documented Design (DATA_MODEL.md / WORKFLOWS.md) | Actual Applied Schema | Migration | Decision |
|--------|--------------------------------------------------|----------------------|-----------|----------|
| `matches` | Modern: `match_id`, `tournament_id`, `round_name`, `match_number`, `status`, `scheduled_at`, `started_at`, `ended_at`, `mode` | Legacy: `team_a_id`, `team_b_id`, `winner_id` (all UUID REF teams) | 1 | **Migrate** — Add entry-based participant model; keep legacy cols for backward compat |
| `results` | Entry-based: `registration_id`, `rank`, `kills`, `placement_points`, `kill_points`, `total_points`, `scoring_rules_version` | Legacy: `team_id` REF teams | 1 | **Migrate** — Add entry-based results; deprecate team_id |
| `match_room_secrets` | Encrypted room_id, room_password, key_version, release_at, released_at | **MISSING** | — | **Create new** |
| `disputes` | `registration_id`, `match_id`, `reason`, `evidence_paths`, `status`, `moderator_id`, `resolution` | **MISSING** | — | **Create new** |
| `tournament_results` | Aggregated standings | **MISSING** | — | **Defer** — Compute from entry-based results; not a separate table |
| `match_entries` (association) | `match_id`, `registration_id`, `slot`, `seed`, `side` | **MISSING** | — | **Create new** |
| `match_credential_access` | Audit of credential retrieval | **MISSING** | — | **Create new** |
| `tournament_rules` | Scoring config per tournament | **MISSING** | — | **Add to tournaments** — Use `tournaments.rules_config` JSONB or similar |
| `dispute_evidence` bucket | Private Storage bucket | **MISSING** | — | **Create in code** |

---

## Key Schema Conflicts to Resolve

### 1. Match Participant Model

**Current (Legacy):**
```sql
matches.team_a_id UUID REFERENCES teams(id)
matches.team_b_id UUID REFERENCES teams(id)
matches.winner_id UUID REFERENCES teams(id)
```
- Only supports 2 teams per match (head-to-head)
- No support for Battle Royale (multiple entries)
- No support for Solo entries

**Required (Phase 4):**
- Many-to-many: `match_entries` linking `matches` ↔ `tournament_registrations`
- Support N entries per match (BR)
- Support 1 entry per match (Solo head-to-head)
- Slot/seed/side assignment

### 2. Results Model

**Current (Legacy):**
```sql
results.team_id UUID REFERENCES teams(id)
```
- One result per team per match
- No solo support
- No immutable roster snapshot linkage

**Required:**
```sql
results.registration_id UUID REFERENCES tournament_registrations(id)
results.rank, results.kills, results.placement_points, results.kill_points, results.total_points
results.scoring_rules_snapshot JSONB
```
- One result per registration per match
- Solo and Squad both supported via registration

### 3. Room Credentials

**Current:** None

**Required:**
- `match_room_secrets` table with encrypted credentials
- Server-side release enforcement (`release_at` timestamp)
- Participant access verification via match_entries + registration status
- Access audit without storing plaintext

### 4. Disputes

**Current:** None

**Required:**
- `disputes` table linked to `registration_id` + `match_id` + `result_id`
- Evidence stored in private Storage bucket
- Moderator assignment via `tournament_organizers` (role: moderator)
- Conflict-of-interest checks
- Append-only resolution history

---

## Migration Plan for Phase 4

### Migration 7: Match Model Reconciliation
1. **Add `match_entries` table** — canonical match↔registration association
2. **Extend `matches` table** — add `mode` (br/cs/tdm), `round_name`, `group_name`, deprecate but keep `team_a_id`/`team_b_id`/`winner_id` for backward compat
3. **Add `match_room_secrets` table** — encrypted credentials with `release_at`, key_version
4. **Add `match_credential_access` table** — audit log for credential retrieval
5. **Extend `results` table** — add `registration_id`, entry-based scoring fields, `scoring_rules_snapshot`; keep `team_id` nullable for migration
5. **Add `disputes` table** — with evidence paths, status, moderator assignment
6. **Add RLS policies** for all new tables
7. **Add trusted RPCs** — `create_match`, `assign_match_entries`, `set_match_credentials`, `get_match_credentials`, `submit_results`, `submit_dispute`, `resolve_dispute`, `finalize_match_results`

### Migration 8: Backfill & Constraints (if needed)
- Backfill `match_entries` from legacy `team_a_id`/`team_b_id` where unambiguous
- Add unique constraints preventing duplicate match-entry assignments
- Add check constraints for valid state transitions

### Migration 9: Cleanup (optional, Phase 5)
- Deprecate legacy `team_a_id`/`team_b_id`/`winner_id`/`team_id` in results
- Add `tournament_rules_config` JSONB column to `tournaments` for scoring config

---

## RLS Policy Review (Current)

| Table | Current Policies | Phase 4 Needs |
|-------|------------------|---------------|
| `matches` | Public readable by tournament participants; Organizers manage | Add: Participant can read if their registration is in match_entries |
| `results` | Public readable by tournament participants; Organizers manage | Add: Participant can read their own result; Provisional hidden from public |
| `match_entries` | **NEW** | Organizer manage; Participant read own; Public read match public info only |
| `match_room_secrets` | **NEW** | No direct SELECT; only via `get_match_credentials` RPC |
| `disputes` | **NEW** | Participant read own; Moderator read assigned; Organizer read tournament; Public none |

---

## Functions Requiring Updates

| Function | Current | Phase 4 Changes |
|----------|---------|-----------------|
| `is_tournament_organizer` | ✅ | Reuse for match management auth |
| `is_team_captain` | ✅ | Reuse where needed |
| `log_audit` | ✅ | Reuse for match/credential/result/dispute audit |
| **NEW** | — | `create_match`, `update_match`, `assign_match_entries`, `remove_match_entry` |
| **NEW** | — | `set_match_credentials`, `get_match_credentials` (with release enforcement) |
| **NEW** | — | `save_result_draft`, `publish_provisional_results`, `finalize_match_results` |
| **NEW** | — | `submit_dispute`, `assign_dispute_moderator`, `resolve_dispute`, `reject_dispute` |
| **NEW** | — | `finalize_tournament_results` (compute standings from entry results) |

---

## Storage Buckets Needed

| Bucket | Access | Purpose |
|--------|--------|---------|
| `dispute-evidence` | Private | Dispute evidence uploads; signed URLs for moderators |

---

## Open Decisions Requiring Owner Input

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Bracket format | Single-elim, double-elim, round-robin, Swiss, custom | **Defer** — Implement generic round/group/slot; bracket engine in Phase 5 |
| Scoring formula | Kill points, placement points, survival time, custom | **Use `tournaments.rules_config` JSONB** — Organizer defines per tournament |
| Dispute window | Fixed hours, configurable per tournament | **Use `tournaments.dispute_window_hours`** (add column) |
| Evidence retention | 30 days, 90 days, 1 year | **Default 90 days** — Configurable in tournament config |
| Credential rotation | Manual, automatic on compromise | **Manual only for Phase 4** — Organizer re-sets credentials |

---

## Verification Commands

```bash
# Check current schema
supabase db diff --schema public

# Verify migrations apply cleanly
supabase db reset

# Run existing Phase 3 regression
node apps/web/scripts/phase3-rpc-check.mjs
node apps/web/scripts/phase3-security-check.mjs
```