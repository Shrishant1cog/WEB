# Architecture — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline architecture

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENTS                                        │
├─────────────────────────────────┬───────────────────────────────────────────┤
│  Flutter Android App (Player)   │  Next.js Web App (Org/Admin + Public)    │
│  - Material 3                   │  - App Router, React 18+                 │
│  - Supabase Flutter SDK         │  - Supabase SSR Auth                     │
│  - Repository Pattern           │  - Server Components + Client Components │
│  - Bloc/Cubit State Mgmt        │  - Tailwind CSS + shadcn/ui              │
└──────────────────┬──────────────┴──────────────────┬───────────────────────┘
                   │                                 │
                   ▼                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SUPABASE PLATFORM                                   │
├──────────────┬──────────────┬──────────────┬──────────────┬────────────────┤
│  PostgreSQL  │    Auth      │   Storage    │ Edge Functions│  Realtime      │
│  - RLS       │  - Email/Pass│  - Private   │  - Privileged  │  - Notifications│
│  - Migrations│  - Google    │    Buckets   │    Ops         │  - Live Updates │
│  - Functions │  - MFA (later)│  - Signed    │  - Webhooks    │                │
│  - Triggers  │  - Sessions  │    URLs      │                │                │
└──────────────┴──────────────┴──────────────┴──────────────┴────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                                      │
├──────────────────┬──────────────────┬──────────────────┬───────────────────┤
│  Firebase FCM    │   Custom SMTP    │   S3-compatible  │   Monitoring      │
│  (Push)          │   (Auth Email)   │   (Backup)       │   (Sentry, etc.)  │
└──────────────────┴──────────────────┴──────────────────┴───────────────────┘
```

---

## 2. Flutter Android Application Architecture

### 2.1 Layered Structure

```
apps/mobile/lib/
├── main.dart                      # App entry, providers, routing
├── core/                          # Cross-cutting concerns
│   ├── config/                    # Environment, constants, feature flags
│   ├── errors/                    # Failure types, exception handling
│   ├── network/                   # Supabase client, interceptors
│   ├── security/                  # Token storage, biometric, crypto helpers
│   └── utils/                     # Extensions, formatters, validators
├── data/                          # Data layer
│   ├── datasources/               # Remote (Supabase), Local (SharedPreferences, SQLite cache)
│   ├── models/                    # DTOs, API response models (freezed)
│   ├── repositories/              # Repository implementations
│   └── services/                  # FCM, notifications, storage upload
├── domain/                        # Business logic layer
│   ├── entities/                  # Core domain objects (immutable, freezed)
│   ├── repositories/              # Repository contracts (abstract classes)
│   ├── usecases/                  # Single-responsibility business operations
│   └── validators/                # Domain validation rules
└── presentation/                  # UI layer
    ├── features/                  # Feature-based modules
    │   ├── auth/                  # Login, register, password reset, delete
    │   ├── profile/               # Profile view/edit, privacy settings
    │   ├── tournaments/           # Discovery, detail, registration
    │   ├── teams/                 # Team create, invite, manage
    │   ├── matches/               # Schedule, room credentials
    │   ├── results/               # Results, disputes
    │   └── notifications/         # In-app center, settings
    ├── shared/                    # Shared UI components
    │   ├── widgets/               # Buttons, inputs, cards, dialogs
    │   ├── themes/                # Material 3 theme, dark/light
    │   └── navigation/            # GoRouter config, route guards
    └── bloc/                      # State management (Bloc/Cubit per feature)
