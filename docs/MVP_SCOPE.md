# MVP Scope — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline for Phase 1-4 implementation

---

## In Scope (MVP)

### Phase 0: Project Baseline ✅
- [x] Repository structure
- [x] Documentation baseline
- [x] Research baseline recorded
- [x] Legal launch gates documented
- [x] Open owner decisions recorded

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

### Phase 2: Authentication & Profiles
- [ ] Supabase Auth: email/password, email verification, password recovery
- [ ] Secure session handling (refresh, revocation, logout)
- [ ] Player profile CRUD (display name, avatar, in-game name, UID)
- [ ] Privacy settings (profile visibility, notification prefs)
- [ ] Account deletion flow (in-app + web page)
- [ ] Role/organization membership model (DB + RLS)
- [ ] RLS policies for profiles, auth, roles
- [ ] Unauthorized access tests (player→organizer, organizer→other org, etc.)

### Phase 3: Tournament Management
- [ ] Tournament CRUD (organizer dashboard)
- [ ] Tournament rules/configuration (format, roster size, eligibility, dates)
- [ ] Publication lifecycle (draft → published → registration open/closed)
- [ ] Public tournament discovery (listing, filtering, detail pages)
- [ ] Search and filtering (status, mode, date)
- [ ] Organizer dashboard tournament management UI
- [ ] Tournament detail pages (public + organizer views)

### Phase 4: Teams & Registration
- [ ] Team creation (captain = creator)
- [ ] Invitation generation (secure tokens, hash stored, expiry, rate limits)
- [ ] Invitation acceptance/decline
- [ ] Captain operations (remove member, transfer captaincy, dissolve)
- [ ] Full-roster validation before registration
- [ ] Registration submission (solo + squad)
- [ ] Duplicate prevention (DB constraints)
- [ ] Capacity enforcement (transactional, race-safe)
- [ ] FIFO waitlist with atomic promotion
- [ ] Concurrency tests (simultaneous registrations at capacity)

### Phase 5: Match Management
- [ ] Match creation (organizer: round, bracket, schedule)
- [ ] Room credential storage (encrypted at rest, restricted access)
- [ ] Release-time enforcement (server-side)
- [ ] Participant access checks (confirmed + eligible only)
- [ ] Organizer match management UI
- [ ] Audit logging for credential access

### Phase 6: Results & Disputes
- [ ] Result entry (organizer)
- [ ] Provisional results publication
- [ ] Dispute submission (player, evidence upload)
- [ ] Moderator workflow (assigned, review, decision)
- [ ] Finalization (immutable)
- [ ] Audited corrections (reason, original, corrected, moderator, timestamp)
- [ ] Result history view

### Phase 7: Notifications & Administration
- [ ] In-app notification system (persisted events)
- [ ] Notification event persistence + retry
- [ ] Push notification integration (FCM)
- [ ] Device token handling
- [ ] Admin dashboard (user mgmt, organizer approval, oversight, config, moderators, abuse, audit)
- [ ] Organizer oversight tools
- [ ] Abuse reporting (player + organizer)
- [ ] Operational logs

### Phase 8: Final Quality & Release Readiness
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
Phase 3 (Tournaments) ◄────────────────────┤
   ↓                                        │
Phase 4 (Teams/Reg) ◄──────────────────────┤
   ↓                                        │
Phase 5 (Matches) ◄────────────────────────┤
   ↓                                        │
Phase 6 (Results/Disputes) ◄───────────────┤
   ↓                                        │
Phase 7 (Notifications/Admin) ◄────────────┘
   ↓
Phase 8 (Quality/Release)
```

**Parallelizable:** Design system, CI workflows, documentation can progress alongside any phase.