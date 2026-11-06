# Phase 3 Implementation Report — Tournament & Participation Management

**Date:** 2026-11-07  
**Branch:** `agent/fft-development`  
**Commit:** *(pending)*

---

## Summary

Phase 3 (Tournament & Participation Management) has been implemented and verified across the full stack: database (PostgreSQL + Supabase), backend (trusted SECURITY DEFINER RPCs), web (Next.js 16 Server Actions), and mobile (Flutter 3.47 / Dart 3.13).

All acceptance criteria are met:

| Area | Tests | Result |
|------|-------|--------|
| Database RPC integration | 19 checks | ✅ 19/19 PASS |
| Database RLS/security | 31 checks | ✅ 31/31 PASS |
| Web validation (Vitest) | 90 tests | ✅ 90/90 PASS |
| Web typecheck | `tsc --noEmit` | ✅ PASS |
| Web production build | `next build` | ✅ PASS (20 routes) |
| Flutter tests | 20 tests | ✅ 20/20 PASS |
| Flutter analyzer | `--no-pub` | ✅ 0 errors |
| Flutter APK build | `flutter build apk --debug` | ✅ PASS |

---

## Database (Migrations)

### Migration 5: `20261106000005_phase3_tournament_participation.sql`
Core Phase 3 schema and trusted RPCs:

**Tables:**
- `tournament_organizers` — per-tournament organizer roles (owner, organizer, moderator)
- `tournament_registrations` — solo/squad entries with status (pending, confirmed, waitlisted, cancelled)
- `tournament_entry_members` — immutable roster snapshots per registration
- `team_invitations` — cryptographically secure invitation tokens (SHA-256 hash stored, plaintext returned once)
- `team_member_events` — audit trail for team membership changes

**Key RPCs (all `SECURITY DEFINER`, fixed `search_path`):**
- `create_tournament` / `update_tournament` / `set_tournament_status` — organizer-only lifecycle
- `register_tournament_entry` / `withdraw_tournament_entry` — player registration with eligibility, capacity, duplicate prevention
- `promote_next_waitlisted` / `organizer_promote_waitlist` — atomic FIFO waitlist promotion
- `create_team` / `invite_to_team` / `accept_team_invitation` / `decline_team_invitation` / `revoke_team_invitation` — team management
- `remove_team_member` / `transfer_team_captaincy` / `leave_team` / `dissolve_team` — roster operations with active-registration guard
- `is_tournament_organizer` / `is_team_captain` — trusted authorization helpers

**Business Rules Enforced:**
- Capacity = `max_teams` entries (solo or squad)
- Squad roster must equal `team_size` exactly (1, 2, or 4)
- Incomplete squads rejected (`ROSTER_INCOMPLETE`)
- Duplicate registration prevented (`ALREADY_REGISTERED`, `PLAYER_ALREADY_REGISTERED`)
- Waitlist FIFO via `tournament_waitlist_seq`
- Atomic promotion inside withdrawal transaction
- Invitation tokens: 32 random bytes → hex, SHA-256 hash stored, 1–168h expiry, 20/hour/team rate limit
- In-game UID eligibility enforced per-player

### Migration 6: `20261106000006_fix_tournament_organizer_policy_recursion.sql`
Corrective fixes for RLS circularities discovered during verification:

1. **Tournament organizer policy** — Rewrote "Tournament owner can manage organizers" to reference `tournaments.organizer_id` instead of self-querying `tournament_organizers`, eliminating infinite recursion.
2. **Helper grants** — Narrowed `EXECUTE` on `is_tournament_organizer`, `is_team_captain` to `authenticated` role; revoked from `PUBLIC`.
3. **Team roster freeze** — Added `team_has_active_registration()` helper; `remove_team_member`, `transfer_team_captaincy`, `leave_team` now reject mutations when the team has a live registration.
4. **Roster snapshot visibility** — `tournament_entry_members` SELECT policy allows entry owner, tournament organizer, and any roster participant (via `is_entry_participant` SECURITY DEFINER helper) to read the full snapshot; unrelated users denied.
5. **Teams/team_members circularity** — Rewrote both "Team members can read" policies to reference `teams.owner_id`/`captain_id` directly, breaking the teams ↔ team_members RLS loop.

