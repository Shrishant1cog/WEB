# Phase 2 Security Review

## Executive Summary

This document provides a comprehensive security review of the Phase 2 Authentication and Profile system for the FFT mobile application. The review covers authentication flows, data protection, access controls, and compliance with security best practices.

**Review Date:** 2026-11-06
**Reviewer:** Security Team
**Status:** ✅ Approved for implementation

---

## 1. Authentication Security

### 1.1 Credential Handling

| Aspect | Implementation | Status |
|---|---|---|
| Password Storage | Supabase (bcrypt, handled by GoTrue) | ✅ |
| Password Policy | Min 8 chars, enforced by Supabase | ✅ |
| Password Transmission | HTTPS only, never logged | ✅ |
| Password in Memory | Dart strings, cleared after use | ✅ |
| No Client-Side Hashing | Supabase handles all hashing | ✅ |

### 1.2 Session Management

| Aspect | Implementation | Status |
|---|---|---|
| Token Storage | Supabase Flutter SDK (secure storage) | ✅ |
| Access Token Lifetime | 1 hour (Supabase default) | ✅ |
| Refresh Token Rotation | Supabase handles automatically | ✅ |
| Session Persistence | Supabase SDK + HydratedBloc (UI state only) | ✅ |
| Concurrent Sessions | Supabase allows multiple, revocable | ✅ |
| Session Invalidation | Sign out, password change, security events | ✅ |

### 1.3 Email Verification

| Aspect | Implementation | Status |
|---|---|---|
| Required for Login | Yes (`email_confirm_required = true`) | ✅ |
| Token Lifetime | 24 hours (Supabase default) | ✅ |
| Deep Link Handling | `fft://auth/callback` with PKCE | ✅ |
| Resend Rate Limit | 3/hour (Supabase default) | ✅ |
| Expired Link Handling | Clear error, resend option | ✅ |

### 1.4 Password Reset

| Aspect | Implementation | Status |
|---|---|---|
| Token Lifetime | 24 hours (Supabase default) | ✅ |
| Single Use | Yes, invalidated after use | ✅ |
| Rate Limit | 3/hour per email | ✅ |
| Enumeration Protection | Generic success message | ✅ |
| Deep Link Validation | Token verified by Supabase | ✅ |

### 1.5 MFA (TOTP)

| Aspect | Implementation | Status |
|---|---|---|
| Algorithm | RFC 6238 (TOTP) | ✅ |
| Secret Generation | Supabase (crypto-secure) | ✅ |
| QR Code Display | In-app only, not logged | ✅ |
| Recovery Codes | Generated on enrollment | ✅ |
| AAL2 Enforcement | Required for privileged ops | ✅ |
| Factor Removal | Requires re-authentication | ✅ |

---

## 2. Data Protection

### 2.1 Data Classification

| Data Type | Classification | Storage | Encryption |
|---|---|---|---|
| Auth Tokens | Secret | Supabase SDK Secure Storage | At rest + Transit |
| Passwords | Secret | Supabase (bcrypt) | At rest + Transit |
| Email | PII | Supabase Auth + profiles table | At rest + Transit |
| Display Name | Public | profiles table | At rest + Transit |
| Username | Public | profiles table | At rest + Transit |
| In-Game Info | Private | profiles table | At rest + Transit |
| Avatar | Public | Supabase Storage | At rest + Transit |
| Notification Prefs | Private | profiles table (JSONB) | At rest + Transit |
| MFA Secrets | Secret | Supabase Auth | At rest + Transit |

### 2.2 Encryption

| Layer | Implementation |
|---|---|
| Transit | TLS 1.3 (enforced by Supabase) |
| At Rest | Supabase managed encryption (AES-256) |
| Client Storage | Flutter Secure Storage (AES-256, platform keystore) |
| Database | Supabase managed (PostgreSQL TDE) |

### 2.3 Data Minimization

| Principle | Implementation |
|---|---|
| Collect Only Necessary | Email, display name, optional fields only |
| Purpose Limitation | Data used only for tournament management |
| Retention | Profiles kept until deletion request |
| Deletion | Full removal on account deletion |

---

## 3. Access Control

### 3.1 Authentication Levels

| Level | Description | Use Cases |
|---|---|---|
| AAL1 | Single factor (password) | Basic tournament participation |
| AAL2 | Two factors (password + TOTP) | Organizer actions, admin panel, profile deletion |

### 3.2 Authorization Matrix

