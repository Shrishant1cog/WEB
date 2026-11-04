# Research Baseline — FFT

**Date:** 5 November 2026  
**Status:** Verified against primary/official sources as of this date

---

## 1. Free Fire India

### Official Sources

| Topic | URL | Accessed |
|-------|-----|----------|
| Official announcement | https://ffindia.garenaind.com/en/article/1191/ | 5 Nov 2026 |
| India Terms of Service | https://content.garena.com/legal/tos/india_tos_en.html | 5 Nov 2026 |
| Google Play listing | https://play.google.com/store/apps/details?id=com.garena.game.ffi | 5 Nov 2026 |

### Key Facts

- **Launch date:** 28 October 2026
- **Product:** India-specific standalone game (not Free Fire MAX)
- **Squad size:** Four-player squads (per Play Store listing)
- **Account age requirement:** Users below 18 require parental/legal guardian permission for Garena account creation
- **IP rights:** Garena retains all intellectual property rights over game and content
- **Commercial use:** Garena terms restrict commercial use of its Services
- **Unauthorized use:** Terms restrict unauthorized copying, redistribution, automated access, and misrepresentation of affiliation

### Implementation Constraints

- ✅ Build for Free Fire India specifically
- ✅ Do not assume account compatibility between game editions
- ✅ Never collect Garena passwords, OTPs, login tokens, or credentials
- ✅ In-game UID/name collected only when necessary with disclosed purpose
- ✅ No scraping, reverse-engineering, or automated unauthorized access
- ✅ No claim of official tournament API existence
- ✅ No integration based on undocumented endpoints
- ✅ Tournament rooms and results managed manually by authorized organizers
- ✅ No reproduction of game artwork or UI
- ⚠️ **Launch Blocker:** Written Garena permission and qualified legal review required before public launch

---

## 2. Indian Online Gaming Regulation

### Official Sources

| Topic | URL | Accessed |
|-------|-----|----------|
| Promotion and Regulation of Online Gaming Act, 2025 | https://www.indiacode.nic.in/bitstream/123456789/22148/1/a2025-32.pdf | 5 Nov 2026 |
| 2026 Rules Summary (PIB) | https://www.pib.gov.in/PressReleasePage.aspx?PRID=2254606 | 5 Nov 2026 |

### Key Facts

- **Act commencement:** 1 May 2026
- **E-sport definition:** Specific requirements including organized multiplayer competition, recognition and registration
- **Section 8(3):** Persons offering, organizing, or facilitating online games must comply with applicable directions, orders, guidelines, codes
- **2026 Rules:** Registration regime for games intended as e-sports and other notified categories

### Critical Limitations

- ❌ Do NOT conclude every tournament-management website automatically requires e-sports registration
- ❌ Do NOT conclude no-fee tournaments automatically fall outside regulation
- ⚠️ **Legal classification of FFT's exact activities must be reviewed by qualified Indian counsel**

### Required Behavior

- ✅ Keep real tournament operations disabled in production until legal launch gate cleared
- ✅ Allow synthetic local test data and local development
- ✅ Do not claim FFT is a registered e-sport or officially recognized platform
- ✅ Do not design payment, stake, betting, prize, or payout capability
- ✅ Record legal classification question in explicit launch-blocker document

---

## 3. DPDP Act and Rules

### Official Sources

| Topic | URL | Accessed |
|-------|-----|----------|
| Gazette notification | https://egazette.gov.in/WriteReadData/2025/267647.pdf | 5 Nov 2026 |
| MeitY DPDP Rules page | https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa | 5 Nov 2026 |

### Staged Commencement Dates

| Date | Provision |
|------|-----------|
| 13 November 2025 | Initial provisions commenced |
| 13 November 2026 | One-year commencement provisions |
| 13 May 2027 | Main 18-month commencement provisions |

### Key Compliance Position

- ❌ Do NOT claim all substantive DPDP obligations were enforceable on 5 Nov 2026
- ✅ Design system for upcoming obligations now (privacy by design)

### Privacy by Design Requirements

