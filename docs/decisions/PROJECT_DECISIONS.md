# Project Decisions — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Recorded architectural and product decisions

---

## Decision Record Format

Each decision records:
- **Context**: What problem was being solved
- **Decision**: What was chosen
- **Alternatives Considered**: What else was evaluated
- **Consequences**: Trade-offs, risks, follow-up work
- **Status**: Accepted / Superseded / Deferred

---

## DEC-001: Monorepo Structure

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Need to manage Flutter mobile app, Next.js web app, Supabase backend, and shared documentation in a single repository.

**Decision:** Use pnpm workspace monorepo with structure:
```
FFT/
├── apps/
│   ├── mobile/     # Flutter
│   └── web/        # Next.js
├── supabase/       # Backend (migrations, functions, tests)
├── docs/           # Documentation
├── scripts/        # Utility scripts
└── package.json    # Root workspace config
```

**Alternatives:**
- Separate repos per app (higher coordination overhead, duplicated config)
- Nx/TurboRepo (adds complexity, not needed for 2 apps)
- Bare pnpm workspaces (chosen — simple, native)

**Consequences:**
- ✅ Shared TypeScript types via `packages/shared-types` (future)
- ✅ Single CI pipeline, shared dependencies
- ✅ Atomic commits across frontend/backend
- ⚠️ Need to configure build tools for monorepo (done in Phase 1)

---

## DEC-002: No Separate Node.js Backend

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Charter specifies Supabase (PostgreSQL, Auth, Storage, Edge Functions) as backend for MVP.

**Decision:** Do not create a separate Express/NestJS/Hono API server. Use:
- Supabase REST API (auto-generated from schema)
- Supabase RPC (SECURITY DEFINER functions) for business logic
- Supabase Edge Functions (Deno) for privileged operations
- Next.js Server Actions for web-specific mutations

**Alternatives:**
- Separate Node.js API (tRPC, Hono, Express) — adds deployment, auth sync, latency
- GraphQL (Hasura, custom) — overkill for MVP, RLS works better with REST/RPC

**Consequences:**
- ✅ Simpler architecture, fewer moving parts
- ✅ RLS enforced at database level (source of truth)
- ✅ Type-safe client via Supabase generated types
- ⚠️ Complex business logic must fit in PostgreSQL functions or Edge Functions
- ⚠️ If MVP grows beyond Supabase capabilities, new decision needed

---

## DEC-003: Flutter State Management — Bloc/Cubit

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Need predictable, testable state management for Flutter app.

**Decision:** Use `flutter_bloc` (Bloc for complex features, Cubit for simple).

**Alternatives:**
- Provider/Riverpod — less opinionated, more boilerplate for complex flows
- GetX — too much magic, not pure
- Redux — verbose, not idiomatic Flutter
- setState/InheritedWidget — doesn't scale

**Consequences:**
- ✅ Unidirectional data flow, easy testing
- ✅ Clear separation: events → states
- ✅ HydratedBloc for persistence (auth, prefs)
- ⚠️ Learning curve for team unfamiliar with Bloc
- ⚠️ More files per feature (event, state, bloc)

---

## DEC-004: Next.js Architecture — App Router + Server Components

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Next.js 16.4.5+ with App Router is the recommended direction.

**Decision:** Use App Router with React Server Components (RSC) by default. Client Components only where needed (interactivity, hooks).

**Alternatives:**
- Pages Router — legacy, not recommended
- Pure SPA (Vite + React) — loses SSR/SEO benefits for public pages

**Consequences:**
- ✅ SSR for public tournament pages (SEO, performance)
- ✅ Server Actions for mutations (no API routes needed)
- ✅ Middleware for auth protection
- ⚠️ Mental model shift: Server vs Client Components
- ⚠️ No shared caching for private data (use `noStore()`)

---

## DEC-005: Database Migrations as Source of Truth

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Schema evolution must be versioned, reviewable, and reversible.

**Decision:** All schema changes via Supabase CLI migrations (`supabase/migrations/*.sql`). Never manual changes in production.

