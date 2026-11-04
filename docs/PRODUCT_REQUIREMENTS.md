# Product Requirements — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline — subject to owner decisions

---

## 1. Product Identity

**Name:** FFT (Free Fire Tournament)  
**Tagline:** Independent Free Fire India Tournament Management Platform  
**Disclaimer (mandatory, visible):** "FFT is an independent tournament management platform. It is not affiliated with, endorsed by, or operated by Garena."

---

## 2. User Roles

| Role | Scope | Capabilities |
|------|-------|--------------|
| **Player** | Individual account | Register, profile, browse tournaments, solo/squad registration, team management, match access, results, disputes, notifications, account deletion |
| **Organizer** | Organization-scoped | Create/manage org, create tournaments, configure rules, manage registration, publish announcements, create matches, enter room credentials, record results, review disputes, audit history |
| **Moderator** | Explicitly scoped | Review assigned disputes, finalize results, audited corrections — NO access to tournaments they participate in or have conflicts with |
| **Administrator** | Platform-level | User management, organizer approval/suspension, tournament oversight, platform config, moderator assignment, abuse reports, audit logs, legal notices, operational monitoring |

**Permission Model:** Separate scopes, not single global role column. Account can be Player + Organizer. Organizer cannot enter own tournament. Moderator cannot adjudicate own disputes.

---

## 3. Player-Facing Android Application

### 3.1 Authentication & Account
- Email/password registration with email verification
- Password recovery (secure reset flow)
- Secure session refresh and revocation
- Logout (all devices option)
- Account deletion (in-app + web)

### 3.2 Player Profile
- Display name, avatar (optional upload)
- Free Fire India in-game name + UID (collected only when required for tournament)
- Privacy settings (profile visibility, data sharing)
- Notification preferences
- Tournament history

### 3.3 Tournament Discovery
- Browse available tournaments
- Filter by: status (upcoming/open/live/completed), mode (solo/squad), date range
- View full rules, eligibility, format, prizes (if any — non-monetary), schedule
- Clear "independent platform" disclaimer on every tournament page

### 3.4 Registration
- **Solo:** Individual entry, capacity-controlled, FIFO waitlist
- **Squad:** Team-based entry (captain registers complete roster)
- Eligibility validation (age, region, prior restrictions)
- Duplicate prevention (same tournament, same player)
- Withdrawal where permitted (before registration close, configurable)

### 3.5 Team Management
- Create team (captain = creator)
- Invite players via secure tokenized links (hash stored, expires, rate-limited)
- Accept/decline invitations
- View team roster, captain, membership history
- Leave team (captain transfer if last member)
- Team dissolution

### 3.6 Match Access
- View match schedule for registered tournaments
- Access room credentials (ID + password) ONLY:
  - After organizer-configured release time
  - For confirmed participants only
  - Server-enforced (not frontend-hidden)
- Credentials never logged, never in public APIs

### 3.7 Results & Disputes
- View provisional results
- Submit dispute within configured window (evidence upload: screenshots)
- View dispute status and moderator decision
- View finalized results (immutable history)

### 3.8 Notifications
- In-app notification center (persisted events)
- Push notifications (FCM, after core works)
- Types: registration confirmed, waitlist promoted, match scheduled, credentials released, result published, dispute update, announcement
- Preferences per type (in-app / push / email)

---

## 4. Public Website

- Product information + independence disclaimer (hero)
- Public tournament listing (read-only, no auth required)
- Tournament detail pages (rules, schedule, results)
- Privacy Policy
- Terms of Service
- Support & grievance contact
- Account deletion initiation page (web)
- App download link (when available)
- No fake statistics, reviews, sponsors, player counts

---

## 5. Organizer Dashboard (Authenticated)

### 5.1 Organization Management
- Create organization profile (name, description, contact, logo)
- Manage organization members (invite/remove organizers)
- Organization-scoped permissions

### 5.2 Tournament CRUD
- Create tournament (draft → publish)
- Configure: format (solo/squad), roster size, mode, map, rules text, eligibility
- Set capacity, registration open/close dates
- Publish / close registration / cancel (with audit)
- Clone tournament template

### 5.3 Participant Management
- View registrations (confirmed, waitlist)
- Manual waitlist promotion (if needed)
- View team rosters (squad tournaments)
- Export participant list (CSV, organizer-only)

### 5.4 Match Management
- Create matches (round, bracket, schedule)
- Configure room credential release time per match
- Enter room ID + password (encrypted at rest)
- Release credentials (manual or scheduled)
- View credential access audit log

