# Project Status — FFT

**Version:** 4.0  
**Date:** 7 November 2026  
**Status:** Phase 4 — Match, Results & Competition Operations (DATABASE MIGRATION APPLIED, PARTIALLY COMPLETE)

---

## 1. Current Phase

**Phase 2: Authentication & Profiles** — Implementation complete, verification in progress

| Milestone | Status | Target Date | Notes |
|-----------|--------|-------------|-------|
| Machine inspection | ✅ Complete | 5 Nov 2026 | All tools verified |
| GitHub authentication | 🔄 In progress | 5 Nov 2026 | Browser auth pending |
| Repository creation | ⏳ Pending | 5 Nov 2026 | After auth |
| Documentation baseline | ✅ Complete | 5 Nov 2026 | All core docs created |
| Architecture docs | ✅ Complete | 5 Nov 2026 | ARCHITECTURE, DATA_MODEL, WORKFLOWS |
| Security docs | ✅ Complete | 5 Nov 2026 | SECURITY_MODEL, THREAT_MODEL |
| Privacy docs | ✅ Complete | 5 Nov 2026 | PRIVACY_AND_DATA_MAP |
| Legal docs | ✅ Complete | 5 Nov 2026 | RESEARCH_BASELINE, LEGAL_LAUNCH_GATES |
| Decision docs | ✅ Complete | 5 Nov 2026 | PROJECT_DECISIONS, OPEN_OWNER_DECISIONS |
| Test strategy | ✅ Complete | 5 Nov 2026 | TEST_STRATEGY |
| Operations docs | ✅ Complete | 5 Nov 2026 | LOCAL_SETUP, BUILD_AND_RELEASE, BACKUP_AND_RECOVERY |

---

## 2. Environment Readiness

| Component | Status | Version | Notes |
|-----------|--------|---------|-------|
| **OS** | ✅ Ready | Windows 11 | C: 543GB free |
| **Git** | ✅ Ready | 2.52.0 | Configured |
| **GitHub CLI** | ✅ Installed | 2.103.3 | Auth pending (browser) |
| **Flutter** | ✅ Ready | 3.47.9 stable | Dart 3.13.7 |
| **Android SDK** | ✅ Ready | API 36, Build Tools 36.1.0 | Emulator available |
| **Java/JDK** | ✅ Ready | 21.0.12 LTS | Temurin |
| **Node.js** | ✅ Ready | 24.20.0 | Target: 26 LTS |
| **npm** | ✅ Ready | 11.19.0 | |
| **pnpm** | ✅ Ready | 12.16.1 | Shell restart needed |
| **Docker Desktop** | ✅ Installed | 4.98.0 | Running |
| **Supabase CLI** | ✅ Ready | 3.0.0 | |
| **IDE** | ✅ Ready | VS Code | Extensions installed |

---

## 3. GitHub Repository

| Item | Status |
|------|--------|
| Repository exists | ⏳ Pending (after auth) |
| Repository name | `FFT` (private) |
| Default branch | `main` |
| Development branch | `agent/fft-development` |
| Branch protection | ⏳ Pending |
| Secrets configured | ⏳ Pending |

---

## 4. Legal Gates Status

| Gate | Status | Blocker | Evidence Needed |
|------|--------|---------|-----------------|
| 1. Garena Permission | ❌ Not obtained | Public launch, Play submission | Signed agreement |
| 2. Legal Classification | ❌ Not obtained | Public launch, real tournaments | Legal opinion |
| 3. DPDP Compliance | 🔄 Design phase | Launch after 13 May 2027 | DPIA, DPA, checklists |
| 4. Age Policy | 🔄 18+ default | Launch if <18 enabled | Policy doc, consent flow |
| 5. Google Play Policy | 🔄 In progress | Play submission | Checklist sign-off |
| 6. Security Baseline | 🔄 Phase 1-2 | Public launch | Test reports, CI passing |
| 7. Operational Readiness | ❌ Not started | Public launch | Infra diagrams, runbooks |
| 8. Owner Approvals | ❌ Not obtained | All public actions | Signed approval |

**Development Policy:** Local development with synthetic data CONTINUES while gates are pending.

---

## 5. Implementation Progress

### Phase 0: Project Baseline ✅
- [x] Machine inspection
- [x] Documentation baseline (17 documents)
- [x] Environment verification
- [ ] GitHub auth + repo creation
- [ ] Initial commit + push