**Alternatives:**
- ORM migrations (Prisma, Drizzle) — adds abstraction, Supabase native is simpler
- Manual SQL — not auditable, not reproducible

**Consequences:**
- ✅ Git history = schema history
- ✅ CI can test migrations (`supabase db reset`)
- ✅ Down migrations for rollback (where possible)
- ⚠️ Data migrations need careful planning
- ⚠️ Destructive changes (DROP COLUMN) require multi-step migrations

---

## DEC-006: Row Level Security on Every Table

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Authorization must be enforced at the data layer, not just application layer.

**Decision:** Enable RLS on every table exposed to clients. Write policies for SELECT, INSERT, UPDATE, DELETE per role.

**Alternatives:**
- Application-level authorization only — vulnerable to bugs, API bypass
- Supabase RLS + some tables without — inconsistent

**Consequences:**
- ✅ Defense in depth: even if API bug, data protected
- ✅ Policies testable with pgTAP
- ⚠️ Policy complexity for multi-table joins (use views or RPC)
- ⚠️ Performance: policies add query overhead (mitigate with indexes)

---

## DEC-007: Secure Room Credentials with pgcrypto

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Room ID + password are sensitive operational secrets. Must not leak before release time, not in logs, not readable by DB admins.

**Decision:**
- Store encrypted in `match_room_secrets` (bytea via `pgcrypto`)
- No direct SELECT policy — access ONLY via `get_match_credentials()` RPC
- Release time enforced in RPC (`released_at` check)
- Audit every access (who, when, match_id)
- Encryption key in Supabase Vault / env var

**Alternatives:**
- Plaintext with RLS — DB admin can read, risk of policy error
- Hash passwords — need to return plaintext to players
- External secret manager (AWS Secrets Manager) — overkill for MVP

**Consequences:**
- ✅ Defense in depth: encryption + RLS + RPC + audit
- ✅ Even Supabase support cannot read plaintext
- ⚠️ Key rotation procedure needed
- ⚠️ Must test decryption in RPC thoroughly

---

## DEC-008: Invitation Tokens — Hash Stored, Not Plaintext

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Team invitations use tokenized links. Tokens must not be reusable if database exposed.

**Decision:**
- Generate cryptographically random token (32 bytes)
- Store `sha256(token)` in `team_invitations.token_hash`
- Link contains plaintext token: `/team/invite/{token}`
- On acceptance: verify `sha256(input) = token_hash`
- Expire after 7 days, single-use

**Alternatives:**
- Store plaintext — if DB leaked, all invitations compromised
- JWT in link — more complex, no benefit

**Consequences:**
- ✅ Database leak ≠ invitation compromise
- ✅ Standard security practice (like password hashing)
- ⚠️ Must use constant-time comparison (pgcrypto `digest()`)

---

## DEC-009: Tournament Registration — Race-Safe via DB Function

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Concurrent registrations at capacity boundary must not overfill.

**Decision:** Single RPC `register_tournament_entry()` with:
- `LOCK tournament FOR UPDATE` (row-level lock)
- Re-check all conditions inside transaction
- Insert entry + waitlist atomically
- Return status (confirmed/waitlisted)

**Alternatives:**
- Optimistic locking (version column) — retry loops, complex client
- Application-level mutex (Redis) — extra infrastructure, not needed
- Queue-based — overkill

**Consequences:**
- ✅ Serializes at capacity boundary, no overfill
- ✅ Single source of truth in DB
- ⚠️ Lock contention at high concurrency (mitigate: short transaction, indexes)
- ⚠️ Must test with concurrent load (k6)

---

## DEC-010: Waitlist Promotion — Atomic FIFO via SKIP LOCKED

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** When capacity frees, next waitlisted entry must be promoted atomically.

**Decision:** `promote_waitlist()` RPC uses:
```sql
SELECT * FROM waitlist_entries
WHERE tournament_id = $1 AND status = 'waiting'
ORDER BY position
FOR UPDATE SKIP LOCKED
LIMIT 1
```

**Alternatives:**
- Application picks and updates — race condition
- Advisory locks — more complex

