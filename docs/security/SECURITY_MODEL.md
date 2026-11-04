# Security Model — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline security architecture

---

## 1. Threat Model Summary (STRIDE)

| Threat | Mitigation |
|--------|------------|
| **Spoofing** | Supabase Auth (email/password + Google), JWT verification, MFA (future), device binding |
| **Tampering** | RLS, DB constraints, SECURITY DEFINER functions with validation, signed URLs, HTTPS/TLS |
| **Repudiation** | Immutable audit_events (append-only), signed JWTs, FCM delivery receipts |
| **Information Disclosure** | RLS on all tables, encrypted credentials (pgcrypto), private storage, no secrets in clients, minimal logging |
| **Denial of Service** | Rate limits (API, auth, invitations), capacity enforcement, FCM quotas, Supabase managed scaling |
| **Elevation of Privilege** | Least-privilege roles, scope-based permissions, no service-role in clients, function security checks |

---

## 2. Authentication Architecture

### 2.1 Supabase Auth Configuration

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Providers** | Email/Password (primary), Google (secondary) | Email = universal, Google = convenience |
| **Email Verification** | Required | Prevent fake accounts, DPDP consent |
| **Password Requirements** | Min 12 chars, entropy check | NIST 800-63B aligned |
| **MFA** | TOTP (optional, post-MVP) | Defense in depth |
| **Session JWT Expiry** | 1 hour (access), 30 days (refresh) | Balance security/UX |
| **Refresh Token Rotation** | Enabled | Detect token theft |
| **Refresh Token Reuse Detection** | Enabled (revoke all sessions) | Security best practice |
| **PKCE** | Enforced | OAuth 2.0 security |
| **Rate Limits** | Auth: 10 req/min/IP, 50 req/hr/user | Abuse prevention |

### 2.2 Client Token Storage

| Platform | Storage | Protection |
|----------|---------|------------|
| **Flutter (Android)** | `flutter_secure_storage` (Keystore) | Hardware-backed, encrypted |
| **Next.js (Web)** | httpOnly, Secure, SameSite=Lax cookies | XSS protection, CSRF mitigation |

### 2.3 Session Validation

```typescript
// Server-side (Next.js middleware, Server Actions)
const supabase = createServerClient()
const { data: { user }, error } = await supabase.auth.getUser()
// Always use getUser() not getSession() for authorization
```

```dart
// Flutter: Supabase Flutter SDK handles refresh automatically
// For sensitive operations, call RPC which verifies auth.uid()
```

---

## 3. Authorization Model

### 3.1 Permission Scopes (Not Single Role)

```
┌─────────────────────────────────────────────────────────────┐
│                    PLATFORM PERMISSIONS                      │
├─────────────────────────────────────────────────────────────┤
│  Player Capabilities (all authenticated users)              │
│  ├── Browse tournaments                                      │
│  ├── Register for tournaments                                │
│  ├── Create/manage teams                                     │
│  ├── Submit disputes                                         │
│  ├── Manage own profile, notifications, account deletion    │
│  └── View own tournament history                             │
├─────────────────────────────────────────────────────────────┤
│  Organizer Permissions (organization-scoped)                │
│  ├── Create/manage organization (owner/admin)               │
│  ├── Create/manage tournaments (owner/admin)                │
│  ├── Manage participants, matches, results                  │
│  ├── Set room credentials                                    │
│  ├── Publish announcements                                   │
│  └── View org-scoped audit logs                              │
├─────────────────────────────────────────────────────────────┤
│  Moderator Permissions (explicitly scoped)                  │
│  ├── Review assigned disputes only                          │
│  ├── Finalize/correct results (with audit)                  │
│  └── NO access to tournaments they participate in           │
├─────────────────────────────────────────────────────────────┤
│  Admin Permissions (platform-level)                         │
│  ├── User/organizer management                              │
│  ├── Platform configuration                                 │
│  ├── Moderator assignment                                   │
│  ├── Abuse report handling                                  │
│  ├── Full audit log access                                  │
│  └── NO automatic access to private user fields             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Authorization Enforcement Layers

| Layer | Mechanism | Example |
|-------|-----------|---------|
| **Database (RLS)** | Policies on every table | `CREATE POLICY ... USING (auth.uid() = profile_id)` |
| **RPC Functions** | SECURITY DEFINER + explicit checks | `IF NOT is_organizer(auth.uid(), tournament_id) THEN RAISE` |
| **Edge Functions** | Service role + auth verification | `const { data: { user } } = await supabase.auth.getUser()` |
| **Next.js Server** | Middleware + Server Actions | `if (!await canManageTournament(user.id, tournamentId)) throw` |
| **Flutter** | Bloc guards + RPC calls | `if (!state.canRegister) showError()` |

### 3.3 Critical Authorization Rules

1. **Never trust client-supplied IDs** — always use `auth.uid()` in RLS/functions
2. **Organizer ≠ unlimited access** — scoped to their organization's tournaments
3. **Moderator conflict check** — `NOT EXISTS (SELECT 1 FROM tournament_entries WHERE tournament_id = $1 AND profile_id = moderator_id)`
4. **Admin least privilege** — no `SELECT * FROM profiles` without audit reason
5. **Service role only in Edge Functions** — never in client bundles, never in Git

---

## 4. Row Level Security (RLS) Policy Patterns

### 4.1 Standard Patterns

```sql
-- Owner-only (profiles, device_tokens, notifications)
CREATE POLICY "owner_select" ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Organization-scoped (tournaments, matches, teams in tournament)
CREATE POLICY "org_member_select" ON tournaments FOR SELECT
  USING (
    status IN ('published','registration_open','registration_closed','scheduled','live','provisional_results','dispute_period','finalized')
    OR EXISTS (
      SELECT 1 FROM organizer_memberships om
      WHERE om.organization_id = tournaments.organization_id
      AND om.profile_id = auth.uid()
      AND om.accepted_at IS NOT NULL
    )
  );

