# Security Policy — FFT

## Supported Versions

| Version | Supported |
|---------|-----------|
| Pre-release (MVP development) | ✅ Security fixes applied to `agent/fft-development` |
| Future releases | Will be documented |

## Reporting a Vulnerability

**Do not create public GitHub issues for security vulnerabilities.**

### Reporting Channel

Email: **security@fft.app** (or create a private GitHub Security Advisory)

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Affected components (mobile, web, backend)
- Suggested fix (if any)

### Response Timeline

| Severity | Acknowledgment | Fix Target |
|----------|----------------|------------|
| Critical (RCE, auth bypass, data exposure) | 24 hours | 72 hours |
| High (privilege escalation, IDOR) | 48 hours | 1 week |
| Medium (info disclosure, weak validation) | 1 week | 2 weeks |
| Low (minor issues) | 2 weeks | Next release |

## Security Architecture Summary

### Authentication & Authorization

- **Supabase Auth**: Email/password + Google OAuth, JWT with RS256
- **Row Level Security**: Enforced on ALL exposed PostgreSQL tables
- **Permission Model**: Scope-based (player, organizer, moderator, admin) — not single role
- **Session Management**: Short-lived JWT (1hr), rotating refresh tokens, revocation on logout
- **MFA**: TOTP support planned (post-MVP)

### Data Protection

- **Encryption at Rest**: Supabase managed (AES-256), pgcrypto for room credentials
- **Encryption in Transit**: TLS 1.3 everywhere, certificate pinning (mobile)
- **Secrets Management**: Supabase Vault / GitHub Secrets / Vercel Env — never in code
- **Key Rotation**: 90-day rotation for service keys, 180-day for encryption keys

### Application Security

- **Input Validation**: Zod (web), Freezed validators (mobile), PostgreSQL constraints
- **Output Encoding**: React auto-escape, no `dangerouslySetInnerHTML`
- **Rate Limiting**: Auth endpoints, registration, invitations, credential access
- **CSP**: Strict Content Security Policy headers
- **Cookies**: httpOnly, Secure, SameSite=Lax
- **CORS**: Restricted to known origins

### Backend Security

- **No Service Role in Clients**: Only in Edge Functions with auth verification
- **SECURITY DEFINER Functions**: Fixed search_path, explicit role checks, input validation
- **Audit Logging**: Immutable `audit_events` table, triggers on sensitive operations
- **Credential Storage**: Encrypted at rest, time-gated release, access audited

### Mobile Security (MASVS Aligned)

- **Secure Storage**: `flutter_secure_storage` (Android Keystore)
- **Certificate Pinning**: Planned for production
- **Anti-Tamper**: Play Integrity API (planned)
- **No Secrets in Binary**: Verified by CI secret scan
- **Network Security Config**: Cleartext traffic blocked

### Web Security (ASVS Aligned)

- **Server Components**: Private data never in shared cache
- **Server Actions**: Authorization checks on every mutation
- **Middleware**: Auth validation on protected routes
- **Dependency Scanning**: `npm audit` + CodeQL in CI

## Compliance

| Standard | Status |
|----------|--------|
| OWASP ASVS 5.0 | Targeting Level 2 (pre-launch verification) |
| OWASP MASVS | Targeting Level 2 (pre-launch verification) |
| DPDP Act 2025 | Privacy by design, consent management, DSR workflows |
| Google Play Account Deletion | In-app + web flow implemented |

## Security Testing

### Automated (CI)

- Secret scanning: TruffleHog on every PR
- Dependency audit: `npm audit`, `flutter pub outdated`
- SAST: CodeQL (TypeScript, Dart)
- RLS Policy Tests: pgTAP matrix (allow + deny)
- Concurrency Tests: Registration race conditions

### Manual (Pre-Launch)

- Penetration testing (external firm)
- MASVS verification checklist
- ASVS verification checklist
- Threat model review

## Vulnerability Disclosure

We follow coordinated disclosure:
1. Report received → acknowledged within SLA
2. Investigation → fix developed
3. Fix tested → deployed to development
4. Fix deployed to production (with owner approval)
5. Public disclosure (after fix deployed + reasonable time)
6. Credit given to reporter (if desired)

## Security Contacts

- **Security Team**: security@fft.app
- **Grievance Officer** (DPDP): grievance@fft.app
- **General Support**: support@fft.app

## Bug Bounty

No formal bug bounty program at this time. Responsible disclosure acknowledged in release notes (with permission).

---

**Last Updated:** 5 November 2026  
**Next Review:** Pre-launch