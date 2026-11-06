# MVP Scope — FFT

**Version:** 3.0  
**Date:** 7 November 2026  
**Status:** Phase 3 — Tournament & Participation Management (VERIFIED COMPLETE)

---

## Phase Mapping (Old → New)

| Previous Phase | New Official Phase |
|----------------|-------------------|
| Phase 0: Project Baseline | **Phase 0: Project Baseline** |
| Phase 1: Foundation | **Phase 1: Foundation** |
| Phase 2: Authentication & Profiles | **Phase 2: Authentication & Profiles** |
| Phase 3: Tournament Management + Phase 4: Teams & Registration | **Phase 3: Tournament & Participation Management** |
| Phase 5: Match Management + Phase 6: Results & Disputes | **Phase 4: Match, Results & Competition Operations** |
| Phase 7: Notifications & Admin + Phase 8: Quality & Release | **Phase 5: Platform Administration, Notifications & Release Readiness** |

**Official roadmap now contains exactly 6 phases: Phase 0, 1, 2, 3, 4, 5.**

Historical references to 9 phases remain in past reports only when clearly identified as historical. Active roadmap references updated.

---

## In Scope (MVP)

### Phase 0: Project Baseline ✅
- [x] Repository structure
- [x] Documentation baseline (17 documents)
- [x] Research baseline recorded
- [x] Legal launch gates documented
- [x] Open owner decisions recorded
- [ ] GitHub authentication + repository creation
- [ ] Initial commit + push to `agent/fft-development`

### Phase 1: Foundation
- [ ] Flutter Android app shell (Material 3, navigation, theming)
- [ ] Next.js web app shell (App Router, TypeScript strict, Supabase SSR)
- [ ] Supabase local development setup (Docker)
- [ ] Database migration baseline (initial schema)
- [ ] Environment variable templates (.env.example)
- [ ] Design system foundation (colors, typography, components)
- [ ] Linting (ESLint, flutter analyze), formatting (Prettier, dart format)
- [ ] Type checking (tsc --noEmit, dart analyze)
- [ ] CI workflows (GitHub Actions)
- [ ] Basic automated tests (unit + widget + integration)

### Phase 2: Authentication & Profiles ✅
- [x] Supabase Auth: email/password, email verification, password recovery, MFA TOTP
- [x] Secure session handling (refresh, revocation, logout) — Supabase SDK owns persistence
- [x] Player profile CRUD (display name, avatar, in-game name, UID)
- [x] Privacy settings (profile visibility: public/organizers_only/private, notification prefs)
- [x] Account deletion flow (in-app + web page)
- [x] RLS policies for profiles, auth, tournament_organizers
- [x] Unauthorized access tests (player→organizer, organizer→other org, cross-tournament)
- [x] AuthBloc extends plain Bloc; Supabase handles session
- [x] Auth models use `@JsonSerializable`; only auth_event uses Freezed
- [x] Flutter analyze: 0 errors | Flutter test: 20 PASS | `flutter build apk --debug`: EXIT=0

### Phase 3: Tournament & Participation Management ✅
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

### Phase 4: Match, Results & Competition Operations
*Combines former Phase 5 (Match Management) and Phase 6 (Results & Disputes)*

- [ ] Match creation (organizer: round, bracket, schedule)
- [ ] Room credential storage (encrypted at rest, restricted access)
- [ ] Release-time enforcement (server-side)
- [ ] Participant access checks (confirmed + eligible only)
- [ ] Organizer match management UI
- [ ] Audit logging for credential access
- [ ] Result entry (organizer)
- [ ] Provisional results publication
- [ ] Dispute submission (player, evidence upload)
- [ ] Moderator workflow (assigned, review, decision)
- [ ] Finalization (immutable)
- [ ] Audited corrections (reason, original, corrected, moderator, timestamp)
- [ ] Result history view

### Phase 5: Platform Administration, Notifications & Release Readiness
*Combines former Phase 7 (Notifications & Admin) and Phase 8 (Quality & Release)*

