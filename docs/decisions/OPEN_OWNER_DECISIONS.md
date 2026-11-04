# Open Owner & Legal Decisions — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** ALL DECISIONS REQUIRED BEFORE PUBLIC LAUNCH

---

## Decision Template

For each decision:
- **Why it matters**: Impact on product, legal, timeline
- **What needs to be decided**: Specific question
- **Recommended option**: Based on research
- **Risks**: Of each option
- **Blocks**: Local dev / Public release / Both

---

## 1. Garena Written Permission

**Why it matters:** Garena ToS restricts commercial use, unauthorized copying, misrepresentation of affiliation. No express third-party tournament license found in research.

**What needs to be decided:**
- Will we seek written permission from Garena for public tournament operations?
- What specific permissions are needed (brand use, UID collection, tournament management)?
- What if permission is denied or not responded to?

**Recommended option:** Seek formal permission via Garena India business development / legal channels. Prepare scope document: "Independent tournament management platform, no game integration, manual UID entry only, clear disclaimer."

**Risks:**
- Permission denied → cannot launch publicly with Free Fire India reference
- No response → launch blocked indefinitely
- Permission granted with restrictive terms → may limit product

**Blocks:** Public release, Google Play submission, any marketing

**Owner:** Legal / Business Development  
**Deadline:** Before Phase 3 completion

---

## 2. Indian Legal Classification (PROG Act 2025)

**Why it matters:** The Promotion and Regulation of Online Gaming Act, 2025 (effective 1 May 2026) and 2026 Rules create registration regimes for e-sports. FFT's classification determines regulatory obligations.

**What needs to be decided:**
- Does FFT "offer, organize, or facilitate online games" under Section 8(3)?
- Does FFT require e-sports registration under 2026 Rules?
- Do no-fee community tournaments fall outside regulation?
- State law applicability (Telangana, Andhra Pradesh, Tamil Nadu, Karnataka, etc.)?

**Recommended option:** Engage qualified Indian gaming law counsel for written opinion. Budget for potential registration/compliance costs.

**Risks:**
- Classified as regulated → registration, compliance costs, ongoing obligations
- Classified as unregulated → regulatory action risk if wrong
- State bans → geo-blocking complexity

**Blocks:** Public release, enabling real tournament operations in production

**Owner:** Legal Counsel (Indian gaming law specialist)  
**Deadline:** Before Phase 3 completion

---

## 3. Minimum Player Age & Minor Consent Policy

**Why it matters:** Garena ToS: <18 requires parental consent for Garena account. DPDP Act: children's data requires verifiable parental consent. Google Play: family policies.

**What needs to be decided:**
- Minimum age for FFT participation (18+ recommended for pilot)
- If <18 allowed: verifiable parental consent mechanism design
- Age verification method (self-declare vs. document vs. third-party)
- Guardian data collection (if any)

**Recommended option:** 18+ for initial closed pilot (configurable flag). Defer <18 until legal review + approved consent design. No government ID collection.

**Risks:**
- 18+ excludes significant player base
- <18 with flawed consent → DPDP violation, Google Play rejection
- Age verification friction → drop-off

**Blocks:** Public release if <18 enabled without approved design  
**Local dev:** Not blocked (configurable flag)

**Owner:** Legal + Product  
**Deadline:** Before Phase 2 completion (auth system)

---

## 4. Public Tournament Operations Before Legal Resolution

**Why it matters:** Legal gates (Garena permission, PROG classification) may take months. Development can continue with synthetic data.

**What needs to be decided:**
- Can we enable real tournament operations in staging/production before all legal gates clear?
- What "real" means: real users, real tournaments, real credentials (no money)
- Soft launch to limited organizers/players?

**Recommended option:** NO real tournament operations in any environment accessible to real users until Gate 1 (Garena) and Gate 2 (Legal classification) clear. Local dev + synthetic data only.

**Risks:**
- Early real operations → regulatory action, Garena legal action
- Delayed real testing → launch bugs
- Organizer frustration → loss of early partners

**Blocks:** Public release, staging with real users  
**Local dev:** Not blocked

**Owner:** Legal + Product  
**Deadline:** Before Phase 3 completion

---

## 5. Tournament Format & Roster Sizes

**Why it matters:** Free Fire India uses 4-player squads. Format affects database schema, registration logic, UI.

