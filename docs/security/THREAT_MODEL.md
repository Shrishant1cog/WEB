# Threat Model — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Methodology:** STRIDE + PASTA elements  
**Scope:** Player app, Organizer/Admin dashboard, Supabase backend

---

## 1. System Boundary Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TRUST BOUNDARIES                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐         ┌──────────────────────────────────────────┐    │
│  │   PLAYER     │         │           ORGANIZER/ADMIN                │    │
│  │  (Untrusted) │         │           (Semi-Trusted)                 │    │
│  │  Flutter App │         │           Next.js Web App                │    │
│  └──────┬───────┘         └────────────────────┬─────────────────────┘    │
│         │                                        │                        │
│         │ HTTPS/TLS 1.3                          │ HTTPS/TLS 1.3          │
│         ▼                                        ▼                        │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                     SUPABASE PLATFORM (Trusted)                    │  │
│  │  ┌──────────┐  ┌────────┐  ┌──────────┐  ┌────────────────────┐  │  │
│  │  │  Auth    │  │  DB    │  │ Storage  │  │  Edge Functions    │  │  │
│  │  │  (JWT)   │  │ (RLS)  │  │(Private) │  │  (Service Role)    │  │  │
│  │  └──────────┘  └────────┘  └──────────┘  └────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│         │                                        │                        │
│         ▼                                        ▼                        │
│  ┌──────────────┐         ┌──────────────────────────────────────────┐  │
│  │  FIREBASE    │         │           EXTERNAL SERVICES              │  │
│  │    FCM       │         │  SMTP, Monitoring, Backup Storage        │  │
│  └──────────────┘         └──────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Asset Inventory

| Asset | Classification | Location | Protection |
|-------|----------------|----------|------------|
| User credentials (hashed) | Critical | Supabase Auth | Bcrypt, managed |
| JWT signing key | Critical | Supabase | Managed, rotated |
| Room credentials (plaintext) | Critical | match_room_secrets (encrypted) | pgcrypto, Vault key |
| In-game UIDs | PII | profiles, entry_members | RLS, encryption at rest |
| Email addresses | PII | auth.users, profiles | RLS, TLS |
| Device tokens | PII | device_tokens | RLS, user-controlled |
| Audit logs | Operational | audit_events | Append-only, 7yr retention |
| Consent records | Legal | consent_records | RLS, immutable |
| Tournament results | Operational | tournament_results | RLS, audit on change |

---

## 3. STRIDE Analysis by Component

### 3.1 Authentication (Supabase Auth)

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Spoofing** | Credential stuffing | High | High | Rate limits, MFA (future), breach detection |
| **Spoofing** | Phishing for credentials | Medium | High | No password in logs, email verification required |
| **Tampering** | JWT algorithm confusion | Low | Critical | Supabase managed, RS256 only |
| **Info Disclosure** | Email enumeration via auth endpoints | Medium | Medium | Generic error messages, rate limits |
| **DoS** | Auth endpoint flooding | Medium | Medium | Supabase managed rate limits, WAF |

### 3.2 Player Mobile App

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Spoofing** | Stolen device + session | Low | Medium | Secure storage (Keystore), short JWT expiry, refresh rotation |
| **Spoofing** | Reverse engineering API | Medium | Low | No secrets in app, all authz server-side |
| **Tampering** | Modified APK bypassing checks | Medium | Medium | Play Integrity API (future), server-side validation |
| **Info Disclosure** | Logcat/analytics leakage | Low | Medium | No PII in logs, debug builds only |
| **Elevation** | Exploit Flutter framework | Low | High | Dependency scanning, pinned versions |

### 3.3 Organizer/Admin Web App

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Spoofing** | Session hijacking (XSS) | Medium | High | httpOnly cookies, CSP, no dangerouslySetInnerHTML |
| **Spoofing** | CSRF on state-changing actions | Low | High | SameSite=Lax, Supabase SSR validates origin |
| **Tampering** | IDOR: access other org's tournament | Medium | High | RLS + Server Action authorization checks |
| **Tampering** | Parameter pollution in RPC calls | Low | Medium | Zod validation, Postgres parameterized |
| **Info Disclosure** | Cached private data in CDN | Medium | Medium | No caching for authenticated routes, Cache-Control |
| **Elevation** | Organizer escalates to admin | Low | Critical | Platform roles in DB, not client metadata |

### 3.4 Database (PostgreSQL + RLS)

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Spoofing** | SQL injection via RPC params | Low | Critical | Parameterized queries only, no dynamic SQL |
| **Tampering** | Direct table access bypassing RLS | Low | Critical | RLS enabled on ALL tables, service role restricted |
| **Tampering** | Race condition in registration | Medium | High | FOR UPDATE locking in SECURITY DEFINER functions |
| **Info Disclosure** | Over-permissive RLS policy | Medium | High | Policy test matrix (allow/deny), least privilege |
| **Info Disclosure** | Backup/restore exposure | Low | Medium | Encrypted backups, access-controlled storage |
| **Elevation** | SECURITY DEFINER function flaw | Medium | Critical | Fixed search_path, input validation, explicit role checks |