- [ ] In-app notification system (persisted events)
- [ ] Notification event persistence + retry
- [ ] Push notification integration (FCM)
- [ ] Device token handling
- [ ] Admin dashboard (user mgmt, organizer approval, oversight, config, moderators, abuse, audit)
- [ ] Organizer oversight tools
- [ ] Abuse reporting (player + organizer)
- [ ] Operational logs
- [ ] Full test suite passing
- [ ] Security testing (authz boundaries, IDOR, RLS, secrets)
- [ ] Android release build (AAB, signed)
- [ ] Web production build (Vercel-ready)
- [ ] Database migration tests (up/down, RLS)
- [ ] Accessibility review (WCAG 2.1 AA)
- [ ] Performance review (benchmarks)
- [ ] Dependency vulnerability scan
- [ ] Account deletion verification (end-to-end)
- [ ] Documentation review (sync with code)
- [ ] Release readiness report

---

## Out of Scope (MVP)

| Feature | Reason |
|---------|--------|
| Social feed / messaging / chat | Not tournament management |
| Live streaming integration | Complex, deferred |
| Betting / prizes / wallets / payouts | Legal blocker, explicitly prohibited |
| Automated game data integration | No official API, legal risk |
| Substitute/bench system | Deferred until rules designed |
| Multi-language | English only initially |
| Organizer marketplace | Not core |
| Cross-tournament rankings | Not core |
| Advanced team branding | Name/logo only |
| Apple/third-party auth | Google only after core email flow |
| Real tournament operations in production | Blocked by legal gates |

---

## Success Criteria (MVP Complete)

1. **Local development:** Full stack runs locally with `supabase start` + `pnpm dev` + `flutter run`
2. **Authentication:** Register → verify → login → profile → delete account works end-to-end
3. **Tournaments:** Organizer can create, publish, manage tournament; players can discover, register (solo/squad)
4. **Teams:** Captain creates team, invites, accepts, registers squad
5. **Registration:** Race-safe, capacity-enforced, waitlist works under concurrency
6. **Matches:** Organizer creates matches, sets credential release time; players see credentials only after release
7. **Results:** Organizer enters results, publishes provisional; players submit disputes; moderator finalizes
8. **Notifications:** In-app notifications persist; push works (FCM configured)
9. **Admin:** Can manage users, organizers, view audit logs
10. **Security:** All authz tests pass; no secrets in repo; RLS tested
11. **Builds:** Android AAB builds; Next.js production builds; CI passes
12. **Docs:** All documentation synchronized with implementation

---

## Phase Dependencies

```
Phase 0
   ↓
Phase 1 (Foundation) ──────────────────────┐
   ↓                                        │
Phase 2 (Auth/Profiles) ◄──────────────────┤
   ↓                                        │
Phase 3 (Tournament & Participation) ◄─────┤
   ↓                                        │
Phase 4 (Match, Results & Competition) ◄───┤
   ↓                                        │
Phase 5 (Platform Admin, Notifications & Release)
```

**Parallelizable:** Design system, CI workflows, documentation can progress alongside any phase.

---

## Roadmap Restructuring Notes

- **No scope removed:** All features from original 9 phases preserved in consolidated 6 phases
- **No engineering steps skipped:** Each consolidated phase retains all original quality gates, testing requirements, and acceptance criteria
- **Internal milestones:** Each consolidated phase uses smaller internal work packages
- **Dependency gates unchanged:** Phase N must pass before Phase N+1 begins
- **Historical reports preserved:** Past progress reports reference original 9-phase structure but are clearly marked historical
- **Active references updated:** MVP_SCOPE.md, PROJECT_STATUS.md, README.md, PROJECT_DECISIONS.md updated to 6-phase structure

**Documentation Updated:** MVP_SCOPE.md, PROJECT_STATUS.md, README.md, PROJECT_DECISIONS.md, ROADMAP_RESTRUCTURING.md