**What needs to be decided:**
- Default squad size: 4 (matches Free Fire India)
- Configurable per tournament (2, 3, 4, 5)?
- Solo format: individual only?
- Future formats: duos, custom?

**Recommended option:** 
- Solo: 1 player
- Squad: default 4, configurable 2-6 per tournament (schema supports)
- No duos in MVP (can be squad size 2)

**Risks:**
- Fixed 4 → inflexible if game changes
- Too configurable → complex UI, organizer confusion

**Blocks:** Phase 3 (tournament config) schema finalization  
**Local dev:** Not blocked (use default 4)

**Owner:** Product  
**Deadline:** Phase 3 start

---

## 6. Substitute / Bench Player Policy

**Why it matters:** Real tournaments allow substitutes. Affects roster validation, registration, match eligibility.

**What needs to be decided:**
- Allow substitutes in MVP? (Currently: max_substitutes = 0)
- If yes: max count, when can they play, how registered
- Substitution during match vs between matches

**Recommended option:** MVP = 0 substitutes (DEC-020). Design when organizer requirements justify.

**Risks:**
- 0 substitutes → organizers may not adopt
- Complex rules → delayed MVP

**Blocks:** Phase 4 (registration) if substitutes needed  
**Local dev:** Not blocked

**Owner:** Product + Organizers (feedback)  
**Deadline:** Post-MVP or Phase 4 if demanded

---

## 7. Organizer Verification & Approval Policy

**Why it matters:** Prevent fake tournaments, abuse, spam. Build trust.

**What needs to be decided:**
- Verification level: email only / phone / identity document / business registration
- Approval workflow: auto-approve / manual review / tiered
- Suspension/revocation criteria
- Organizer eligibility: individuals, companies, communities?

**Recommended option:** 
- Phase 1: Email verification + manual admin approval (simple)
- Post-MVP: Tiered (verified badge for identity-verified orgs)
- No gov ID by default (privacy)

**Risks:**
- Too loose → spam tournaments, player trust loss
- Too strict → barrier to entry, fewer organizers

**Blocks:** Phase 3 (organizer dashboard) approval flow  
**Local dev:** Not blocked (mock approval)

**Owner:** Product + Admin  
**Deadline:** Phase 3 start

---

## 8. Tournament Cancellation Policy

**Why it matters:** Organizers may need to cancel. Players need notice, refunds (if paid — N/A), data handling.

**What needs to be decided:**
- Who can cancel: organizer only / admin / auto on conditions
- Notice period required
- Player notification process
- Data retention for cancelled tournaments
- Waitlist handling on cancellation

**Recommended option:**
- Organizer can cancel before `registration_closes_at`
- Admin can cancel anytime
- Auto-cancel if `registration_opens_at` passes with < minimum entries
- Notify all registered players via in-app + email
- Retain data per schedule (3 years)

**Risks:**
- Last-minute cancellation → player frustration
- No cancellation → stuck tournaments

**Blocks:** Phase 3 (tournament lifecycle)  
**Local dev:** Not blocked

**Owner:** Product  
**Deadline:** Phase 3

---

## 9. Waitlist Withdrawal & Promotion Policy

**Why it matters:** Players on waitlist need clarity on auto-promotion, withdrawal rights.

**What needs to be decided:**
- Can waitlisted player withdraw anytime? (Yes)
- Auto-promotion: immediate on spot opening? (Yes, atomic)
- Notification: push + in-app + email?
- Time to confirm after promotion? (Instant confirmation, can withdraw after)
- What if promoted player doesn't respond? (Auto-confirmed, can withdraw)

**Recommended option:**
- Withdraw anytime before promotion
- Atomic FIFO promotion (DEC-010)
- Immediate confirmation on promotion
- Player can withdraw after promotion (standard withdrawal rules)
- Notify via all channels (in-app, push, email)

**Risks:**
- Auto-confirm surprises player → withdrawal spike
- No auto-confirm → capacity unfilled

**Blocks:** Phase 4 (waitlist)  
**Local dev:** Not blocked

**Owner:** Product  
**Deadline:** Phase 4

---

## 10. Match Result Evidence Standards

**Why it matters:** Disputes require evidence. Standards affect storage, review, fairness.

**What needs to be decided:**
- Accepted evidence: screenshots only / video / streaming link / API (none)
- Minimum evidence for dispute acceptance
- Organizer evidence requirements for result entry
- Evidence retention period
- Evidence verification process

