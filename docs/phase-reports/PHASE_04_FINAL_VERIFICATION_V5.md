# Phase 4 Final Verification Report (V5)

## Executive Summary

**Verdict: PHASE 4 CODE COMPLETE — EXTERNAL VERIFICATION PENDING**

Every code-level defect identified for Phase 4 has been repaired in a new,
additive migration and verified against a fresh local Supabase database with
real authenticated users. The remaining items are production-owner actions
(production database migration approval, production signing secrets, final
application id) and GitHub Actions runtime execution, none of which can be
completed from this repository without external authorization.

This report supersedes V4. V4 described two high-priority defects as
unresolved; those defects are now fixed and covered by regression tests.

---

## Defects Repaired In This Round

All fixes live in `supabase/migrations/20261108000014_phase4_final_repair.sql`.
Previously applied migrations were not edited.

### A. `assign_match_entries` capacity and batch validation

- NULL and empty arrays are rejected with `INVALID_ENTRY_FOR_MATCH`.
- NULL array elements are rejected.
- Duplicate ids inside one batch are rejected with `DUPLICATE_ENTRY_IN_BATCH`.
- Every registration is checked for existence, correct tournament and
  `confirmed` status before any insert.
- Already-assigned registrations reject the entire batch with
  `ENTRY_ALREADY_ASSIGNED`.
- Capacity is computed once as `existing_committed_entries + batch_size`, not
  per loop iteration.
- `SELECT ... FOR UPDATE` on the match serializes concurrent assignment
  attempts; the second caller re-reads committed entries after the first
  commits, so capacity cannot be exceeded.
- Any failure rolls the whole function (one transaction) back, leaving no
  partial assignments.

### B. `save_result_draft` lifecycle protection

- The match row and existing result row are locked before the state check.
- Draft → Draft is allowed (idempotent update).
- Draft → Provisional remains exclusive to `publish_provisional_results`.
- Provisional → Draft is rejected with `RESULT_NOT_EDITABLE`.
- Finalized → Draft is rejected with `RESULT_NOT_EDITABLE`.
- Disputed → Draft is rejected with `RESULT_NOT_EDITABLE` as well.
- Rejected calls do not modify rank, kills, points or status.

### C. `is_team_staff` authorization boundary

- Signature changed from `is_team_staff(p_team_id, p_user_id DEFAULT auth.uid())`
  to `is_team_staff(p_team_id)`.
- Identity is derived only from `auth.uid()`.
- The old two-argument overload is dropped.
- Dependent RLS policies are recreated against the one-argument function.
- `EXECUTE` is revoked from `PUBLIC` and `anon` and granted only to
  `authenticated`.
- Team-history read access for ordinary team members is preserved without
  re-introducing RLS recursion.

### D. `finalize_match_results` scope bug

Discovered during this verification round: migration `00007` declared
`v_assigned_count` inside a nested `DECLARE` block and then referenced it
outside the block, so every finalization failed with
`column "v_assigned_count" does not exist`. The function is recreated with the
variable at function scope.

### E. Dispute tests

`apps/web/scripts/phase4-rpc-check.mjs` was rewritten:

- Removed the false-positive `submit_dispute succeeds (or known cache issue)`
  assertion and all schema-cache SKIP paths.
- Removed the service-role INSERT fallback that pretended to prove the RPC.
- PostgREST availability is now verified deterministically against the live
  OpenAPI document; if a required RPC is absent the run is BLOCKED, not PASS.
- Added real authenticated-user coverage for:
  - valid participant submission and persisted row,
  - duplicate active dispute rejection,
  - outsider rejection,
  - unauthenticated rejection,
  - squad-member submission,
  - resolved-dispute resubmission,
  - two concurrent submissions producing exactly one active dispute,
  - valid moderator assignment,
  - moderator conflict-of-interest rejection,
  - non-moderator rejection.
- All setup writes (users, moderator roles, dispute resolution) check their
  errors.

### F. Flutter CI and signing paths

- `.github/workflows/flutter-ci.yml` now runs only development CI: pub get,
  analyze, test, debug APK. It has no production signing dependency.
- `.github/workflows/flutter-release.yml` is a separate manual
  `workflow_dispatch` workflow that requires all four signing secrets.
- Signing files are written where Gradle reads them:
  - `apps/mobile/android/key.properties`
  - `apps/mobile/android/app/keystore/release.keystore`
- `storeFile=keystore/release.keystore` resolves correctly relative to the app
  module (`apps/mobile/android/app`).
- Signature verification uses `apksigner verify --print-certs`; the previous
  `keytool -list -printcert -jarfile` invocation was invalid for APKs.
- `.gitignore` and `apps/mobile/android/.gitignore` ignore the real
  `key.properties` and all `*.jks` / `*.keystore` files.

---

## Verification Results (Executed Locally)

### Database

`supabase db reset` applied all 13 migrations cleanly, ending with
`20261108000014_phase4_final_repair.sql`.

| Suite | Result |
|---|---|
| Phase 4 RPC / RLS / capacity / result-state / dispute integration | **73 / 73 PASS, 0 FAIL, 0 BLOCKED** |
| Phase 3 RPC regression | **19 / 19 PASS** |
| Phase 3 security / RLS regression | **31 / 31 PASS** |

Phase 4 coverage includes:

- one registration, multiple separate registrations in one batch, exact
  capacity, over capacity, duplicate id in batch, already assigned, foreign
  registration, NULL/empty arrays, and two concurrent assignment requests;
- draft create, draft update, publish provisional, rejected provisional
  overwrite, finalize, rejected finalized overwrite, and unchanged data after
  rejection;
- `is_team_staff` owner/member/outsider/anonymous/arbitrary-id cases and real
  RLS update denial for members and outsiders;
- all ten dispute acceptance scenarios listed above.

The partial unique index `uq_disputes_active_per_match_registration` remains
in place and is exercised by both the duplicate and concurrent dispute tests.

### Web

| Check | Result |
|---|---|
| `npm run typecheck` | PASS |
| `npm run lint` | PASS (0 errors, 23 pre-existing warnings) |
| `npm test` | **90 / 90 PASS** |
| `npm run build` | PASS |

### Flutter

| Check | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter analyze --no-fatal-infos` | PASS (0 errors, 0 warnings, 1006 info; exit 0) |
| `flutter test` | **20 / 20 PASS** |
| `flutter build apk --debug` | PASS |
| `flutter build apk --release` without keystore | FAILS CLOSED with `PRODUCTION RELEASE BLOCKED: key.properties missing or incomplete.` |
| `flutter build apk --release` with a throwaway keystore at the new paths | PASS; `apksigner` reports `CN=FFT Release Test`, not the debug certificate |

The throwaway keystore and `key.properties` used for the path verification were
deleted immediately afterwards and were never tracked by Git.

---

## Remaining Blockers (Genuine External Actions)

| Blocker | Why it cannot be completed here | Owner action |
|---|---|---|
| Production database migration | Production project `zjwgqjjgqbkunzhghdtb` is not authorized for changes from this environment | Review and run `supabase/fix_tournament_public_listing.sql` in the production SQL editor |
| Production signing secrets | Repository secrets are not readable/writable from the codebase | Configure `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` in GitHub |
| Production application id | The owner has not approved a final package id | Confirm the id and update `applicationId` / `namespace` |
| GitHub Actions runtime | This environment cannot observe GitHub-hosted runner execution | Confirm the workflows run on the next push and manual release dispatch |

`main` was not modified.

---

## Decision

**PHASE 4 CODE COMPLETE — EXTERNAL VERIFICATION PENDING**

No Phase 5 work was started.