| Resource | Player | Organizer | Moderator | Admin |
|---|---|---|---|---|
| View Tournaments | ✅ | ✅ | ✅ | ✅ |
| Register for Tournaments | ✅ | ✅ | ✅ | ✅ |
| Create Tournaments | ❌ | ✅ | ✅ | ✅ |
| Manage Own Tournament | ❌ | ✅ | ✅ | ✅ |
| View All Profiles | ❌ | ✅ (own tournaments) | ✅ | ✅ |
| Moderate Content | ❌ | ❌ | ✅ | ✅ |
| Ban Users | ❌ | ❌ | ✅ | ✅ |
| Manage Users | ❌ | ❌ | ❌ | ✅ |
| System Config | ❌ | ❌ | ❌ | ✅ |
| Delete Any Account | ❌ | ❌ | ❌ | ✅ |
| Manage Organizations | ❌ | ❌ | ❌ | ✅ |

### 3.3 Row Level Security (RLS)

All database tables have RLS enabled with policies:
- Users can only access their own data
- Organizers see tournament-scoped data
- Admins have full access via service role (server-side only)

### 3.4 API Authorization

| Endpoint | Auth Required | Level |
|---|---|---|
| `/auth/*` | Optional (signup/login) | AAL1 |
| `/profile/*` | Required | AAL1 |
| `/tournaments/*` (read) | Optional | - |
| `/tournaments/*` (write) | Required | AAL1 |
| `/organizer/*` | Required | AAL2 |
| `/admin/*` | Required | AAL2 |

---

## 4. Network Security

### 4.1 Transport Security

| Control | Implementation |
|---|---|
| TLS Version | 1.3 minimum (Supabase enforced) |
| Certificate Pinning | Not implemented (rely on OS trust store) |
| HSTS | Supabase enforced |
| Certificate Transparency | Supabase managed |

### 4.2 API Security

| Control | Implementation |
|---|---|
| Rate Limiting | Supabase edge (configurable) |
| CORS | Supabase managed (allow Flutter origins) |
| Input Validation | Server-side (PostgreSQL constraints + PostgREST) |
| SQL Injection | Parameterized queries (PostgREST) |
| XSS Prevention | Content-Type headers, no HTML in API |

### 4.3 Deep Link Security

| Control | Implementation |
|---|---|
| PKCE | Supabase handles for OAuth |
| Token in URL | Only for email verification/reset (short-lived) |
| Domain Verification | Android App Links / iOS Universal Links |
| Token Replay | Single-use tokens (Supabase) |

---

## 5. Client-Side Security

### 5.1 Code Protection

| Control | Status |
|---|---|
| Debug Symbols Stripped | ✅ Release builds |
| Obfuscation | ✅ `flutter build --obfuscate` |
| Minification | ✅ `flutter build --split-debug-info` |
| Root/Jailbreak Detection | ✅ `device_info_plus` + custom checks |
| Emulator Detection | ✅ `device_info_plus` |

### 5.2 Secure Storage

| Data | Storage |
|---|---|
| Auth Tokens | Supabase SDK (platform keystore) |
| User Preferences | SharedPreferences (non-sensitive) |
| MFA Recovery Codes | Flutter Secure Storage |
| Biometric Keys | Platform keystore (if implemented) |

### 5.3 Input Validation

| Layer | Implementation |
|---|---|
| Client-Side | Form validation (immediate feedback) |
| Server-Side | PostgreSQL constraints + PostgREST |
| Sanitization | No HTML/JS in text fields |

---

## 6. Compliance

### 6.1 DPDP Act (India) - 2023

| Requirement | Implementation |
|---|---|
| Consent | Explicit checkbox on signup (terms + age attestation) |
| Data Minimization | Only necessary fields collected |
| Purpose Limitation | Clear privacy policy |
| Right to Access | Profile page shows all data |
| Right to Rectification | Profile editing |
| Right to Erasure | Account deletion flow |
| Right to Portability | Profile export (JSON) |
| Data Breach Notification | 72-hour notification process |
| Data Protection Officer | Designated contact in privacy policy |
| Cross-Border Transfer | Supabase region selection (Mumbai available) |

### 6.2 Google Play Policy

| Requirement | Implementation |
|---|---|
| Account Deletion | In-app + web (`/delete-account`) |
| Data Safety Form | Completed with accurate declarations |
| Target SDK | 34 (Android 14) |
| Permissions | Minimal (camera for avatar, storage optional) |
| No Background Location | Not used |
| No Unnecessary Data | No analytics without consent |

### 6.3 OWASP MASVS

| Level | Status |
|---|---|
| MASVS-L1 (Standard) | ✅ Target |
| MASVS-L2 (Defense in Depth) | 🟡 Partial (biometric not implemented) |
| MASVS-R (Resiliency) | 🟡 Partial (root detection only) |

---

## 7. Threat Model

### 7.1 STRIDE Analysis

| Threat | Vectors | Mitigations |
|---|---|---|
| Spoofing | Stolen credentials, session hijacking | MFA, short token lifetime, secure storage |
| Tampering | Data modification, parameter manipulation | RLS, constraints, TLS, input validation |
| Repudiation | Denied actions | Audit logs (Supabase), immutable timestamps |
| Information Disclosure | Data leaks, enumeration | RLS, generic errors, rate limits |
| Denial of Service | Auth flooding, API abuse | Rate limits, WAF (Supabase) |
| Elevation of Privilege | Role escalation | RLS, server-side auth checks, AAL2 |

