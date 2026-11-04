# Security, compliance and deployment specification

## 1. Security threat model

### Assets and trust boundaries
Assets: identity tokens, player profile/game identifiers, organizer legal/KYC/beneficiary refs, room credentials, tournament rules/rosters, payment and ledger records, evidence/results, cloud secrets and audit history. Boundaries: client/API; Firebase/authorization; organizer tenant; API/PSP; webhook; API/object storage; API/worker; cloud/DB/secrets; organizer/winner.

| Threat | Required control |
|---|---|
| Broken object-level authorization | Scope every read/write by actor + organizer/tournament; negative cross-tenant tests |
| Privilege escalation | DB-backed role assignments, no client trust, MFA, audited grants |
| Account takeover/token theft | Firebase controls, rate limits, secure cookies/Keystore, session revocation |
| Fake/replayed webhook | Raw-body signature check, replay/event uniqueness, idempotency |
| Payment race | DB locks, unique constraints and transactional outbox |
| SQL injection | Prisma parameterization, raw SQL review, least-privilege DB identity |
| Secret exposure | Secrets Manager/KMS; never source/client bundle/log |
| Room password leak | Envelope encryption, just-in-time scoped retrieval, no caching/logging |
| Evidence malware/privacy leak | File type/size limits, scanning, private bucket, short signed URL |
| Data exfiltration | Least privilege, audit, exports restricted, moderator isolation |
| Admin abuse | Immutable audit, MFA, maker-checker, break-glass alerts |
| Supply-chain compromise | Lockfiles, dependency scanning, pin Actions to reviewed commit SHAs |
| DDoS/abuse | CDN/WAF, rate limits, circuit breakers |
| Score tampering | Versioned rules, server calculation, golden test vectors |
| Prize fraud | Evidence status separate from bank/PSP verified status |

### Baseline
OWASP ASVS-aligned web/API review and MASVS-aligned mobile review; TLS; KMS-managed encryption; private DB; least-privilege IAM/DB roles; separate app/migration/report roles; secret rotation; cloud audit; backup restore drills; incident response; vulnerability disclosure; privacy/retention plan.

Never log passwords, OTPs, Firebase tokens, cookies, UPI PINs, banking/card credentials, PSP secrets, room passwords or sensitive raw webhook payloads. Log IDs, masked refs, hashes and request IDs.

Incidents must preserve evidence, revoke sessions/secrets, disable affected feature gates, notify accountable owners and follow legal reporting. Never “fix” financial incidents by editing journal history.

## 2. India legal and publisher compliance gates

This is an engineering risk register, not legal advice or a conclusion that paid tournaments are lawful.

### Promotion and Regulation of Online Gaming Act, 2025 / Rules, 2026
The statutory esports definition contains cumulative requirements, including multi-sports event context; organized multiplayer competition under predefined rules; recognition under the National Sports Governance Act, 2025 and registration with the relevant Authority/agency; skill-determined outcomes; registration/participation fee solely for competition entry or administrative cost and performance-based prizes; and no bets, wagers or other stakes.

The 2026 Rules were announced as effective 1 May 2026 and establish a determination/registration/safety framework. Determination factors include fees/stakes, expected winnings, revenue model and reward monetization.

**Project impact:** This is an independent one-game tournament marketplace. Do not assume it qualifies. Indian gaming counsel must assess exact title/event/platform/organizer/service-provider/fee/commission/prize funding/payment flow, and determine which parties need determination, recognition or registration. Obtain written opinion/clarification and required approvals before paid entry or cash prizes. If the structure is prohibited, do not launch it. Do not create bets, wagers, stakes, participant-funded pooled prize, deposits or wallet workarounds.

### Google Play
Google Play Developer Program Policy reviewed 2026-11-04 showed an effective date of 29 October 2026 and prohibits most other real-money tournament/contest apps from enabling or facilitating payment/stakes for real-world prizes. Examples include buttons, navigation and webviews inviting cash-prize tournament registration. Evaluate a separate free-only Play build. Do not hide the paid flow behind external links, browser, QR or webview to bypass policy. Direct APK is not an exemption from Indian law, Garena terms, PSP policy or privacy obligations.

### Garena / Free Fire India
Current India Terms of Service provide a limited personal-use license and restrict commercial use of Game/Services/Content. Obtain written Garena permission for commercial tournament operations and any use of marks, artwork, screenshots, gameplay footage or promotion. Independent branding is not permission and does not imply affiliation. Do not claim official partnership without written evidence.

### Privacy, age, consumer and tax
Counsel must review the DPDP Act/rules/commencement applicable at launch, processors, data transfers, deletion/retention, child data, breach notifications, consumer/refund rights, age assurance, tax and grievance obligations. Garena India terms state that under-18 users need parent/guardian permission for a Garena account. Define platform eligibility and guardian process; do not admit minors to paid events until counsel approves the lawful process.

Prepare privacy notice, player terms, organizer agreement, tournament-specific rules, cancellation/refund policy, prize terms/funding source/payment deadline, grievance contact, tax invoice treatment, dispute/appeal policy and evidence retention rules.