- ✅ Collect only necessary personal data
- ✅ Document every data collection purpose
- ✅ Provide understandable privacy notices
- ✅ Record consent where required
- ✅ Support correction and deletion workflows
- ✅ Apply retention limits
- ✅ Restrict staff access
- ✅ Protect data in transit and at rest
- ✅ Maintain data-processing inventory
- ✅ Prepare breach handling and incident documentation
- ✅ Keep user information out of logs
- ✅ Review every third-party SDK for its data collection

### Data Collection Restrictions

- ❌ No Aadhaar, government identity documents by default
- ❌ No exact birth dates by default
- ❌ No guardian documents by default
- ❌ No advertising SDKs or unnecessary analytics
- ✅ **Conservative product decision:** 18+ access policy for initial closed pilot (configurable)
- ✅ Age policy is a product decision, NOT a claim about statutory minimum age

---

## 4. Google Play Requirements

### Official Sources

| Topic | URL | Accessed |
|-------|-----|----------|
| Target API requirements | https://support.google.com/googleplay/android-developer/answer/11926878 | 5 Nov 2026 |
| Account deletion policy | https://support.google.com/googleplay/android-developer/answer/13327111 | 5 Nov 2026 |

### Requirements (as of research snapshot)

- ✅ New apps/updates must target Android API 36 or higher
- ✅ Apps creating user accounts must provide in-app account deletion
- ✅ Must provide external web resource for initiating account deletion
- ✅ Data safety declaration and privacy policy must match actual behavior

### Implementation Requirements

- ✅ Target API 36+
- ✅ Build complete account deletion flow (in-app + web)
- ✅ Provide public account deletion web page
- ✅ Document data retention exceptions clearly
- ✅ Maintain accurate permissions inventory
- ✅ Use Android system Photo Picker instead of broad photo/file permissions
- ✅ Prepare Play Store policy checklist
- ❌ Do NOT submit app without explicit approval

---

## 5. Technology Architecture Baseline

### Android Player Application

- Flutter stable (3.47.9+)
- Dart bundled with selected SDK
- Android target API 36+
- Supabase Flutter client
- Material 3
- Layered architecture (presentation, domain, data, API/auth, local config, test)
- Repository-based data access
- Strong typing, immutable UI state
- No database queries in widgets

### Organizer/Admin Dashboard

- Next.js 16.4.5+ (patched stable)
- TypeScript strict mode
- App Router
- Supabase JS client + SSR integration
- Responsive desktop/tablet/mobile

### Runtime

- Node.js 26 Active LTS

### Backend & Database

- Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime)
- Region: Mumbai `ap-south-1` (preferred, subject to plan)
- Row Level Security mandatory on every exposed table
- Versioned SQL migrations as source of truth
- Database functions for critical transactional workflows
- Service-role keys never exposed to clients

### Authentication

- Email/password + email verification + password recovery (core)
- Optional Google sign-in (after core tested)
- Custom SMTP required for production (Supabase default limited)

### Storage

- Private Supabase Storage buckets
- Validate file size, type, content (not just filename/MIME)
- Authenticated short-lived signed URLs
- Rate limits on upload/storage

### Push Notifications

- Firebase Cloud Messaging (after core works)
- In-app notifications first
- Backed by persisted notification events + retry handling
- No success notification before DB transaction commits

---

## 6. Open Questions Requiring Owner/Legal Decision

See [OPEN_OWNER_DECISIONS.md](docs/decisions/OPEN_OWNER_DECISIONS.md) for the complete list including:

1. Written Garena permission for public operations/assets/integrations
2. Indian legal classification under PROG Act and Rules
3. Minimum player age and minor-consent policy
4. Public tournament support before legal resolution
5. Tournament format and roster sizes
6. Substitute policy
7. Organizer verification/approval policy
8. Tournament cancellation policy
9. Waitlist withdrawal/promotion policy
10. Match result evidence standards
11. Dispute deadlines
12. Data retention policy
13. Support/grievance contact
14. Hosting and email provider
15. Production backup/recovery expectations
16. Production budget/infrastructure approval
17. Public launch and Google Play submission approval