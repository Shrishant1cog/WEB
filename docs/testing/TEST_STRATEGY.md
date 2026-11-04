# Test Strategy — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline for Phase 1-8 implementation

---

## 1. Testing Philosophy

- **Test pyramid:** Many unit, fewer integration, few E2E
- **Shift left:** Security, accessibility, performance in CI
- **Real verification:** No mocking database, auth, or external services in integration tests
- **Evidence-based:** "Tested" = test actually ran and passed in CI
- **Definition of Done:** All relevant tests pass + build succeeds + security scan clean

---

## 2. Test Layers by Component

### 2.1 Flutter Mobile App

| Layer | Tool | Scope | Target Coverage |
|-------|------|-------|-----------------|
| **Unit** | `flutter_test`, `bloc_test`, `mocktail` | Use cases, validators, formatters, Bloc/Cubit logic | >90% |
| **Widget** | `flutter_test` | Individual widgets, forms, screens (with mocked dependencies) | >80% |
| **Integration** | `integration_test` (on device/emulator) | Critical user journeys: auth, registration, team, match access, dispute | 10+ scenarios |
| **Contract** | Generated types from Supabase | API response parsing, RPC return types | 100% |
| **Static Analysis** | `flutter analyze` | All code | 0 errors, 0 warnings |
| **Security** | MASVS checklist, dependency scan | Keystore usage, cert pinning, no secrets | All critical |

### 2.2 Next.js Web App

| Layer | Tool | Scope | Target Coverage |
|-------|------|-------|-----------------|
| **Unit** | Vitest | Utilities, validators, helpers, Server Actions logic | >90% |
| **Component** | React Testing Library | UI components, forms, tables (with mocked Server Actions) | >80% |
| **Integration** | Playwright | Critical journeys: auth, organizer dashboard, admin, public pages | 15+ scenarios |
| **API/Contract** | Vitest + MSW | Server Actions, RPC calls, Supabase client | 100% endpoints |
| **Type Check** | `tsc --noEmit` | All TypeScript | 0 errors |
| **Lint/Format** | ESLint + Prettier | All code | 0 errors |
| **Security** | ASVS checklist, dependency scan | Authz, CSRF, XSS, no secrets | All critical |

### 2.3 Supabase Backend

| Layer | Tool | Scope | Target Coverage |
|-------|------|-------|-----------------|
| **Schema** | `supabase db diff` | Migration validity, reversibility | All migrations |
| **RLS Policies** | pgTAP | Every policy: allow cases + deny cases | 100% policies |
| **RPC Functions** | pgTAP | Business logic, authorization, edge cases | 100% functions |
| **Constraints** | pgTAP | Unique, check, FK, triggers | 100% |
| **Concurrency** | pgTAP + custom SQL | Race conditions (registration, waitlist, promotion) | Critical paths |
| **Migration Test** | `supabase db reset` in CI | Clean apply + rollback | Every PR |
| **Performance** | `EXPLAIN ANALYZE` | Key queries (tournament listing, registration) | <100ms p95 |

---

## 3. Critical Test Scenarios (Must Pass)

### 3.1 Authentication & Authorization

| Scenario | Layer | Expected |
|----------|-------|----------|
| Register → verify email → login → access profile | Mobile + Web E2E | Success |
| Password reset flow | Mobile + Web E2E | Success |
| Unauthenticated user cannot access organizer dashboard | Web E2E | 403/redirect |
| Player cannot access organizer RPC functions | Backend pgTAP | RAISE EXCEPTION |
| Organizer A cannot access Organizer B's tournament | Backend pgTAP | 0 rows |
| Moderator cannot resolve dispute in own tournament | Backend pgTAP | RAISE EXCEPTION |
| Admin cannot read private user fields without audit | Backend pgTAP | Policy denies |

### 3.2 Tournament Registration (Race Conditions)