```

### 2.2 Key Patterns

| Pattern | Application |
|---------|-------------|
| **Repository** | Abstract data access; swap local/remote; testable |
| **Use Case** | Single business operation; composable; testable |
| **Bloc/Cubit** | Predictable state; immutable events/states; testable |
| **Freezed** | Immutable models, union types, pattern matching |
| **GoRouter** | Declarative routing; deep links; auth guards |
| **Dependency Injection** | GetIt/service_locator; scoped to feature |

### 2.3 State Management

- **Bloc** for complex features (auth, tournaments, teams, registration)
- **Cubit** for simple UI state (forms, toggles, filters)
- **HydratedBloc** for persistence (auth state, preferences)
- **No setState in business logic** — all via Bloc/Cubit

---

## 3. Next.js Web Application Architecture

### 3.1 App Router Structure

```
apps/web/
├── src/
│   ├── app/                          # App Router pages
│   │   ├── (public)/                 # Public route group
│   │   │   ├── layout.tsx            # Public layout
│   │   │   ├── page.tsx              # Homepage
│   │   │   ├── tournaments/          # Public tournament listing/detail
│   │   │   ├── privacy/              # Privacy policy
│   │   │   ├── terms/                # Terms of service
│   │   │   ├── account-deletion/     # Web account deletion page
│   │   │   └── support/              # Support/grievance contact
│   │   ├── (auth)/                   # Auth route group
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   ├── password-reset/
│   │   │   └── email-verify/
│   │   ├── (player)/                 # Player dashboard (authenticated)
│   │   │   ├── layout.tsx            # Player layout + auth guard
│   │   │   ├── profile/
│   │   │   ├── tournaments/
│   │   │   ├── teams/
│   │   │   ├── matches/
│   │   │   ├── results/
│   │   │   └── notifications/
│   │   ├── (organizer)/              # Organizer dashboard
│   │   │   ├── layout.tsx            # Org layout + org-scoped auth guard
│   │   │   ├── organization/
│   │   │   ├── tournaments/
│   │   │   ├── matches/
│   │   │   ├── results/
│   │   │   └── announcements/
│   │   ├── (admin)/                  # Admin dashboard
│   │   │   ├── layout.tsx            # Admin layout + admin guard
│   │   │   ├── users/
│   │   │   ├── organizers/
│   │   │   ├── tournaments/
│   │   │   ├── moderators/
│   │   │   ├── abuse/
│   │   │   ├── audit/
│   │   │   └── settings/
│   │   ├── api/                      # API routes (minimal - prefer Server Actions)
│   │   │   ├── webhooks/             # Stripe (N/A), FCM, Supabase webhooks
│   │   │   └── account-deletion/     # Account deletion initiation
│   │   ├── globals.css               # Tailwind + CSS variables
│   │   ├── layout.tsx                # Root layout
│   │   └── page.tsx                  # Redirect to /tournaments or login
│   ├── components/                   # Shared React components
│   │   ├── ui/                       # shadcn/ui primitives
│   │   ├── forms/                    # Form components (react-hook-form + zod)
│   │   ├── tables/                   # Data tables (tanstack/react-table)
│   │   ├── charts/                   # Recharts (if needed)
│   │   └── layout/                   # Sidebar, header, breadcrumbs
│   ├── lib/                          # Core libraries
│   │   ├── supabase/                 # Server/client Supabase clients
│   │   ├── auth/                     # Auth helpers, middleware
│   │   ├── validators/               # Zod schemas
│   │   ├── utils/                    # Formatters, helpers
│   │   └── constants/                # App constants
│   ├── hooks/                        # Custom React hooks
│   ├── types/                        # TypeScript types (shared with mobile via API contracts)
│   └── middleware.ts                 # Auth middleware, route protection
├── public/                           # Static assets
├── tailwind.config.ts
├── tsconfig.json
├── next.config.mjs
└── package.json
```

### 3.2 Authentication & Authorization

| Layer | Mechanism |
|-------|-----------|
| **Middleware** | Validates session cookie, redirects unauthenticated |
| **Server Components** | `createServerClient` — read user, org, roles from DB |
| **Server Actions** | Mutations with authorization checks |
| **RLS** | Database-enforced (source of truth) |
| **Client Components** | `createBrowserClient` — only for realtime, optimistic UI |

### 3.3 Security Rules

- **Never** use shared caching (`cache: 'force-cache'`) for private data
- **Always** verify auth claims in Server Components/Actions
- **Never** trust session from browser storage without token verification
- **Protect** cookies: `Secure`, `HttpOnly`, `SameSite=Lax`
- **Avoid** exposing protected data in server-rendered HTML (use client fetch for sensitive)
- **Authorize** on server + database, not only UI

---

## 4. Supabase Backend Architecture

### 4.1 Database Design Principles

| Principle | Implementation |
|-----------|----------------|
| **PostgreSQL as source of truth** | All invariants in DB (constraints, triggers, functions) |
| **Versioned migrations** | `supabase/migrations/*.sql` — never manual prod changes |
| **RLS mandatory** | Every exposed table has RLS + policies |
| **Least privilege** | `authenticated` role minimal; custom roles for org/admin |
| **Service role only in Edge Functions** | Never in client bundles |
| **SECURITY DEFINER functions** | Fixed `search_path`, input validation, explicit role checks |
| **Audit everything** | `audit_events` table + triggers on sensitive tables |

### 4.2 Key Database Objects

| Object | Purpose |
|--------|---------|
| **Tables** | Core entities (see DATA_MODEL.md) |
| **Views** | Aggregated data for dashboards (materialized where needed) |
| **Functions** | Transactional workflows (registration, promotion, credential release, result finalization) |
| **Triggers** | `updated_at`, audit logging, constraint enforcement |
| **Policies** | RLS policies per table per role |
| **Indexes** | Query performance (composite for common filters) |
| **Enums** | Type-safe statuses (tournament_state, entry_status, etc.) |

### 4.3 Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `send-notification` | DB trigger / API | Push + in-app notification delivery |
| `process-waitlist-promotion` | Scheduled / trigger | Atomic waitlist promotion |
| `release-room-credentials` | Scheduled / trigger | Time-based credential release |
| `finalize-tournament-results` | API / scheduled | Dispute period expiry → finalize |
| `handle-account-deletion` | API | Cascading user data deletion |
| `export-user-data` | API | GDPR/DPDP data export |

### 4.4 Realtime Usage

| Channel | Use Case |
|---------|----------|
| `tournament:{id}:entries` | Live registration count (organizer dashboard) |
| `match:{id}:credentials` | Credential release notification |
| `notification:{user_id}` | In-app notification delivery |
| `tournament:{id}:results` | Live result updates |

**Not for:** Critical writes (registration, results) — use RPC/functions.

---

## 5. Data Flow Patterns

### 5.1 Registration Flow (Race-Safe)

```
Player/Captain → POST /rpc/register_tournament_entry
    │
    ▼
DB Function (SECURITY DEFINER)
    ├── Lock tournament row (FOR UPDATE)
    ├── Check state = RegistrationOpen
    ├── Check capacity (count confirmed entries)
    ├── Check eligibility (age, region, duplicates)
    ├── Check roster complete (squad)
    ├── Insert entry + entry_members (snapshot)
    ├── If capacity full → insert waitlist (FIFO)
    ├── Release lock
    └── Return entry_id + status (confirmed/waitlist)
    │
    ▼
Trigger → notification event → Edge Function → FCM + In-app
```

### 5.2 Room Credential Release

```
Organizer → POST /rpc/set_match_credentials
    │
    ▼
DB Function
    ├── Verify organizer owns tournament
    ├── Encrypt password (pgcrypto)
    ├── Store in match_room_secrets (restricted)
    └── Schedule release (pg_cron or Edge Function)
    │
    ▼
At release_time:
Edge Function → Update match_room_secrets.released_at
    │
    ▼
Player → GET /rpc/get_match_credentials
    ├── Verify confirmed entry for tournament
    ├── Verify release_time passed
    ├── Decrypt password
    └── Return credentials + audit log
```

### 5.3 Result Finalization

```
Organizer → POST /rpc/submit_provisional_results
    │
    ▼
DB Function
    ├── Verify organizer owns tournament
    ├── Insert result_submissions (pending)
    └── Schedule dispute_period_end
    │
    ▼
Player → POST /rpc/submit_dispute (within window)
    ├── Verify confirmed participant
    ├── Insert dispute + evidence
    └── Notify moderator
    │
    ▼
Moderator → POST /rpc/resolve_dispute
    ├── Verify assigned moderator, no conflict
    ├── Update tournament_results (corrected)
    ├── Insert audit record (original, corrected, reason, moderator)
    └── Mark dispute resolved
    │
    ▼
At dispute_period_end (or manual):
POST /rpc/finalize_results
    ├── Verify all disputes resolved
    ├── Set tournament_results.finalized = true
    ├── Set tournament.state = Finalized
    └── Notify participants
```

---

## 6. Security Architecture

### 6.1 Defense in Depth

| Layer | Controls |
|-------|----------|
| **Network** | Supabase managed TLS, no public DB port |
| **Application** | Server-side authz, input validation (Zod), output encoding |
| **Database** | RLS, constraints, SECURITY DEFINER with checks, audit triggers |
| **Client** | No secrets, token storage in secure enclave (Android Keystore), cert pinning |
| **CI/CD** | Secret scanning, dependency audit, SAST, container scanning |

### 6.2 Key Security Decisions

| Decision | Rationale |
|----------|-----------|
| No separate Node API | Supabase PostgreSQL + Edge Functions sufficient for MVP |
| RLS on every table | Database-enforced authorization; defense in depth |
| Service role only in Edge Functions | Never exposed to clients |
| Encrypted room passwords at rest | `pgcrypto` — even DB admin cannot read plaintext |
| Invitation tokens hashed | `sha256(token)` stored; plaintext never in DB |
| Audit log immutable | Append-only table, no UPDATE/DELETE policies |

---

## 7. Observability

| Signal | Tool | Implementation |
|--------|------|----------------|
| **Logs** | Supabase Logs + Structured logging in Edge Functions | JSON, correlation IDs |
| **Metrics** | Supabase Dashboard + Custom (Prometheus later) | DB performance, auth, function latency |
| **Traces** | OpenTelemetry (future) | Distributed traces across client → Edge → DB |
| **Alerts** | Supabase Webhooks → PagerDuty/Slack | Auth failures, DB errors, function timeouts |
| **Errors** | Sentry (client + server) | Source maps, user context, release tracking |

---

## 8. Deployment Architecture

### 8.1 Environments

| Environment | Purpose | Supabase Project | Domain |
|-------------|---------|------------------|--------|
| **Local** | Development | Docker (supabase start) | localhost |
| **Staging** | Integration testing | Supabase Cloud (separate project) | staging.fft.app |
| **Production** | Live (post-gates) | Supabase Cloud (paid, Mumbai) | fft.app |

### 8.2 CI/CD Pipeline

```
Push to agent/fft-development
    │
    ├── Lint & Type Check (Flutter, Next.js)
    ├── Unit Tests (Flutter, Next.js)
    ├── Integration Tests (Supabase local)
    ├── Security Scan (secrets, deps)
    ├── Build (Android AAB, Next.js production)
    └── Deploy Preview (Vercel for web, manual for mobile)
```

### 8.3 Database Migrations

- **Local:** `supabase db reset` (applies all migrations)
- **Staging/Prod:** `supabase db push` via CI (reviewed migration files)
- **Rollback:** Down migrations tested in CI

---

## 9. Technology Versions (Pinned)

| Component | Version | Source |
|-----------|---------|--------|
| Flutter | 3.47.9 (stable) | flutter.dev |
| Dart | 3.13.7 | Bundled |
| Android Target API | 36 | Google Play requirement |
| Next.js | 16.4.5+ | nextjs.org |
| React | 18.3+ | Bundled with Next.js |
| TypeScript | 5.6+ | Strict mode |
| Node.js | 26 LTS | nodejs.org |
| pnpm | 12.16+ | pnpm.io |
| Supabase CLI | 3.0.0+ | supabase.com |
| Supabase JS | 2.45+ | npm |
| Supabase Flutter | 2.3+ | pub.dev |
| PostgreSQL | 17 (Supabase) | Supabase Cloud |
| Tailwind CSS | 3.4+ | tailwindcss.com |
| shadcn/ui | Latest | shadcn.dev |

---

## 10. Evolution Path (Post-MVP)

| Area | Future Consideration |
|------|---------------------|
| **Separate API Layer** | If Edge Functions become complex; tRPC or Hono on Cloud Run |
| **Event Sourcing** | For audit-heavy domains (results, disputes) |
| **Multi-region** | Read replicas, global tournament support |
| **Real-time Sync** | CRDT for offline-first mobile |
| **Analytics** | ClickHouse/PostHog for product analytics (privacy-first) |