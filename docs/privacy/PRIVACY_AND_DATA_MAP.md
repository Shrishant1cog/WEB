# Privacy & Data Map — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Regulatory Baseline:** DPDP Act 2025 (staged commencement), Google Play Account Deletion Policy

---

## 1. Data Processing Inventory

| Data Category | Specific Fields | Purpose | Legal Basis (DPDP) | Retention | Sharing |
|---------------|-----------------|---------|-------------------|-----------|---------|
| **Account Identity** | email, password hash, email_verified | Authentication, account recovery | Contract (ToS) | Account life + 30 days grace | Supabase Auth (subprocessor) |
| **Profile** | display_name, avatar_url, in_game_name, in_game_uid | Tournament participation, organizer contact | Consent (explicit for in-game info) | Account life + 30 days | Organizers (tournament-scoped, with consent) |
| **Device/Session** | device_token, platform, app_version, refresh_token | Push notifications, session management | Legitimate interest (service delivery) | 90 days inactive | Firebase FCM (subprocessor) |
| **Tournament Registration** | tournament_id, team_id, roster_snapshot, status | Tournament operations, capacity mgmt | Contract (registration) | Tournament finalized + 3 years | Organizers, moderators (scoped) |
| **Team Data** | team name, members, invitations | Squad tournament participation | Contract (team creation) | Team disbanded + 1 year | Team members, tournament organizers |
| **Match Credentials** | room_id, password (encrypted) | Match access control | Contract (tournament participation) | Match completed + 30 days | Participants only (after release_at) |
| **Results & Disputes** | rank, score, kills, evidence_urls, resolutions | Competition integrity, dispute resolution | Contract (tournament rules) | Tournament finalized + 3 years | Participants, organizers, moderators |
| **Notifications** | type, title, body, data, read_at | User communication | Legitimate interest | 90 days | None (internal) |
| **Audit Logs** | actor, action, entity, old/new values, metadata | Security, compliance, debugging | Legal obligation (DPDP, security) | 7 years | Admins, legal (if required) |
| **Consent Records** | purpose, granted, version, timestamps | DPDP compliance evidence | Legal obligation | 7 years after revocation | Admins, legal (if required) |
| **Account Deletion** | status, retention_exceptions, timestamps | Deletion workflow, legal compliance | Legal obligation | 7 years after completion | Admins, legal |

---

## 2. Data Flow Map

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────────────────┐
│   PLAYER    │────►│   SUPABASE       │────►│      SUBPROCESSORS              │
│  (Data      │     │   (Controller/   │     │  ┌────────────────────────────┐  │
│   Subject)  │     │    Processor)    │     │  │ Firebase FCM               │  │
└─────────────┘     └────────┬─────────┘     │  │  - Device tokens           │  │
                             │               │  │  - Push payload (minimal)  │  │
                             ▼               │  └────────────────────────────┘  │
                    ┌──────────────────┐     │  ┌────────────────────────────┐  │
                    │   DATABASE       │     │  │ Custom SMTP Provider       │  │
                    │   (PostgreSQL)   │     │  │  - Email address           │  │
                    │   - RLS enforced │     │  │  - Template variables      │  │
                    │   - Encrypted    │     │  └────────────────────────────┘  │
                    │     at rest      │     │  ┌────────────────────────────┐  │
                    └────────┬─────────┘     │  │ Supabase (Hosting)         │  │
                             │               │  │  - All data (Mumbai region)│  │
                             ▼               │  └────────────────────────────┘  │
                    ┌──────────────────┐     │  ┌────────────────────────────┐  │
                    │   STORAGE        │     │  │ Monitoring (Sentry, etc.)  │  │
                    │   (Private       │     │  │  - Error context (no PII)  │  │
                    │    buckets)      │     │  └────────────────────────────┘  │
                    │   - Signed URLs  │     └─────────────────────────────────┘
                    └──────────────────┘