### 3.5 Room Credential System

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Info Disclosure** | Credentials leaked before release | Medium | High | Encrypted at rest, release_at enforced, no early SELECT |
| **Info Disclosure** | Credentials in logs/error reports | Low | Critical | Never log passwords, structured error codes only |
| **Tampering** | Organizer modifies credentials after release | Low | High | released_at immutable, audit trail |
| **Spoofing** | Player guesses credential retrieval | Low | Medium | RPC verifies confirmed entry + release time |

### 3.6 Notification System (FCM + In-App)

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Spoofing** | Fake push notifications | Low | Medium | FCM server key secret, app validates payload |
| **Info Disclosure** | PII in push payload | Medium | Medium | Minimal data in push (deep link only), full content in-app |
| **DoS** | Notification spam | Low | Medium | Rate limits, user preferences, unsubscribe |

### 3.7 Storage (Supabase Storage)

| Threat | Scenario | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| **Info Disclosure** | Public bucket misconfiguration | Low | High | All buckets private, signed URLs only |
| **Info Disclosure** | Signed URL leakage | Low | Medium | Short expiry (1hr), single-use where possible |
| **Tampering** | Malicious file upload | Medium | Medium | Size limit, MIME validation, virus scan (future) |
| **Elevation** | Path traversal in file names | Low | High | Sanitized filenames, UUID storage paths |

---

## 4. Attack Trees (Critical Paths)

### 4.1 Unauthorized Tournament Registration

```
Goal: Register for tournament without eligibility
├── Bypass client validation
│   └── Mitigated: Server-side RPC validates all rules
├── Exploit race condition at capacity boundary
│   └── Mitigated: FOR UPDATE lock in register_tournament_entry()
├── Forge another user's registration
│   └── Mitigated: RPC uses auth.uid(), not client-supplied profile_id
├── Register multiple times (solo + squad)
│   └── Mitigated: Partial unique index + trigger prevents dual entry
└── Register after registration_closes_at
    └── Mitigated: RPC checks tournament.status + registration_closes_at
```

### 4.2 Early Room Credential Access

```
Goal: Get room ID/password before release_at
├── Direct SELECT on match_room_secrets
│   └── Mitigated: NO RLS SELECT policy, REVOKE from authenticated
├── Call get_match_credentials() early
│   └── Mitigated: RPC checks released_at IS NOT NULL
├── Intercept organizer setting credentials
│   └── Mitigated: TLS 1.3, set_match_credentials() encrypts immediately
├── Access via organizer account compromise
│   └── Mitigated: MFA (future), audit log, short session expiry
└── Database backup/restore exposure
    └── Mitigated: Encrypted backups, pgcrypto key not in backup
```

### 4.3 Result Manipulation

```
Goal: Alter tournament results without detection
├── Direct UPDATE tournament_results
│   └── Mitigated: RLS prevents direct UPDATE, only via RPC
├── Compromise moderator account
│   └── Mitigated: Conflict check, audit trail with old/new values
├── Compromise organizer account
│   └── Mitigated: Organizer can only submit provisional, not finalize
├── Exploit dispute resolution
│   └── Mitigated: resolve_dispute() requires moderator assignment + no conflict
└── Delete audit records
    └── Mitigated: audit_events append-only, no DELETE policy
```

---

## 5. Data Flow Threats (DFD Level 1)

```
External Entity: Player
    │
    ▼
Process: Player App (Flutter)
    │  Threats: Tampering (modified app), Info Disclosure (logs)
    ▼
Data Flow: HTTPS API Calls (Supabase REST/RPC)
    │  Threats: Spoofing (stolen token), Info Disclosure (MITM)
    ▼
Process: Supabase Auth
    │  Threats: Spoofing (credential stuffing), DoS
    ▼
Process: PostgreSQL (RLS + RPC)
    │  Threats: All STRIDE (see 3.4)
    ▼
Data Store: Tables (profiles, entries, credentials, results)
    │  Threats: Info Disclosure, Tampering, Elevation
    ▼
Process: Edge Functions (notifications, deletion, credentials)
    │  Threats: Elevation (service role misuse), Info Disclosure
    ▼
External Entity: Firebase FCM
    │  Threats: Spoofing (fake push), Info Disclosure (payload)
```

---

## 6. Risk Register (Top 10)