| Scenario | Layer | Expected |
|----------|-------|----------|
| 100 concurrent solo registrations at capacity 50 | Backend pgTAP (concurrent) | Exactly 50 confirmed, 50 waitlisted |
| 50 concurrent squad registrations at capacity 20 | Backend pgTAP (concurrent) | Exactly 20 confirmed, 30 waitlisted |
| Player registers solo + squad same tournament | Backend pgTAP | Second registration rejected |
| Waitlist promotion on withdrawal | Backend pgTAP | Next waitlisted promoted atomically |
| Double withdrawal attempt | Backend pgTAP | Idempotent, no error |

### 3.3 Room Credentials

| Scenario | Layer | Expected |
|----------|-------|----------|
| Organizer sets credentials, release_at = future | Backend pgTAP | Encrypted stored, not accessible |
| Player calls get_match_credentials before release_at | Backend pgTAP | 403/empty |
| Player calls get_match_credentials after release_at | Backend pgTAP | Returns decrypted credentials |
| Non-participant calls get_match_credentials | Backend pgTAP | 403 |
| Credentials never appear in logs | Log audit | No room_id/password in any log |

### 3.4 Results & Disputes

| Scenario | Layer | Expected |
|----------|-------|----------|
| Organizer submits provisional results | Backend pgTAP | is_provisional=true |
| Player submits dispute within window | Backend pgTAP | Dispute created, moderator assigned |
| Player submits dispute after window | Backend pgTAP | Rejected |
| Moderator resolves with correction | Backend pgTAP | Result corrected, audit recorded |
| Moderator with conflict attempts resolve | Backend pgTAP | RAISE EXCEPTION |
| Finalize with pending disputes | Backend pgTAP | Rejected |
| Finalize after all resolved | Backend pgTAP | is_provisional=false, status=finalized |

### 3.5 Account Deletion

| Scenario | Layer | Expected |
|----------|-------|----------|
| In-app deletion request → email verification → completion | Mobile E2E | Profile anonymized, PII deleted, audit retained |
| Web deletion request → email verification → completion | Web E2E | Same |
| Deletion cancels within 24h | E2E | Request cancelled, no data loss |
| Retention exceptions documented | Backend pgTAP | account_deletion_requests.retention_exceptions populated |

---

## 4. Test Infrastructure

### 4.1 CI Pipeline (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, version: '3.47.9' }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
  
  nextjs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '26', cache: 'pnpm' }
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test
      - run: pnpm build
  
  supabase:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: supabase/postgres:17
        env: { POSTGRES_PASSWORD: postgres }
        ports: [5432:5432]
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - run: supabase db reset --linked=false
      - run: supabase test db --pgtap
  
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: trufflesecurity/trufflehog@v3
      - run: pnpm audit --audit-level=high
      - run: flutter pub outdated --mode=null-safety
```

### 4.2 Local Test Commands

```bash
# Flutter
cd apps/mobile
flutter analyze
flutter test
flutter test integration_test/  # requires emulator/device

# Next.js
cd apps/web
pnpm lint
pnpm typecheck
pnpm test
pnpm test:e2e  # Playwright