-- Participant-scoped (entries, results, credentials)
CREATE POLICY "participant_select" ON tournament_entries FOR SELECT
  USING (
    profile_id = auth.uid()                    -- solo player
    OR team_id IN (                            -- squad member
      SELECT team_id FROM team_memberships
      WHERE profile_id = auth.uid() AND is_active
    )
    OR EXISTS (                                -- organizer
      SELECT 1 FROM organizer_memberships om
      JOIN tournaments t ON t.organization_id = om.organization_id
      WHERE t.id = tournament_entries.tournament_id
      AND om.profile_id = auth.uid()
      AND om.accepted_at IS NOT NULL
    )
  );
```

### 4.2 Restricted Tables (No Direct SELECT)

```sql
-- match_room_secrets: NO RLS policies for SELECT
-- Access ONLY via SECURITY DEFINER function
REVOKE ALL ON match_room_secrets FROM authenticated, anon;
GRANT SELECT, INSERT, UPDATE ON match_room_secrets TO service_role;
```

---

## 5. Data Protection

### 5.1 Encryption at Rest

| Data | Method | Key Management |
|------|--------|----------------|
| **Room credentials** | `pgcrypto` (`encrypt()`, `decrypt()`) | Key in Supabase Vault / environment variable |
| **Database** | Supabase managed (AES-256) | Cloud provider KMS |
| **Storage** | Supabase managed (SSE-S3) | AWS KMS / GCP KMS |
| **Backups** | Encrypted by Supabase | Cloud provider KMS |

### 5.2 Encryption in Transit

| Channel | Protocol | Verification |
|---------|----------|--------------|
| Client ↔ Supabase | TLS 1.3 | Certificate pinning (mobile) |
| Client ↔ Next.js | TLS 1.3 | HSTS, cert pinning |
| Next.js ↔ Supabase | TLS 1.3 | Internal network |
| Edge Functions ↔ External | TLS 1.3 | Certificate validation |

### 5.3 Secrets Management

| Secret | Location | Rotation |
|--------|----------|----------|
| Supabase Service Role Key | GitHub Actions secrets, Vercel env, Supabase Vault | 90 days |
| JWT Secret | Supabase managed | Automatic |
| pgcrypto Key | Supabase Vault | 180 days |
| FCM Server Key | GitHub Actions secrets, Vercel env | 90 days |
| SMTP Credentials | Supabase Vault, Vercel env | 90 days |
| Sentry DSN | GitHub Actions secrets, Vercel env | As needed |

**NEVER in:** Client code, Git history, logs, error reports

---

## 6. Input Validation & Output Encoding

### 6.1 Validation Layers

| Layer | Tool | Scope |
|-------|------|-------|
| **Client (Flutter)** | `freezed` + custom validators | UX, early rejection |
| **Client (Next.js)** | `zod` schemas + `react-hook-form` | UX, early rejection |
| **Server (Next.js Actions)** | `zod` parse | Authorization boundary |
| **Database (PostgreSQL)** | CHECK constraints, domain types | Last line of defense |
| **RPC Functions** | Explicit `IF ... THEN RAISE` | Business logic validation |

### 6.2 Output Encoding

| Context | Method |
|---------|--------|
| **HTML (Next.js)** | React auto-escapes; `dangerouslySetInnerHTML` banned |
| **JSON API** | `jsonb_build_object` / Supabase returns safe JSON |
| **SQL** | Parameterized queries only (Supabase client, RPC) |
| **Shell/Logs** | Structured JSON logging, no interpolation |

---

## 7. Rate Limiting & Abuse Protection

### 7.1 API Rate Limits (Supabase/Edge Functions)

| Endpoint | Limit | Window |
|----------|-------|--------|
| Auth (signup, login, reset) | 10 | minute/IP |
| Auth (email verification) | 3 | hour/email |
| Tournament registration | 5 | minute/user |
| Team invitation creation | 10 | hour/user |
| Team invitation acceptance | 20 | hour/user |
| Dispute submission | 3 | hour/user |
| Credential access | 10 | minute/user |
| Notification preferences | 30 | minute/user |

### 7.2 Database-Level Protection

```sql
-- Trigger-based rate limiting for invitations
CREATE OR REPLACE FUNCTION check_invitation_rate_limit()
RETURNS TRIGGER AS $$
DECLARE
  recent_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO recent_count
  FROM team_invitations
  WHERE invited_by = NEW.invited_by
    AND created_at > NOW() - INTERVAL '1 hour';
  IF recent_count >= 10 THEN
    RAISE EXCEPTION 'Rate limit: max 10 invitations per hour';
  END IF;
  
  SELECT COUNT(*) INTO recent_count
  FROM team_invitations
  WHERE invited_by = NEW.invited_by
    AND created_at > NOW() - INTERVAL '24 hours';
  IF recent_count >= 50 THEN
    RAISE EXCEPTION 'Rate limit: max 50 invitations per day';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 8. Audit & Accountability