### Feature gates (false by default; organizer cannot change)

\`\`\`env
PAID_REGISTRATION_ENABLED=false
ORGANIZER_SETTLEMENT_ENABLED=false
CASH_PRIZE_FEATURES_ENABLED=false
ESPORTS_DETERMINATION_APPROVED=false
ESPORTS_REGISTRATION_CONFIRMED=false
GARENA_COMMERCIAL_PERMISSION_CONFIRMED=false
PAYMENT_PROVIDER_UNDERWRITING_APPROVED=false
PLAY_STORE_PAID_FEATURES_APPROVED=false
\`\`\`

Activation requires evidence reference, scope, approver, expiry/review date, controlled deployment and audit. Phase 0 paid launch status: **BLOCKED / NOT APPROVED**.

## 3. Payment provider approval checklist

Cashfree Easy Split is first technical discovery candidate; Razorpay Route is an alternative. Neither is approved. Provider must confirm in writing:
- Exact India esports/tournament business category.
- Marketplace commission and merchant-of-record model.
- Organizer/sub-merchant onboarding/KYC.
- Hosted payment link with exact amount.
- Dynamic UPI QR with exact amount.
- Both methods compatible with the same split settlement model.
- UPI VPA versus bank account payout availability, limits and beneficiary verification.
- Refunds, chargebacks, post-settlement adjustment and recovery.
- Webhook events and transaction/settlement reports.
- Fees, taxes, reserves, settlement window and negative-balance handling.
- Whether the selected prize model creates any additional restrictions.

If neither provider approves, paid features stay disabled. Do not misdescribe category or use static QR/manual transfer as workaround.

## 4. Deployment proposal (not provisioned)

Separate development, staging and production cloud resources, Firebase projects, PostgreSQL databases, object-storage buckets, Redis, domains and provider credentials. Use synthetic data outside production; never copy production PII into staging.

Proposed initial cloud region: AWS Mumbai \`ap-south-1\`, subject to actual regional availability, cost, processor contracts and data-transfer review.
- NestJS API containers on ECS/Fargate behind HTTPS load balancer.
- Separate BullMQ worker service.
- RDS PostgreSQL Multi-AZ with encrypted backup and point-in-time recovery.
- ElastiCache Redis private subnet.
- S3 private bucket for evidence/organizer documents, KMS encryption, lifecycle rules, signed URLs.
- CloudFront/WAF for static delivery and edge protection.
- KMS and Secrets Manager for keys/secrets.
- CloudWatch metrics/logs/alarms; select tracing/error vendor after cost review.
- Firebase Authentication and FCM; review data processor and region terms.
- Next.js on AWS-managed runtime or reviewed host after data/operations review.

Only the load balancer is public. API/worker/database/Redis stay in private networks. Use TLS, least-privilege IAM task roles, separate migration/app/report roles, no public database endpoint, signed URLs and envelope encryption for room secrets.

## 5. CI/CD and operations

GitHub Actions should run:
- Phase 0 documentation validator.
- When code exists: formatting, lint, typecheck, unit/integration/contract tests.
- Secret and dependency scanning.
- Build and artifact provenance.
- Staging deployment after reviewed merge.
- Production only from protected branch/tag with manual environment approval.

Pin third-party Actions to reviewed full commit SHAs before production. Prefer OIDC short-lived cloud credentials, not long-lived repository keys. Protect main and require PR reviews for payment/auth/ledger/migrations.

Prisma migrations are serialized and reviewed; require backup and rollback plan before destructive change. Test backup restore, monitor DB connection/lag/storage/slow query, set budget alerts for compute/database/Redis/storage/egress/logs/OTP/monitoring/backups.

## 6. Source register (reviewed 2026-11-04; recheck before launch)

- [PROG Act, 2025 — MeitY PDF](https://www.meity.gov.in/static/uploads/2025/10/8a7f103cefc68ed8aaa2ebc9a2ed7c13.pdf)
- [PROG Rules 2026 — PIB/MeitY release, 22 April 2026](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2254606&lang=1&reg=3&v=4)
- [MeitY Act/corrigenda page](https://www.meity.gov.in/documents/guidelines/promotion-and-regulation-of-online-gaming-act-2025-and-its-corrigenda-kTMxQjMtQWa)
- [Google Play Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/18265346)
- [Garena Free Fire India Terms of Service](https://content.garena.com/legal/tos/india_tos_en.html)
- [Cashfree Easy Split](https://www.cashfree.com/easy-split/split-payment-gateway/)
- [Cashfree dynamic UPI QR](https://www.cashfree.com/upi-for-business/)
- [Cashfree Payment Links](https://www.cashfree.com/payment-links/)
- [Razorpay Route](https://razorpay.com/route/)
- [Razorpay Payment Links](https://razorpay.com/payment-links/)
- [Razorpay partnership/collection facilitation terms](https://razorpay.com/partnership-services-and-collection-facilitation-agreement/)

Product pages indicate potential technical capabilities, not underwriting approval. No written legal, Garena, PSP or Play approval exists. Future approvals record reviewer, exact policy version/date, written evidence, scope and expiry/review date.