# Supabase
supabase db reset
supabase test db
```

---

## 5. Test Data Management

| Environment | Data Source | Isolation |
|-------------|-------------|-----------|
| **Local Dev** | `supabase/seed.sql` (synthetic) | Per-developer Supabase local |
| **CI** | Fresh `supabase db reset` per job | Ephemeral container |
| **Staging** | Subset of production-like synthetic | Separate Supabase project |
| **Production** | Real user data | N/A (no testing in prod) |

**Seed Data Principles:**
- Clearly marked as test (prefix `test_`, emails `@test.fft.local`)
- No real PII, no real game UIDs
- Covers edge cases (boundary values, all statuses)
- Versioned with migrations

---

## 6. Security Testing Requirements

| Test | Frequency | Tool | Gate |
|------|-----------|------|------|
| Secret scanning | Every PR | TruffleHog | Block merge |
| Dependency audit | Every PR | `npm audit`, `flutter pub outdated` | Block on critical |
| RLS policy matrix | Every migration | pgTAP | Block on failure |
| SAST | Weekly | CodeQL | Alert |
| Penetration test | Pre-launch | External firm | Launch gate |
| MASVS verification | Pre-launch | Checklist + tools | Launch gate |
| ASVS verification | Pre-launch | Checklist + tools | Launch gate |

---

## 7. Performance Benchmarks (CI Gates)

| Operation | Target (p95) | Measurement |
|-----------|--------------|-------------|
| Tournament listing (20 items) | <500ms | Playwright / k6 |
| Registration submission | <1s | k6 (concurrent) |
| Room credential retrieval | <300ms | k6 |
| Dashboard load (organizer) | <2s | Playwright |
| Mobile app cold start | <3s | Flutter driver |
| Database migration (full) | <60s | CI timing |

---

## 8. Accessibility Testing

| Standard | Tool | Scope |
|----------|------|-------|
| WCAG 2.1 AA | axe-core (Playwright) | All web pages |
| Material 3 a11y | Flutter a11y test | Mobile screens |
| Color contrast | Automated + manual | Design system |
| Screen reader | Manual (TalkBack, VoiceOver) | Critical flows |
| Keyboard navigation | Manual + axe | Web dashboard |

---

## 9. Test Reporting & Evidence

**Required for each milestone:**
- Test run logs (CI artifacts)
- Coverage reports (lcov, HTML)
- Security scan reports
- Performance benchmark results
- Accessibility audit results
- **Manual verification checklist** signed by engineer

**Definition of "Tested":**
> The specific test case executed in CI, passed, and artifacts archived. Not "looks like it works."

---

## 10. Test Maintenance

| Activity | Frequency | Owner |
|----------|-----------|-------|
| Flaky test quarantine | Weekly | Platform team |
| Coverage threshold increase | Per phase | Tech lead |
| New feature test checklist | Per feature | Feature owner |
| Dependency update testing | Weekly (Dependabot) | DevOps |
| Test data refresh | Per migration | Backend lead |

---

## 11. Phase-Specific Test Deliverables

| Phase | Test Deliverables |
|-------|-------------------|
| **Phase 1** | CI pipeline running, `flutter analyze` clean, `tsc` clean, `supabase db reset` works, seed data loads |
| **Phase 2** | Auth flow E2E (mobile+web), RLS policies for profiles/auth, account deletion flow test |
| **Phase 3** | Tournament CRUD tests, public listing tests, RLS for tournaments |
| **Phase 4** | Registration concurrency tests (k6), waitlist promotion tests, team invitation tests |
| **Phase 5** | Credential encryption/decryption tests, release time enforcement, access control tests |
| **Phase 6** | Dispute workflow tests, result correction audit tests, finalization tests |
| **Phase 7** | Notification delivery tests (in-app + push), admin workflow tests, abuse report tests |
| **Phase 8** | Full regression suite, security test report, accessibility report, performance report, launch readiness checklist |

---

## 12. Tools & Versions (Pinned)

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.47.9 | Mobile framework |
| `flutter_test` | Bundled | Unit/widget/integration |
| `bloc_test` | 9.1.7 | Bloc testing |
| `mocktail` | 1.0.4 | Mocking |
| `integration_test` | Bundled | Device integration |
| Next.js | 16.4.5 | Web framework |
| Vitest | 2.1.8 | Unit/Component testing |
| React Testing Library | 16.0.0 | Component testing |
| Playwright | 1.48.0 | E2E testing |
| MSW | 2.4.0 | API mocking |
| TypeScript | 5.6.3 | Type checking |
| ESLint | 9.13.0 | Linting |
| Prettier | 3.3.3 | Formatting |
| Supabase CLI | 3.0.0 | Backend management |
| pgTAP | 1.3.0 | SQL testing |
| PostgreSQL | 17 | Database (Supabase) |
| TruffleHog | 3.81.0 | Secret scanning |
| CodeQL | Latest | SAST |
| k6 | 0.54.0 | Load testing |