**Consequences:**
- ✅ True FIFO, no skipping, no double-promotion
- ✅ `SKIP LOCKED` allows concurrent promotions for different tournaments
- ⚠️ PostgreSQL 9.5+ required (Supabase has 17)

---

## DEC-011: Account Deletion — In-App + Web, 24h Cooling-Off

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Google Play requires in-app + web account deletion. DPDP requires erasure right.

**Decision:**
- In-app: Settings → Delete Account → password confirm → email verification
- Web: `/account-deletion` page → email → verification link
- Backend: Edge Function workflow with 24h cooling-off
- Retention exceptions documented (audit logs, legal)
- Soft delete profiles (anonymize), hard delete PII tables

**Alternatives:**
- Immediate deletion — no cooling-off, higher regret risk
- Manual admin process — doesn't scale, not self-service

**Consequences:**
- ✅ Meets Google Play + DPDP requirements
- ✅ User can cancel within 24h
- ⚠️ Complex workflow: auth deletion + data anonymization + retention tracking
- ⚠️ Must test thoroughly (Phase 2)

---

## DEC-012: Age Policy — 18+ Default, Configurable

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Garena ToS requires parental consent for <18. DPDP has children's data provisions. Legal classification unclear.

**Decision:** Default minimum age = 18. Configurable via feature flag. No under-18 registration without legal review + approved parental consent design.

**Alternatives:**
- 13+ with parental consent — requires verified consent mechanism (complex)
- No age gate — legal risk

**Consequences:**
- ✅ Conservative, defensible position
- ✅ Configurable for future policy change
- ⚠️ Excludes legitimate younger players
- ⚠️ Age verification = self-declaration (no gov ID collected)

---

## DEC-013: No Real-Money Features

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Legal gates prohibit real-money prizes, wallets, betting, payouts.

**Decision:** Hard-code "no monetary features" in MVP. Prize field = text description only (non-monetary). No payment integration.

**Alternatives:**
- Build wallet/payment but disable — technical debt, confusion
- Virtual currency — still resembles gambling in some jurisdictions

**Consequences:**
- ✅ Clear boundary, no accidental compliance violations
- ✅ Simplifies legal review
- ⚠️ Organizers may want prize pools (deferred)

---

## DEC-014: Push Notifications — FCM After Core, In-App First

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Notifications critical for tournament operations but FCM adds complexity.

**Decision:** Build in-app notification system first (persisted, realtime). Add FCM in Phase 7.

**Alternatives:**
- FCM from start — delays core features
- Email only — poor UX for time-sensitive updates (credentials, matches)

**Consequences:**
- ✅ Core tournament flows work without FCM
- ✅ In-app notifications reliable (DB + Realtime)
- ⚠️ Mobile users need app open for real-time (acceptable for MVP)

---

## DEC-015: Design System — Custom, Material 3 (Mobile), Tailwind + shadcn/ui (Web)

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Need professional esports look, not generic template.

**Decision:**
- Mobile: Material 3 with custom theme (colors, typography, components)
- Web: Tailwind CSS + shadcn/ui (accessible, customizable)
- Shared design tokens (colors, spacing) via JSON (future package)

**Alternatives:**
- Flutter: Custom painter everything — too much work
- Web: MUI, Chakra — heavier, less customizable
- Shared UI kit — premature for 2 platforms

**Consequences:**
- ✅ Platform-appropriate, professional look
- ✅ Accessibility built-in (shadcn/ui, Material 3)
- ⚠️ Two design systems to maintain (mitigate: shared tokens)

---

## DEC-016: Testing Strategy — Layered, Automated in CI

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Charter requires actual verification evidence, not fake tests.

**Decision:**
| Layer | Mobile | Web | Backend |
|-------|--------|-----|---------|
| Unit | `flutter_test` + `bloc_test` | Vitest | pgTAP (SQL) |
| Widget/Component | `flutter_test` (widget) | React Testing Library | N/A |
| Integration | `integration_test` (device) | Playwright (E2E) | `supabase db reset` + RPC tests |
| Contract | API types shared | API types shared | Generated types |
| Security | MASVS checks | OWASP ASVS checks | RLS policy matrix |