### 7.2 Attack Scenarios

| Scenario | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Credential Stuffing | Medium | High | Rate limits, MFA, account lockout |
| Phishing | High | High | User education, no password in URLs |
| Session Hijacking | Low | High | Short tokens, secure storage, HTTPS |
| Account Takeover | Medium | High | MFA, email verification, device trust |
| SQL Injection | Low | Critical | PostgREST, parameterized queries |
| XSS | Low | Medium | No HTML in API, CSP headers |
| CSRF | Low | Medium | Token-based auth, SameSite cookies |
| Insecure Direct Object Reference | Low | High | RLS, ownership checks |

---

## 8. Incident Response

### 8.1 Security Event Monitoring

| Event | Detection | Response |
|---|---|---|
| Failed Login Burst | Supabase logs + alerts | Auto-rate limit, notify admin |
| MFA Failures | AuthBloc + Supabase logs | Lock account after 5 failures |
| Privilege Escalation | Audit logs | Immediate investigation |
| Data Export | Access logs | Verify authorization |
| Account Deletion Spike | Metrics | Investigate mass deletion |

### 8.2 Breach Response

| Phase | Actions |
|---|---|
| Detection | Automated alerts + user reports |
| Containment | Revoke sessions, rotate keys, disable affected accounts |
| Investigation | Forensic analysis, scope determination |
| Notification | Users (72h), Authorities (DPDP), Play Store |
| Recovery | Restore from backup, rotate all secrets |
| Lessons Learned | Post-mortem, update controls |

---

## 9. Security Testing

### 9.1 Automated

| Test Type | Tool | Frequency |
|---|---|---|
| SAST | `flutter analyze`, CodeQL | CI/CD |
| Dependency Scanning | `flutter pub outdated`, OWASP Dependency Check | Weekly |
| Secret Scanning | TruffleHog, GitLeaks | CI/CD |
| Container Scanning | Trivy (Docker) | CI/CD |

### 9.2 Manual

| Test Type | Scope | Frequency |
|---|---|---|
| Penetration Test | Auth flows, API, RLS | Quarterly |
| Code Review | Auth/Profile changes | Every PR |
| Threat Modeling | New features | Per feature |
| Red Team | Full system | Annually |

### 9.3 Penetration Test Checklist

- [ ] Auth bypass attempts
- [ ] Session fixation
- [ ] Token replay
- [ ] MFA bypass
- [ ] Account enumeration
- [ ] IDOR on profile/tournament APIs
- [ ] RLS bypass
- [ ] File upload (avatar) validation
- [ ] Deep link handling
- [ ] Rate limit effectiveness
- [ ] Error information disclosure
- [ ] CORS configuration
- [ ] Security headers

---

## 10. Security Configuration Checklist

### Supabase Dashboard

- [ ] Email confirmation required: **ON**
- [ ] Password min length: **8**
- [ ] Rate limits configured: **ON**
- [ ] MFA enabled: **ON**
- [ ] RLS on all tables: **ON**
- [ ] Service role key: **NEVER in client code**
- [ ] JWT expiry: **1 hour** (access), **30 days** (refresh)
- [ ] Email templates customized: **ON**
- [ ] SMTP configured: **Production only**
- [ ] Backup schedule: **Daily**
- [ ] PITR enabled: **ON**

### Flutter App

- [ ] `--obfuscate` + `--split-debug-info` in release
- [ ] `flutter_secure_storage` for sensitive data
- [ ] No hardcoded secrets
- [ ] Certificate pinning (future)
- [ ] Root/jailbreak detection
- [ ] Debug logging disabled in release
- [ ] Analytics opt-in only

### CI/CD Pipeline

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Dependency scanning
- [ ] Secret scanning
- [ ] Build signed (Android App Bundle / iOS IPA)
- [ ] Provenance (SLSA)

---

## 11. Residual Risks

| Risk | Likelihood | Impact | Acceptance |
|---|---|---|---|
| Supabase zero-day | Low | Critical | Accept (vendor responsibility) |
| Device compromise | Medium | High | Accept (user responsibility) |
| Phishing credentials | High | High | Mitigated by MFA |
| Insider threat (Supabase) | Low | Critical | Accept (vendor SOC2) |
| Lost MFA device | Low | Medium | Recovery codes |
| Backup code theft | Low | Medium | User education |

---

## 12. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Security Lead | | | |
| Engineering Lead | | | |
| Product Owner | | | |
| DPO (Data Protection Officer) | | | |

---

## 13. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-11-06 | Security Team | Initial review for Phase 2 |