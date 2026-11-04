# Legal Launch Gates — FFT

**Status:** ALL GATES MUST BE CLEARED BEFORE PUBLIC LAUNCH  
**Last Updated:** 5 November 2026

---

## Gate 1: Garena Permission ✅ REQUIRED

**Requirement:** Written permission from Garena for:
- Public tournament operations referencing Free Fire India
- Use of any game assets, trademarks, or branding
- Any form of integration (even manual UID collection)

**Status:** ❌ NOT OBTAINED  
**Blocker:** Public launch, Google Play submission, any marketing referencing Free Fire India  
**Evidence Required:** Signed letter/agreement from authorized Garena representative

---

## Gate 2: Indian Legal Classification ✅ REQUIRED

**Requirement:** Qualified Indian legal counsel opinion on:
- Whether FFT's tournament management activities constitute "offering, organizing, or facilitating online games" under PROG Act Section 8(3)
- Whether FFT requires e-sports registration under 2026 Rules
- Whether no-fee community tournaments fall within or outside regulatory scope
- Applicability of state-level gaming laws (Telangana, Andhra Pradesh, Tamil Nadu, etc.)

**Status:** ❌ NOT OBTAINED  
**Blocker:** Public launch, enabling real tournament operations in production  
**Evidence Required:** Written legal opinion from qualified Indian gaming law counsel

---

## Gate 3: DPDP Act Compliance Readiness ✅ REQUIRED

**Requirement:** Demonstrated compliance with DPDP Act obligations effective 13 May 2027:
- Data Protection Impact Assessment (DPIA) if required
- Data Processing Agreement with Supabase (subprocessor)
- Consent management system operational
- Data Principal rights workflows (access, correction, erasure, portability)
- Breach notification procedures tested
- Data retention schedule implemented and enforced
- Children's data handling (if under-18 permitted) — verifiable parental consent

**Status:** 🔄 IN PROGRESS (design phase)  
**Blocker:** Public launch after 13 May 2027  
**Evidence Required:** Compliance checklist sign-off, DPIA report, DPA executed

---

## Gate 4: Age Policy & Minor Safety ✅ REQUIRED

**Requirement:** Documented and implemented policy:
- Minimum age for participation (recommend 18+ for pilot)
- If under-18 permitted: verifiable parental consent mechanism
- Age verification approach (not collecting government ID by default)
- Child safety risk assessment

**Status:** 🔄 CONFIGURABLE (default 18+ for pilot)  
**Blocker:** Public launch if under-18 access enabled without approved design  
**Evidence Required:** Policy document, consent flow implementation, legal review

---

## Gate 5: Google Play Policy Compliance ✅ REQUIRED

**Requirement:** Full compliance before submission:
- Target API 36+ ✅ (build configuration)
- In-app account deletion flow 🔄
- Web-based account deletion page 🔄
- Accurate Data Safety form 🔄
- Privacy policy matching actual behavior 🔄
- No broad storage permissions (use Photo Picker) 🔄
- Content rating questionnaire completed 🔄

**Status:** 🔄 IN PROGRESS  
**Blocker:** Google Play submission  
**Evidence Required:** Play Console pre-launch report, policy checklist sign-off

---

## Gate 6: Security Baseline ✅ REQUIRED

**Requirement:** Security controls implemented and tested:
- RLS policies on all exposed tables with automated tests
- Authentication token verification on all protected routes
- Object-level authorization (no IDOR)
- Rate limiting on all public endpoints
- Secret scanning in CI (no secrets in repo)
- Dependency vulnerability scanning
- OWASP ASVS 5.0 / MASVS alignment review
- Penetration test (or automated security test suite) for auth, tournaments, payments (N/A), credentials

**Status:** 🔄 IN PROGRESS (Phase 1-2)  
**Blocker:** Public launch  
**Evidence Required:** Security test reports, CI pipeline passing, secret scan clean

---

## Gate 7: Operational Readiness ✅ REQUIRED

**Requirement:** Production operations foundation:
- Hosting provider selected and configured (Vercel for web, TBD for mobile distribution)
- Custom SMTP configured and tested for Supabase Auth
- Supabase project on paid plan with Mumbai region (`ap-south-1`)
- Backup and point-in-time recovery verified
- Incident response runbook documented
- On-call escalation defined
- Monitoring/alerting for auth, database, edge functions
- Cost forecasting and budget approval

**Status:** ❌ NOT STARTED  
**Blocker:** Public launch  
**Evidence Required:** Infrastructure diagram, runbooks, budget approval

---

## Gate 8: Owner Approvals ✅ REQUIRED

**Requirement:** Explicit written approval from project owner for:
- Public launch
- Google Play submission
- Production infrastructure spend
- Real tournament operations enablement
- Any partnership or integration announcements

**Status:** ❌ NOT OBTAINED  
**Blocker:** All public-facing actions  
**Evidence Required:** Signed approval record (email/decision log)

---

## Gate Summary

| Gate | Status | Blocks |
|------|--------|--------|
| 1. Garena Permission | ❌ Not obtained | Public launch, Play submission, marketing |
| 2. Legal Classification | ❌ Not obtained | Public launch, real tournaments |
| 3. DPDP Compliance | 🔄 In progress | Launch after 13 May 2027 |
| 4. Age Policy | 🔄 Configurable (18+ default) | Launch if under-18 enabled |
| 5. Google Play Policy | 🔄 In progress | Play submission |
| 6. Security Baseline | 🔄 In progress | Public launch |
| 7. Operational Readiness | ❌ Not started | Public launch |
| 8. Owner Approvals | ❌ Not obtained | All public actions |

---

## Development Continuation Policy

**Local development and synthetic testing may continue while gates are pending.**

The following are explicitly PERMITTED during gate resolution:
- Building and testing all features with synthetic/local data
- Running local Supabase instance
- CI/CD pipeline development
- Documentation updates
- Security test development
- Database migration development

The following are explicitly BLOCKED until relevant gates clear:
- Deploying to production/staging with real user access
- Submitting to Google Play
- Enabling real tournament registration/operations
- Any public marketing or user acquisition
- Spending on production infrastructure without approval