| ID | Risk | Likelihood | Impact | Score | Status | Owner |
|----|------|------------|--------|-------|--------|-------|
| R1 | RLS policy misconfiguration exposes PII | Medium | Critical | 20 | 🔄 Testing | Backend |
| R2 | Race condition allows over-registration | Medium | High | 15 | 🔄 Testing | Backend |
| R3 | Room credentials leaked before match | Low | Critical | 15 | 🔄 Design review | Backend |
| R4 | Organizer IDOR accesses other org data | Medium | High | 15 | 🔄 Testing | Full-stack |
| R5 | Service role key exposed in client build | Low | Critical | 15 | ✅ Prevented | DevOps |
| R6 | Account deletion incomplete (data remnants) | Medium | High | 15 | 🔄 Design | Backend |
| R7 | Moderator conflict of interest not detected | Low | High | 10 | 🔄 Design | Backend |
| R8 | Push notification PII exposure | Medium | Medium | 10 | 🔄 Design | Mobile |
| R9 | Dependency vulnerability in supply chain | Medium | Medium | 10 | 🔄 CI/CD | DevOps |
| R10 | Legal classification blocks launch | High | Critical | 25 | ⚠️ Legal gate | Legal |

**Scoring:** Likelihood (Low=1, Medium=3, High=5) × Impact (Medium=5, High=10, Critical=20)

---

## 7. Security Test Cases (Mapping to Risks)

| Test Case | Risk | Method | Expected Result |
|-----------|------|--------|-----------------|
| RLS: Player cannot SELECT other player's profile | R1 | pgTAP | 0 rows returned |
| RLS: Organizer cannot SELECT other org's tournaments | R1, R4 | pgTAP | 0 rows returned |
| RPC: register_tournament_entry rejects duplicate | R2 | pgTAP | Unique violation / waitlist |
| RPC: register_tournament_entry respects capacity | R2 | Concurrency test (k6) | Exactly capacity confirmed |
| RPC: get_match_credentials denies before release_at | R3 | pgTAP | 403/empty |
| RPC: get_match_credentials allows after release_at | R3 | pgTAP | Returns decrypted credentials |
| Audit: credential access logged without password | R3 | pgTAP | audit_events row, no password |
| IDOR: Player A cannot access Player B's team invite | R4 | Integration test | 403/404 |
| Secret scan: No service role key in mobile/web build | R5 | TruffleHog/GitLeaks | Clean |
| Account deletion: All PII tables processed | R6 | Integration test | PII anonymized, audit retained |
| Moderator: resolve_dispute rejects conflict | R7 | pgTAP | RAISE EXCEPTION |
| Push payload: No email, UID, PII | R8 | Code review + test | Only notification_id + deep link |
| Dependency scan: No critical CVEs | R9 | npm audit / flutter pub outdated | Clean |

---

## 8. Security Requirements Traceability

| Requirement | Source | Implementation | Test |
|-------------|--------|----------------|------|
| SR-01: All tables have RLS | SECURITY_MODEL | Migration 007 | pgTAP policy tests |
| SR-02: No service role in clients | SECURITY_MODEL | Build config, CI scan | Secret scan |
| SR-03: Credentials encrypted at rest | THREAT_MODEL | pgcrypto + Vault | Decrypt test |
| SR-04: Registration race-safe | THREAT_MODEL | FOR UPDATE in RPC | Concurrency test |
| SR-05: Audit trail immutable | SECURITY_MODEL | Append-only table, triggers | Delete attempt test |
| SR-06: Account deletion complete | DPDP/Google Play | Edge Function workflow | E2E test |
| SR-07: Rate limits on all public endpoints | THREAT_MODEL | Supabase + DB triggers | Load test |
| SR-08: No PII in logs | SECURITY_MODEL | Structured logging, redaction | Log review |
| SR-09: MFA for organizers/admins | SECURITY_MODEL | Supabase Auth config (post-MVP) | Auth test |
| SR-10: Cert pinning on mobile | MASVS | Flutter native config | Network test |

---

## 9. Residual Risks (Accepted with Mitigation)

| Risk | Reason for Acceptance | Mitigation |
|------|----------------------|------------|
| Supabase platform compromise | Managed service, outside control | Contractual security, data encryption, backup isolation |
| Zero-day in PostgreSQL/Node/Flutter | Unknown unknowns | Dependency scanning, rapid patch deployment, WAF |
| Insider threat (Supabase staff) | Trust boundary | Encryption at rest (customer-managed keys future), audit logs |
| Legal classification changes | Regulatory uncertainty | Configurable tournament enable/disable, legal gate |

---

## 10. Review Cadence

| Review | Frequency | Participants |
|--------|-----------|--------------|
| Threat model update | Per major feature | Lead eng + security |
| RLS policy review | Per migration | Backend lead |
| Dependency audit | Weekly (CI) | DevOps |
| Penetration test | Pre-launch + annual | External firm |
| Incident response drill | Quarterly | All engineers |