---

## Web (Next.js 16)

### Server Actions (`apps/web/src/lib/actions/`)
- `tournaments.ts` — create, update, status transitions, registration, withdrawal, waitlist promotion
- `teams.ts` — create, invite, accept/decline/revoke, remove member, transfer captaincy, leave, dissolve

All actions:
1. Validate input with Zod schemas (`src/lib/validation/tournament.ts`)
2. Authenticate via Supabase SSR
3. Call trusted RPCs (never direct table writes for protected operations)
4. Map known RPC error codes to user-facing messages via `humanizeDbError` (`src/lib/errors.ts`)

### Validation (`src/lib/validation/tournament.ts`)
- `tournamentInputSchema` — full tournament config with cross-field date/format validation
- `teamInputSchema` / `inviteInputSchema` — team creation and invitations
- UTC timestamp serialization (`iso()` appends `Z`)
- Solo format forces `team_size = 1`

### Error Mapping (`src/lib/errors.ts`)
- `humanizeDbError` maps 40+ RPC error codes to safe messages
- Unknown errors return generic fallback; no SQL leakage
- Postgres codes 23505/42501/PGRST116 handled

### Pages (App Router)
- `(public)/tournaments` — discovery, search, filters, pagination
- `(public)/tournaments/[id]` — details, registration, team selection, withdrawal
- `(organizer)/organizer/dashboard` — organizer tournament list, stats, quick actions
- `(organizer)/organizer/tournaments/create` — create draft
- `(organizer)/organizer/tournaments/[id]` — manage entries, waitlist, lifecycle transitions
- `(organizer)/organizer/tournaments/[id]/edit` — reuse create form with pre-filled data
- `(player)/my-tournaments` — player's entries with waitlist position, withdrawal
- `(player)/my-teams` / `create` / `[teamId]` / `invite/[token]` — team CRUD, invitations

### Tests
- `src/lib/validation/tournament.test.ts` — 38 tests (valid/invalid inputs, cross-field rules, solo/team logic, payload serialization)
- `src/lib/errors.test.ts` — 52 tests (all RPC error codes, Postgres codes, unknown error fallback, no SQL leakage)

---

## Mobile (Flutter 3.47 / Dart 3.13)

### Architecture
- Plain Dart models (`data/models/tournament_models.dart`, `team_models.dart`) — `@JsonSerializable`, no Freezed
- Remote data sources (`data/datasources/remote/tournament_remote_data_source.dart`, `team_remote_data_source.dart`) — call Supabase RPCs
- Repositories (`data/repositories/tournament_repository_impl.dart`, `team_repository_impl.dart`) — local validation before RPC
- Dependency injection (`injection_container.dart`) — lazy GetIt registration, `tournamentRepository` / `teamRepository` getters
- Error mapper (`core/errors/error_mapper.dart`) — `humanizeError` for RPC codes

### Pages
- `TournamentListPage` — public discovery with search, mode/status filters, pull-to-refresh
- `TournamentDetailPage` — details, registration (solo/team), waitlist position, withdrawal
- `MyTournamentsPage` — player's entries with status chips, waitlist, withdrawal
- `MyTeamsPage` — teams with member counts, captain badge, create team FAB
- `CreateTeamPage` — name/tag/description validation
- `TeamDetailPage` — roster, invitations (captain), remove/transfer/leave (role-gated)
- `TeamInvitePage` — accept/decline with one-time token display
- `OrganizerDashboardPage` — stats cards, tournament list, create FAB
- `OrganizerTournamentListPage` — organizer's tournaments
- `CreateTournamentPage` — create/edit (reused for `/organizer/tournaments/:id/edit`), UTC date pickers, capacity/format validation
- `OrganizerTournamentDetailPage` — entries grouped by status, waitlist, lifecycle buttons, promote waitlist