### 8.1 Immutable Audit Log

```sql
-- audit_events table: append-only
CREATE POLICY "audit_insert_only" ON audit_events FOR INSERT
  WITH CHECK (false); -- Only via SECURITY DEFINER functions/triggers

CREATE POLICY "audit_select_actor" ON audit_events FOR SELECT
  USING (actor_id = auth.uid() OR is_admin(auth.uid()));

-- Trigger on sensitive tables
CREATE TRIGGER audit_tournament_changes
  AFTER INSERT OR UPDATE OR DELETE ON tournaments
  FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

### 8.2 Audited Operations

| Operation | Audit Fields |
|-----------|--------------|
| Tournament state change | old_status, new_status, actor, timestamp |
| Registration/withdrawal | entry_id, tournament_id, actor, roster_snapshot |
| Credential set/release/access | match_id, actor, action (set/release/access), NO password |
| Result submission/correction | result_id, old_values, new_values, moderator, reason |
| Dispute resolution | dispute_id, resolution, corrected_values, moderator |
| Team membership changes | team_id, profile_id, action (add/remove/role), actor |
| Account deletion | profile_id, retention_exceptions, completion_status |

---

## 9. Security Testing Requirements

### 9.1 Automated Tests (CI)

| Test Type | Coverage | Tool |
|-----------|----------|------|
| **RLS Policy Tests** | Every policy: allow + deny cases | pgTAP / Supabase CLI test |
| **RPC Authorization** | Valid caller, invalid caller, edge cases | pgTAP |
| **IDOR Attempts** | Cross-user access to entries, teams, credentials | Integration tests |
| **Rate Limit Enforcement** | Exceed limits → 429 | Load test (k6) |
| **Secret Scanning** | No secrets in repo | TruffleHog, GitLeaks |
| **Dependency Audit** | Known vulnerabilities | `npm audit`, `flutter pub outdated` |
| **SAST** | Code patterns | CodeQL (GitHub Advanced Security) |

### 9.2 Manual Security Review (Pre-Launch)

- Penetration test (auth, tournament ops, credential flow)
- OWASP ASVS 5.0 Level 2 verification
- MASVS verification (mobile)
- Third-party dependency review

---

## 10. Incident Response

### 10.1 Detection

| Signal | Alert |
|--------|-------|
| Auth failure spike | >50 failures/min → PagerDuty |
| RLS policy violation attempts | >10/min → Slack + PagerDuty |
| Edge Function errors | >5% error rate → PagerDuty |
| Database connection pool exhaustion | >80% → PagerDuty |
| Unusual data access patterns | ML-based (future) |

### 10.2 Response Playbook

1. **Contain**: Revoke compromised tokens, disable affected functions
2. **Assess**: Query audit_events, determine scope
3. **Notify**: Legal, users (if PII exposed), authorities (DPDP 72hr)
4. **Remediate**: Patch, rotate secrets, deploy fix
5. **Post-mortem**: Document, improve detection

---

## 11. Compliance Mapping

| Requirement | Implementation |
|-------------|----------------|
| **DPDP Consent** | consent_records table, granular purposes, revocation |
| **DPDP Data Principal Rights** | export_user_data(), initiate_account_deletion() RPCs |
| **DPDP Breach Notification** | 72-hour alerting, incident response playbook |
| **Google Play Account Deletion** | In-app + web flow, account_deletion_requests tracking |
| **OWASP ASVS 5.0** | Architecture aligned, test coverage planned |
| **MASVS** | Mobile-specific controls (keystore, cert pinning, anti-tamper) |

---

## 12. Security Checklist (Per Feature)

- [ ] Threat model updated
- [ ] RLS policies written + tested (allow/deny)
- [ ] RPC functions use SECURITY DEFINER + explicit checks
- [ ] No service-role key in client code
- [ ] Input validation at all layers
- [ ] Rate limits configured
- [ ] Audit events for sensitive operations
- [ ] Secrets in vault/env, not code
- [ ] Dependency scan clean
- [ ] Secret scan clean
- [ ] Penetration test scope includes feature