**Consequences:**
- ✅ Comprehensive coverage
- ✅ CI gates on all layers
- ⚠️ Significant test infrastructure investment (Phase 1)

---

## DEC-017: CI/CD — GitHub Actions, Private Repo, Development Branch

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Charter specifies automatic push to `agent/fft-development` branch after validated milestones.

**Decision:**
- Private GitHub repo
- Branch: `agent/fft-development` (no force-push, no merge to main)
- Workflows: lint, typecheck, test, build, security scan
- Deploy previews: Vercel (web), manual (mobile)
- Pin action versions to commit SHAs

**Consequences:**
- ✅ Traceable, auditable development history
- ✅ Automated quality gates
- ⚠️ Requires GitHub CLI auth (in progress)

---

## DEC-018: Supabase Region — Mumbai (ap-south-1)

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Data localization preference for Indian users.

**Decision:** Use Mumbai region for primary Supabase project. Document that region ≠ compliance proof.

**Alternatives:**
- Singapore — lower latency for some, but not India
- Multiple regions — not needed for MVP

**Consequences:**
- ✅ Data at rest in India
- ⚠️ Backups, logs, email may process elsewhere (documented)
- ⚠️ Region availability depends on Supabase plan

---

## DEC-019: No Social Features in MVP

**Date:** 5 Nov 2026  
**Status:** Accepted

**Context:** Charter explicitly excludes social feed, DM, chat, live streaming.

**Decision:** Hard scope boundary. No friend system, no chat, no follow, no feed.

**Consequences:**
- ✅ Focus on tournament management
- ✅ Reduces moderation surface
- ⚠️ Organizers may request (deferred)

---

## DEC-021: Roadmap Restructuring — 9 Phases → 6 Phases

**Date:** 6 Nov 2026  
**Status:** Accepted

**Context:** Original roadmap had 9 phases (0–8). Phase boundaries created overhead without clear domain separation.

**Decision:** Restructure to exactly 6 official phases:

| New Phase | Name | Combines |
|-----------|------|----------|
| Phase 0 | Project Baseline | Phase 0 |
| Phase 1 | Foundation | Phase 1 |
| Phase 2 | Authentication & Profiles | Phase 2 |
| Phase 3 | Tournament & Participation Management | Phase 3 + Phase 4 |
| Phase 4 | Match, Results & Competition Operations | Phase 5 + Phase 6 |
| Phase 5 | Platform Administration, Notifications & Release Readiness | Phase 7 + Phase 8 |

**Constraints:**
- Phases 0, 1, 2 unchanged in scope, requirements, deliverables, acceptance criteria
- All features preserved — no scope removed
- All engineering steps retained — no quality gates skipped
- Internal milestones used within consolidated phases
- Dependency gates unchanged (Phase N → Phase N+1)
- Historical reports preserve 9-phase references; active references updated

**Documentation Updated:** MVP_SCOPE.md, PROJECT_STATUS.md, README.md, ROADMAP_RESTRUCTURING.md, PROJECT_DECISIONS.md

**Alternatives:**
- Keep 9 phases — higher overhead, thinner slices
- Merge differently (e.g., Auth+Foundation) — weaker domain boundaries

**Consequences:**
- ✅ Fewer phase boundaries = fewer handoffs
- ✅ Natural domain groupings (Tournament+Registration, Match+Results, Admin+Release)
- ✅ All scope, engineering steps, quality gates preserved
- ⚠️ Larger phases need internal milestone discipline
- ⚠️ Historical reports reference 9 phases (preserved as historical)

---

## DEC-020: Substitute System — Deferred

**Date:** 5 Nov 2026  
**Status:** Deferred

**Context:** Squad roster size configurable, but substitutes not designed.

**Decision:** MVP: `max_substitutes = 0`. Design substitutes when real organizer requirements emerge.

**Consequences:**
- ✅ Simpler roster validation
- ⚠️ May need migration later (add column, adjust constraints)