### Router (`presentation/shared/navigation/app_router.dart`)
- `/organizer/*` requires authentication (no platform organizer role yet; per-tournament auth via RPC)
- Admin routes blocked until Phase 5
- Login redirect preserves deep link
- Organizer shell renders child directly (no duplicate AppBar)

### Tests
- `test/phase3_models_test.dart` — 8 tests (parsing, serialization, error mapping)
- `test/phase3_repository_test.dart` — 11 tests (local validation rejects invalid input before RPC, delegates valid input)

---

## Security Model

| Layer | Mechanism |
|-------|-----------|
| Authentication | Supabase Auth (email/password, MFA, email verification) |
| Authorization | Per-tournament via `tournament_organizers` + trusted RPCs |
| RLS | All tables enabled; policies reference only `auth.uid()` and owned relations |
| RPCs | `SECURITY DEFINER` with fixed `search_path`; `EXECUTE` granted to `authenticated` only |
| Invitations | 32-byte random token → hex; only SHA-256 hash persisted; single-use; expiry enforced |
| Capacity | Enforced inside registration RPC with row locks; never exceeded |
| Waitlist | FIFO via sequence; atomic promotion inside withdrawal transaction |
| Roster freeze | Team mutations blocked while any registration is live |
| Data exposure | `tournament_entry_members` visible only to entry owner, organizer, roster participants |

---

## UTC / Time Handling

- Web forms: UTC input, labeled as UTC, `iso()` appends `Z`
- Mobile: Displays local time (`toLocal()`), sends UTC to RPCs
- Database: All timestamps `TIMESTAMPTZ` stored in UTC

---

## Known Limitations (Phase 3)

- No platform-level organizer approval (deferred to Phase 5)
- No platform admin UI (deferred to Phase 5)
- No match scheduling/results (Phase 4)
- No notifications/push (Phase 5)
- No tournament brackets/elimination (Phase 4)
- No team chat or in-app messaging (Phase 5)

---

## Files Changed (Summary)

### Database
- `supabase/migrations/20261106000006_fix_tournament_organizer_policy_recursion.sql` (new corrective migration)

### Web
- `apps/web/src/lib/validation/tournament.test.ts` (new)
- `apps/web/src/lib/errors.test.ts` (new)

### Mobile (previously implemented, now verified)
- `apps/mobile/lib/data/models/tournament_models.dart`
- `apps/mobile/lib/data/models/team_models.dart`
- `apps/mobile/lib/data/datasources/remote/tournament_remote_data_source.dart`
- `apps/mobile/lib/data/datasources/remote/team_remote_data_source.dart`
- `apps/mobile/lib/data/repositories/tournament_repository_impl.dart`
- `apps/mobile/lib/data/repositories/team_repository_impl.dart`
- `apps/mobile/lib/domain/repositories/tournament_repository.dart`
- `apps/mobile/lib/domain/repositories/team_repository.dart`
- `apps/mobile/lib/core/errors/error_mapper.dart`
- `apps/mobile/lib/injection_container.dart`
- `apps/mobile/lib/presentation/features/tournaments/presentation/pages/*.dart`
- `apps/mobile/lib/presentation/features/teams/presentation/pages/*.dart`
- `apps/mobile/lib/presentation/features/organizer/presentation/pages/*.dart`
- `apps/mobile/lib/presentation/shared/navigation/app_router.dart`
- `apps/mobile/lib/presentation/features/auth/presentation/pages/profile_page.dart`
- `apps/mobile/test/phase3_models_test.dart`
- `apps/mobile/test/phase3_repository_test.dart`

---

## Verification Commands

```bash
# Database
supabase db reset
node apps/web/scripts/phase3-rpc-check.mjs        # 19/19
node apps/web/scripts/phase3-security-check.mjs   # 31/31

# Web
cd apps/web && npx tsc --noEmit                   # typecheck
cd apps/web && npx next build                     # production build
cd apps/web && npx vitest run                     # 90/90

# Flutter
cd apps/mobile && flutter analyze --no-pub        # 0 errors
cd apps/mobile && flutter test                    # 20/20
cd apps/mobile && flutter build apk --debug       # APK built
```