```

**Data Location:** Primary: Mumbai, India (`ap-south-1`) — Supabase project region  
**Backup Location:** Same region (Supabase managed)  
**Log Location:** Supabase logs (region-matched), Sentry (US/EU — no PII configured)

---

## 3. Consent Management

### 3.1 Consent Purposes (Granular)

| Purpose ID | Description | Required? | Default | Revocation Effect |
|------------|-------------|-----------|---------|-------------------|
| `tournament_registration` | Process tournament entries, share with organizers | Yes (core) | Granted on registration | Cannot revoke while active registrations exist |
| `notifications_marketing` | Promotional emails, tournament announcements | No | Denied | Stops marketing emails |
| `analytics` | Product usage analytics (future) | No | Denied | Stops analytics collection |
| `third_party_sharing` | Share data with partners (none currently) | No | Denied | N/A |

### 3.2 Consent Flow

```
Registration → Consent Screen (granular toggles)
    │
    ├── tournament_registration: PRE-SELECTED, cannot deselect (core)
    ├── notifications_marketing: OFF by default
    ├── analytics: OFF by default
    ├── third_party_sharing: OFF by default
    │
    ▼
User confirms → INSERT consent_records (one per purpose)
    │
    ▼
Consent stored with: profile_id, purpose, granted, version, IP, UA
```

### 3.3 Consent Records Schema

```sql
-- See DATA_MODEL.md consent_records table
-- Immutable after grant/revoke (new row per change)
-- Version ties to privacy policy version
```

---

## 4. Data Subject Rights (DPDP / Google Play)

| Right | Implementation | Endpoint |
|-------|----------------|----------|
| **Access** | Export all user data (JSON) | `POST /rpc/export_user_data()` |
| **Correction** | Profile edit in app; organizer data via support | App UI + Support ticket |
| **Erasure** | Account deletion flow (in-app + web) | `POST /rpc/initiate_account_deletion()` |
| **Portability** | Export includes machine-readable JSON | `export_user_data()` |
| **Restriction** | Withdraw from tournaments; disable notifications | App UI |
| **Objection** | Revoke marketing/analytics consent | Privacy settings |
| **Grievance** | Support contact form + escalation | `/support` page, email |

### 4.1 Account Deletion Details

**In-App Flow:**
1. Settings → Delete Account
2. Confirm password + consequences (irreversible, data retention exceptions shown)
3. `initiate_account_deletion()` → request record, verification email

**Web Flow:**
1. `/account-deletion` → enter email
2. Verification link sent
3. Click link → same backend workflow

**Backend Processing (24h cooling-off):**
1. Soft delete: profiles (anonymize), entries (withdraw), teams (disband if captain)
2. Hard delete: device_tokens, notifications, Storage files
3. Retain (documented in `retention_exceptions`): audit_events (7yr legal), consent_records (7yr legal), account_deletion_requests
4. Supabase Auth: `admin.delete_user()` → removes from auth.users
5. Confirmation email sent

**Google Play Compliance:**
- In-app deletion: ✅
- Web deletion: ✅ (`/account-deletion` page)
- Data retention exceptions documented: ✅
- 30-day grace before hard delete: ✅ (cooling-off + processing time)

---

## 5. Data Minimization Practices

| Practice | Implementation |
|----------|----------------|
| **No Aadhaar/gov ID** | Not collected; age = 18+ gate (configurable) |
| **No exact DOB** | Age gate only; no birth date stored |
| **In-game UID optional** | Only collected when tournament requires it |
| **No contacts access** | Android Photo Picker for avatar only |
| **No location permission** | Not requested |
| **No advertising SDKs** | Zero third-party trackers |
| **Minimal push payload** | Only notification_id + deep link; content fetched in-app |
| **Storage: private buckets** | Evidence screenshots never public |
| **Logs: no PII** | Structured JSON, correlation IDs only |

---

## 6. Retention & Disposal Schedule

| Data | Retention Period | Disposal Method | Trigger |
|------|------------------|-----------------|---------|
| Profiles (PII) | Account life + 30 days | Anonymize (display_name='Deleted User', nullify PII) | Account deletion completed |
| Tournament entries | Tournament finalized + 3 years | Hard delete | Time-based job |
| Match credentials | Match completed + 30 days | Hard delete (encrypted rows) | Time-based job |
| Disputes & evidence | Resolution + 3 years | Hard delete | Time-based job |
| Notifications | 90 days | Hard delete | Time-based job |
| Device tokens | 90 days inactive | Hard delete | Cron job |
| Audit events | 7 years | Hard delete | Time-based job (legal) |
| Consent records | 7 years after revocation | Hard delete | Time-based job |
| Account deletion requests | 7 years | Hard delete | Time-based job |

**Automated:** pg_cron jobs or Edge Function cron for disposal

---

## 7. Third-Party Subprocessors

| Subprocessor | Purpose | Data Categories | Location | DPA Status |
|--------------|---------|-----------------|----------|------------|
| **Supabase** | Database, Auth, Storage, Edge Functions, Realtime | All | Mumbai (ap-south-1) | Required |
| **Firebase (Google)** | FCM Push Notifications | Device tokens, minimal push payload | Global (Google infra) | Required |
| **SMTP Provider** (TBD) | Transactional emails (auth, deletion, notifications) | Email address, template vars | TBD | Required |
| **Monitoring** (Sentry) | Error tracking | Error context (no PII configured) | US/EU | Required |
| **Backup Storage** (S3-compatible) | Database backups | Encrypted backups | Same region | Required |

**DPA Requirement:** All subprocessors must have Data Processing Addendum before production use.

---

## 8. Cross-Border Transfer Assessment

| Transfer | Mechanism | Safeguards |
|----------|-----------|------------|
| Firebase FCM | Google Standard Contractual Clauses | Minimal data (token + notification_id), no PII in payload |
| Monitoring (Sentry) | SCC + Supplementary Measures | PII scrubbing configured, no auth tokens in errors |
| SMTP Provider | SCC | Email only, no profile data |

**Note:** Primary data remains in India (Mumbai). Transfers only for specific subprocessors with adequate safeguards.

---

## 9. Security Measures (Privacy-Relevant)

| Measure | Implementation |
|---------|----------------|
| **Encryption at rest** | Supabase managed (AES-256), pgcrypto for credentials |
| **Encryption in transit** | TLS 1.3 everywhere, cert pinning (mobile) |
| **Access control** | RLS + least privilege + service role isolation |
| **Pseudonymization** | UUIDs everywhere, no sequential IDs |
| **Data minimization** | See Section 5 |
| **Retention enforcement** | Automated disposal jobs |
| **Breach detection** | Audit log monitoring, anomaly alerts |
| **Staff access logging** | All admin actions in audit_events |
| **DPIA** | To be completed pre-launch (required for systematic monitoring) |

---

## 10. Privacy Policy & Notices

**Required Documents:**
1. **Privacy Policy** — Full DPDP/Google Play compliant (`/privacy` page)
2. **Terms of Service** — Includes tournament rules, disclaimer (`/terms` page)
3. **Account Deletion Notice** — Explains process, retention exceptions (`/account-deletion` page)
4. **Consent Screen** — Granular, at registration + settings
5. **Cookie/Storage Notice** — Minimal (auth cookies only, no tracking)

**Key Privacy Policy Sections:**
- Data controller identity + contact
- Data categories + purposes + legal bases
- Subprocessors + locations
- Retention periods
- Data subject rights + how to exercise
- Grievance officer contact (DPDP requirement)
- International transfers
- Security measures
- Children's data (18+ policy)
- Changes to policy + notification

---

## 11. Compliance Checklist (Pre-Launch)

- [ ] Privacy Policy published + accessible
- [ ] Terms of Service published + accessible
- [ ] Consent screen implemented (granular, versioned)
- [ ] Account deletion in-app (tested end-to-end)
- [ ] Account deletion web page (`/account-deletion`)
- [ ] Data export RPC working (`export_user_data`)
- [ ] Consent records stored per purpose
- [ ] Retention jobs configured + tested
- [ ] DPA signed with all subprocessors
- [ ] DPIA completed (if required)
- [ ] Grievance officer designated + contact published
- [ ] Breach notification procedure documented + tested
- [ ] Staff access procedures + logging
- [ ] Google Play Data Safety form matches actual behavior
- [ ] No unauthorized data collection in mobile build
- [ ] Certificate pinning enabled (mobile)
- [ ] Logs verified PII-free

---

## 12. Open Privacy Decisions

See [OPEN_OWNER_DECISIONS.md](../decisions/OPEN_OWNER_DECISIONS.md) for:
- Minimum age policy (18+ default, configurable)
- In-game UID mandatory vs optional per tournament
- Evidence screenshot retention period
- Marketing consent default (currently OFF)
- Analytics implementation (deferred)