**Recommended option:**
- Screenshots (primary) — uploaded to private Storage
- Video links (secondary) — URL stored, not hosted
- Minimum: screenshot showing final scoreboard + room info
- Organizer must enter results with screenshot (enforced in UI)
- Retention: dispute resolution + 3 years

**Risks:**
- Screenshots forgeable → moderator judgment needed
- Video hosting → storage costs, privacy
- No evidence standard → inconsistent dispute outcomes

**Blocks:** Phase 5 (matches) + Phase 6 (disputes)  
**Local dev:** Not blocked

**Owner:** Product + Moderation  
**Deadline:** Phase 5

---

## 11. Dispute Deadlines

**Why it matters:** Balance player protection vs. tournament finality.

**What needs to be decided:**
- Dispute window after provisional results: 1 hour / 2 hours / 4 hours / 24 hours
- Extension for complex disputes
- Moderator response SLA
- Finalization: auto after window + no pending disputes

**Recommended option:** 
- Default: 2 hours (configurable per tournament in `tournament_rules.config.dispute_window_hours`)
- Moderator SLA: 1 hour to acknowledge, 4 hours to resolve
- Auto-finalize if no disputes submitted

**Risks:**
- Too short → legitimate disputes missed
- Too long → delayed finalization, player frustration

**Blocks:** Phase 6 (disputes)  
**Local dev:** Not blocked

**Owner:** Product  
**Deadline:** Phase 6

---

## 12. Data Retention Policy

**Why it matters:** DPDP compliance, storage costs, legal risk.

**What needs to be decided:**
- Retention periods per data category (see PRIVACY_AND_DATA_MAP.md)
- Automated disposal jobs
- Legal hold process
- Backup retention vs. primary retention

**Recommended option:** 
- Implement schedule from PRIVACY_AND_DATA_MAP.md Section 6
- pg_cron / Edge Function cron for disposal
- Legal hold: admin flag prevents disposal
- Backups: same retention + 30 days

**Risks:**
- Too long → DPDP violation, storage cost
- Too short → legal exposure, audit gaps

**Blocks:** Phase 8 (production readiness)  
**Local dev:** Not blocked

**Owner:** Legal + Engineering  
**Deadline:** Phase 7

---

## 13. Support & Grievance Contact

**Why it matters:** DPDP requires grievance officer. Google Play requires support contact.

**What needs to be decided:**
- Grievance officer: name, email, phone (published in Privacy Policy)
- Support channels: email / in-app form / chat (future)
- Response SLA: 24h / 48h / 72h
- Escalation path
- Language support: English / Hindi / regional

**Recommended option:**
- Grievance officer: designated individual (legal requirement)
- Support: in-app form → email ticketing (Phase 7)
- SLA: 48h acknowledgment, 7 days resolution
- English + Hindi initially

**Blocks:** Google Play submission, DPDP compliance  
**Local dev:** Not blocked

**Owner:** Legal + Operations  
**Deadline:** Phase 7

---

## 14. Hosting & Email Provider

**Why it matters:** Production infrastructure decisions affect cost, compliance, reliability.

**What needs to be decided:**
- Web hosting: Vercel (recommended for Next.js) / Netlify / AWS / GCP / Azure
- Email: SendGrid / Mailgun / Postmark / AWS SES / Resend / Supabase SMTP
- Mobile distribution: Google Play only / direct APK / both
- Monitoring: Sentry / Datadog / Grafana Cloud
- Budget approval

**Recommended option:**
- Web: Vercel (native Next.js, edge, preview deployments)
- Email: Resend or Postmark (developer-friendly, good deliverability)
- Mobile: Google Play (primary), direct APK for testing
- Monitoring: Sentry (free tier sufficient for MVP)

**Risks:**
- Vercel cost at scale
- Email deliverability issues
- Play Store policy changes

**Blocks:** Phase 7 (production infra)  
**Local dev:** Not blocked (local Supabase, localhost)

**Owner:** Engineering + Finance  
**Deadline:** Phase 7

---

## 15. Production Backup & Recovery Expectations

**Why it matters:** Data loss tolerance, RTO/RPO requirements.

**What needs to be decided:**
- RPO (Recovery Point Objective): 1 hour / 24 hours / 0 (sync)
- RTO (Recovery Time Objective): 1 hour / 4 hours / 24 hours
- Backup frequency: continuous (PITR) / daily / hourly
- Backup retention: 7 days / 30 days / 90 days
- DR region: same / different (multi-region)
- Restore testing frequency