### Phase 1: Foundation ⏳
- [ ] Flutter app shell
- [ ] Next.js app shell
- [ ] Supabase local config
- [ ] Initial migrations (baseline schema)
- [ ] Design system foundation
- [ ] CI workflows
- [ ] Environment templates

### Phase 2: Authentication & Profiles ✅ VERIFIED COMPLETE
- [x] Supabase Auth integration (email/password, email verification, password recovery, MFA TOTP)
- [x] Secure session handling (refresh, revocation, logout) — Supabase SDK owns persistence
- [x] Player profile CRUD (display name, avatar, in-game name, UID)
- [x] Privacy settings (profile visibility: public/organizers_only/private, notification prefs)
- [x] Account deletion flow (in-app + web page)
- [x] RLS policies for profiles, auth, tournament_organizers
- [x] Unauthorized access tests (player→organizer, organizer→other org, cross-tournament)
- [x] AuthBloc extends plain Bloc (Supabase handles session; no HydratedBloc)
- [x] Auth models use `@JsonSerializable` (no Freezed for auth_state)
- [x] Flutter analyze: 0 errors | Flutter test: 20 PASS | `flutter build apk --debug`: EXIT=0

### Phase 3: Tournament & Participation Management ✅ VERIFIED COMPLETE
*Combines former Phase 3 (Tournament Management) and Phase 4 (Teams & Registration)*

**Database (Migrations 5-6):**
- [x] Tournament CRUD + configuration (format, mode, capacity, schedule, visibility, eligibility)
- [x] Publication lifecycle (draft → published → registration_open → registration_closed → in_progress → completed/cancelled)
- [x] Per-tournament organizer roles (owner, organizer, moderator) via `tournament_organizers`
- [x] Solo & squad registration with eligibility (in-game UID), capacity, duplicate prevention
- [x] Waitlist FIFO (`tournament_waitlist_seq`) + atomic promotion on withdrawal
- [x] Team creation, captaincy, invitations (32-byte token, SHA-256 hash, 1-168h expiry, 20/h/team rate limit)
- [x] Roster freeze: team mutations blocked while registration live
- [x] Trusted `SECURITY DEFINER` RPCs with fixed `search_path`; `EXECUTE` to `authenticated` only

**Web (Next.js 16):**
- [x] Public tournament discovery (search, filters, pagination)
- [x] Tournament detail with registration/withdrawal
- [x] Organizer dashboard, tournament list, create, edit, manage (entries, waitlist, lifecycle)
- [x] Player my-tournaments, my-teams, team CRUD, invitations
- [x] Server Actions with Zod validation + RPC error mapping
- [x] Typecheck PASS | Production build PASS (20 routes) | Vitest 90/90 PASS

**Mobile (Flutter 3.47):**
- [x] Public tournament list/detail, my-tournaments, my-teams
- [x] Team create/detail/invite/accept/decline
- [x] Organizer dashboard/list/create/edit/detail
- [x] Router: `/organizer/*` auth-gated; admin blocked (Phase 5); edit reuses create form
- [x] Plain Dart models, repositories, DI; no new Freezed targets
- [x] Analyzer 0 errors | Tests 20/20 PASS | APK build PASS

**Database Integration Tests:**
- [x] 19/19 RPC happy-path checks PASS
- [x] 31/31 RLS/security checks PASS (visibility, authorization, roster freeze, invitation security, waitlist FIFO, atomic promotion)

### Phase 4: Match, Results & Competition Operations 🟡 MIGRATION APPLIED, PARTIALLY COMPLETE
*Combines former Phase 5 (Match Management) and Phase 6 (Results & Disputes)*

**Database (Migration 7):**
- [x] Match entries canonical model (`match_entries` linking matches ↔ tournament_registrations)
- [x] Extended `matches` table (round/group/mode, dispute window)
- [x] `match_room_secrets` with encrypted credentials + server-side release enforcement
- [x] `match_credential_access` audit log (no secrets)
- [x] Extended `results` table (entry-based scoring, status lifecycle: draft→provisional→disputed→finalized)
- [x] `disputes` table (evidence, moderator review, resolution)
- [x] `tournaments` extensions (dispute window, scoring config JSONB)
- [x] Trusted `SECURITY DEFINER` RPCs with fixed `search_path` for all operations