### 5.5 Results & Disputes
- Enter match results (provisional)
- Publish provisional results
- Review assigned disputes (evidence, player statements)
- Finalize results (with reason if correcting)
- View audit trail for all result changes

### 5.6 Communications
- Create announcements (tournament-scoped)
- Pin critical announcements
- Notification broadcast to participants

---

## 6. Administrator Dashboard (Authenticated, Separate)

- User account management (view, suspend, delete, role audit)
- Organizer approval/suspension workflow
- Tournament oversight (view all, flag issues)
- Platform configuration (global settings, feature flags)
- Moderator assignment (explicit tournament scoping)
- Abuse report management (triage, assign, resolve)
- Audit log review (searchable, exportable)
- Legal/policy notice management
- Operational status monitoring (signups, active tournaments, errors)

---

## 7. Tournament System Rules (Business Logic)

### 7.1 Formats
- **Solo:** Individual players
- **Squad:** 4 active players (configurable preset for Free Fire India)
- Roster size configurable per tournament
- No substitute system in MVP (deferred)

### 7.2 Teams
- Team ID, name, captain, active members, timestamps
- Membership history (immutable)
- Invitation history (token hashes, expiry, rate limits)
- Required roster complete before registration
- Consent required for all joins
- Captain cannot add arbitrary users by guessed UID
- Audit: member add/remove, captain change
- Post-registration roster changes = explicit audited exception only

### 7.3 Registration (Race-Safe)
- Solo capacity = individual entries
- Squad capacity = eligible team entries
- Complete roster required
- Eligibility validated
- Duplicate prevention via DB unique constraints
- Never exceed capacity (DB transaction + locking)
- Idempotent confirmation (no double-confirm on retry)
- Player cannot be in multiple entries same tournament
- Roster snapshot recorded per entry
- Audit on important changes

### 7.4 Acceptance Policy (MVP)
- Default: eligible + capacity = confirmed
- Full = waitlist (FIFO)
- Atomic promotion when capacity frees
- User informed: waitlist promotion = auto-confirmation
- Withdrawal permitted (configurable window)
- Manual pre-approval = deferred

### 7.5 Tournament Lifecycle States
`Draft → Published → RegistrationOpen → RegistrationClosed → Scheduled → [CheckIn] → Live → ProvisionalResults → DisputePeriod → Finalized`
`Cancelled` (from any pre-Live state)

**Transitions:** Verified (actor, permissions, ownership, current state, conditions, valid transition, audit record)

### 7.6 Matches & Room Credentials
- Stored in restricted structure (not in public listings)
- Released only to confirmed eligible participants
- Release time enforced server-side
- Never logged
- Audit: release + authorized retrieval

### 7.7 Results & Disputes Workflow
1. Result entry (organizer)
2. Verification (organizer)
3. Provisional publication
4. Dispute period (configurable, e.g., 2 hours)
5. Dispute submission (player, evidence)
6. Moderator review (assigned, no conflict)
7. Finalization
8. Corrections = explicit reason, original, corrected, moderator, timestamp, immutable audit

---

## 8. Non-Functional Requirements

### 8.1 Security
- RLS on every exposed table
- Least privilege grants
- Server-side validation + authorization
- Rate limits + abuse protection
- Secure invitation tokens (hash stored, expiry)
- Private storage + signed URLs
- No secrets in client bundles or Git
- Immutable audit history
- Dependency vulnerability scanning in CI

### 8.2 Privacy
- Minimize personal data collection
- Document every purpose
- Consent records
- Retention schedule
- Account deletion (complete where appropriate)
- No Aadhaar, gov ID, exact DOB, contacts, broad media access by default
- Screenshots = private evidence, not auto-published

### 8.3 Performance
- Tournament listing: <500ms p95
- Registration submission: <1s p95
- Room credential retrieval: <300ms p95
- Dashboard loads: <2s p95
- Offline-first mobile (cached tournament data)

### 8.4 Accessibility
- WCAG 2.1 AA target
- Semantic HTML, ARIA labels
- Color contrast
- Touch target sizes (mobile)
- Screen reader tested

### 8.5 Reliability
- Database transactions for multi-record ops
- Row locking for capacity operations
- Idempotent API endpoints
- Retry with backoff for external calls
- Health checks for all services

---

## 9. Out of Scope (MVP)

- Social feed, direct messaging, live chat
- Live streaming integration
- Betting, prizes, wallets, payouts
- Automated game data integration (no official API)
- Substitute/bench player system
- Multi-language (English only initially)
- Organizer public marketplace
- Player rankings/leaderboards across tournaments
- Team branding/customization beyond name/logo
- Third-party authentication beyond Google (Apple, etc. — deferred)