**Recommended option:**
- Supabase PITR (Point-in-Time Recovery) — RPO ~1s, RTO ~minutes
- Daily logical backups to S3-compatible (30 day retention)
- DR: Not multi-region for MVP (cost)
- Restore test: Monthly (automated)

**Risks:**
- Single region → regional outage = downtime
- No DR test → unknown RTO

**Blocks:** Phase 7 (production)  
**Local dev:** Not blocked

**Owner:** Engineering + Operations  
**Deadline:** Phase 7

---

## 16. Production Budget & Infrastructure Approval

**Why it matters:** Real costs for Supabase Pro, Vercel Pro, email, monitoring, domain, SSL.

**What needs to be decided:**
- Monthly budget cap
- Supabase plan: Pro ($25/mo) / Team ($599/mo) / Enterprise
- Vercel plan: Pro ($20/mo) / Enterprise
- Email volume estimate → provider tier
- Domain: fft.app / fft.in / other
- Contingency for scaling

**Recommended option:**
- Start: Supabase Pro, Vercel Pro, Resend Pro (~$100-150/mo)
- Scale up as needed
- Owner approval for >$500/mo

**Blocks:** Phase 7 (production deployment)  
**Local dev:** Not blocked

**Owner:** Finance + Engineering  
**Deadline:** Phase 7

---

## 17. Public Launch & Google Play Submission Approval

**Why it matters:** Final gate. All previous decisions + legal gates + quality gates must clear.

**What needs to be decided:**
- Launch date target
- Launch scope: open to all / invite-only / waitlist
- Marketing plan (or none)
- Play Store listing: screenshots, description, privacy policy URL
- Rollout: staged (10%, 50%, 100%) or full
- Post-launch support plan

**Recommended option:**
- Invite-only beta (organizers + players) for 4 weeks
- Staged rollout on Play Store
- No paid marketing (organic/community)
- Dedicated support for first 30 days

**Risks:**
- Launch bugs → reputation damage
- Legal gate missed → removal from Play Store
- Scale issues → downtime

**Blocks:** PUBLIC LAUNCH (final gate)  
**All previous gates must be CLEARED**

**Owner:** Product + Legal + Engineering + Owner  
**Deadline:** Phase 8 complete + all gates cleared

---

## Decision Tracking

| # | Decision | Status | Owner | Target Date |
|---|----------|--------|-------|-------------|
| 1 | Garena Permission | ❌ Pending | Legal/BD | Pre-Phase 3 |
| 2 | Legal Classification | ❌ Pending | Legal | Pre-Phase 3 |
| 3 | Minimum Age | 🔄 18+ default | Legal/Product | Phase 2 |
| 4 | Real Ops Before Legal | 🔄 No | Legal/Product | Phase 3 |
| 5 | Tournament Formats | ✅ 4-player squad default | Product | Phase 3 |
| 6 | Substitutes | 🔄 Deferred | Product | Post-MVP |
| 7 | Organizer Verification | 🔄 Manual approval | Product/Admin | Phase 3 |
| 8 | Cancellation Policy | 🔄 Drafted | Product | Phase 3 |
| 9 | Waitlist Policy | 🔄 Drafted | Product | Phase 4 |
| 10 | Evidence Standards | 🔄 Drafted | Product/Mod | Phase 5 |
| 11 | Dispute Deadlines | 🔄 2h default | Product | Phase 6 |
| 12 | Data Retention | 🔄 Drafted | Legal/Eng | Phase 7 |
| 13 | Grievance Contact | 🔄 Pending | Legal/Ops | Phase 7 |
| 14 | Hosting/Email | 🔄 Vercel/Resend | Eng/Finance | Phase 7 |
| 15 | Backup/DR | 🔄 PITR + daily | Eng/Ops | Phase 7 |
| 16 | Budget | 🔄 ~$150/mo start | Finance/Eng | Phase 7 |
| 17 | Launch Approval | ❌ All gates required | All | Phase 8+ |

---

## Process for Resolving Decisions

1. **Owner reviews** this document
2. **Legal counsel** provides written opinions for Gates 1-2
3. **Product** proposes options with trade-offs for product decisions
4. **Engineering** estimates implementation impact
5. **Owner makes decision** → recorded here with date + rationale
6. **Implementation proceeds** with decision as constraint

**Do not block local development** on unresolved decisions. Use recommended options as defaults, make configurable where possible.