**Security:**
- [x] Server-side release enforcement in `get_match_credentials`
- [x] Moderator conflict-of-interest checks
- [x] Dispute deadline enforced by database time
- [x] Credential encryption (simple XOR dev / pgcrypto+Vault prod)
- [x] Audit logging via `log_audit`

**Testing:**
- [x] Migration applies cleanly
- [x] Phase 3 regression: 19/19 RPC + 31/31 security = 50/50 PASS
- [x] Web typecheck + build + Vitest 90/90 PASS
- [x] Flutter analyzer 0 errors | Tests 20/20 PASS | APK build PASS

**Known Issues (to complete):**
- [ ] Match entries query returns null in test
- [ ] Duplicate assignment constraint not enforced
- [ ] Match status visibility timing
- [ ] `team_id` NOT NULL constraint violation
- [ ] PostgREST schema cache refresh for `submit_dispute`
- [ ] Unique constraint for `results` ON CONFLICT

### Phase 5: Platform Administration, Notifications & Release Readiness ⏳
*Combines former Phase 7 (Notifications & Admin) and Phase 8 (Quality & Release)*
- [ ] In-app notifications
- [ ] Push (FCM)
- [ ] Admin dashboard
- [ ] Abuse reporting
- [ ] Full test suite
- [ ] Security testing
- [ ] Release builds
- [ ] Documentation sync

---

## 6. Open Technical Decisions

| Decision | Status | Impact |
|----------|--------|--------|
| Shared types package | Deferred | Phase 1+ |
| Real-time subscriptions scope | Deferred | Phase 4 (was Phase 7) |
| Analytics implementation | Deferred | Post-MVP |
| Multi-language support | Deferred | Post-MVP |
| Organizer tiered verification | Deferred | Phase 3+ |

---

## 7. Risks & Blockers

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Garena permission denied | Medium | Critical | Design for independence; legal review |
| PROG Act classification = regulated | Medium | High | Engage counsel early; configurable ops |
| DPDP compliance gaps | Low | High | Privacy by design from Phase 1 |
| Google Play rejection | Low | High | Pre-launch checklist, account deletion |
| Supabase region unavailable | Low | Medium | Document alternative regions |
| Flutter/Next.js breaking changes | Low | Medium | Pin versions, test upgrades in CI |
| Freezed 4.x test runner issues | High | Medium | Documented workaround; monitor upstream |
| HydratedBloc + Freezed 4.x serialization | Medium | Medium | Requires additional Freezed config |

---

## 8. Next Actions

### Immediate (This Session)
1. Complete GitHub authentication in browser
2. Create private `FFT` repository
3. Push initial documentation commit
4. Verify CI pipeline runs

### Phase 1 Start (Next Session)
1. Create Flutter app shell (`apps/mobile`)
2. Create Next.js app shell (`apps/web`)
3. Configure Supabase local (`supabase/config.toml`)
4. Write initial migrations (001-003)
5. Set up CI workflows
6. Create design system foundations

### Phase 2 Verification (Current Focus)
1. Fix Freezed 4.x HydratedBloc serialization (add @JsonSerializable to AuthState)
2. Fix Flutter test runner Freezed resolution (investigate package_config.json)
6. Run flutter build apk --debug successfully
7. Run flutter test successfully

---

## 9. Metrics Dashboard (Placeholder)

| Metric | Current | Target | Trend |
|--------|---------|--------|-------|
| Documentation pages | 17 | 17 (Phase 0) | ✅ |
| Test coverage (backend) | 0% | >80% (Phase 5) | — |
| Test coverage (mobile) | 0% | >80% (Phase 5) | — |
| Test coverage (web) | 0% | >80% (Phase 5) | — |
| Security findings (critical) | 0 | 0 | — |
| Legal gates cleared | 0/8 | 8/8 | — |
| CI pipeline status | Not configured | All green | — |

---

## 10. Sign-Off

**Phase 0 Complete When:**
- [x] All 17 documentation files created
- [x] Machine readiness verified
- [ ] GitHub auth complete
- [ ] Repository created
- [ ] Initial commit pushed to `agent/fft-development`
- [ ] CI pipeline runs successfully

**Owner Review Required:** Before Phase 1 implementation begins.