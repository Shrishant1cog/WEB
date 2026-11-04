# System, database and API architecture

## 1. Architecture decision

Use a **modular monolith** for the first production release: one NestJS/TypeScript API and worker deployment, separated domain modules and one managed PostgreSQL database. Do not begin with microservices. This reduces distributed-transaction complexity for slot reservations, payment confirmation, ledger posting and registration.

## 2. Logical topology

\`\`\`mermaid
flowchart TB
  PW[Player web - Next.js]
  AP[Admin portal - Next.js]
  OP[Organizer portal - Next.js]
  MA[Android - Flutter]
  API[NestJS API - modular monolith]
  WK[Background worker - BullMQ]
  DB[(Managed PostgreSQL)]
  RD[(Redis)]
  OS[(Private object storage)]
  FA[Firebase Authentication]
  PSP[Approved payment provider]
  FCM[Firebase Cloud Messaging]
  PW --> API
  AP --> API
  OP --> API
  MA --> API
  PW --> FA
  AP --> FA
  OP --> FA
  MA --> FA
  API --> DB
  API --> RD
  API --> OS
  API --> PSP
  PSP --> API
  DB --> WK
  RD --> WK
  WK --> PSP
  API --> FCM
\`\`\`

### Hostnames (proposed; domain not purchased)

- \`www.<domain>\`: public/player website.
- \`admin.<domain>\`: separate admin login and portal.
- \`organizer.<domain>\`: separate organizer/moderator login and portal.
- \`api.<domain>\`: versioned API.
- Android app calls the API directly.

Admin and organizer websites may share one Next.js codebase and design system, but need separate login routes, navigation, sessions and backend permission checks. Hostname separation is a UX boundary, not a security boundary. Every API call is authorized server-side.

## 3. Technology choices

| Layer | Technology | Reason |
|---|---|---|
| Android | Flutter/Dart | Native Android release and shared UI architecture |
| Web portals | Next.js/TypeScript | Separate portals, server-rendered pages and shared contracts |
| API | NestJS/TypeScript | Modules, validation, guards, background tasks |
| ORM | Prisma | Typed PostgreSQL access and migrations |
| Database | Managed PostgreSQL | Relational integrity and transactions |
| Identity | Firebase Authentication | Email/password and Google across web/mobile |
| Cache/queue | Redis/BullMQ | Non-authoritative cache and async jobs |
| Durable async | PostgreSQL transactional outbox | No business event lost if queue is unavailable |
| Files | Private S3-compatible object storage | Match evidence and organizer documents |
| Realtime | WebSockets | UI updates; API remains source of truth |
| Push | Firebase Cloud Messaging | Android notifications |
| API contract | OpenAPI | Versioned API and generated clients |
| Tests | Jest + integration/contract tests + Flutter tests | Unit and cross-service behaviour |
| CI | GitHub Actions | Repeatable checks and deployment gates |

## 4. Bounded contexts

| Module | Owns | Must not own |
|---|---|---|
| Identity | Firebase UID mapping, internal user, platform UID, session/account status | Payment balance |
| Profiles/game accounts | Player profile, Free Fire UID and honest verification method | Authentication secrets |
| Teams | Team, memberships, invitations, accepted roster snapshots | Payment truth |
| Organizers | Legal organizer profile, provider onboarding state, beneficiary refs | Arbitrary UPI strings |
| Tournaments | Mode, rules/pricing/prize versions, schedule, slots, lifecycle | Gateway transaction truth |
| Registrations | Solo/team entry, slot reservation, roster and price snapshots | Mutable current team roster |
| Payments | Orders, link/QR attempts, provider transactions, webhook inbox and refunds | Client-reported success |
| Accounting | Commission, double-entry journals, organizer payable, reconciliation | Editable wallet balances |
| Settlement | Provider connected account, allocations and transfer state | Retroactive beneficiary changes |
| Matches/scoring | Schedules, room credentials, evidence, versioned scoring and leaderboard | Client-side authoritative scores |
| Prize operations | Commitments, awards, organizer payment claims and verification evidence | Custody of organizer prize funds |
| Moderation | Event assignments, disputes, moderation decisions | Cross-organizer finance access |
| Notifications | Outbox delivery, push and realtime notifications | Source of truth |
| Audit/compliance | Security/finance audit, approvals and feature gates | Unreviewed business decisions |

## 5. Source-of-truth rules

- PostgreSQL is authoritative for users, roles, teams, tournaments, registrations, payments, ledger, settlement and final results.
- Firebase proves identity; PostgreSQL determines platform permissions and resource scope.
- The client never determines payable amount, commission, beneficiary, prize amount or official score.
- Redis is disposable. Durable events use a PostgreSQL transactional outbox.
- WebSocket/FCM notifications are hints; clients refresh authoritative API state.
- Evidence is stored privately and accessed through short-lived signed URLs.
- No SQLite/Drift, local JSON or browser local storage as production authoritative data. Ephemeral cache can improve UX but must be invalidatable and shown as stale when offline.
- Secure session material is stored in platform-secure storage, never ordinary preferences.

## 6. Identity architecture

One Firebase Authentication project for website and Android:
- Email/password.
- Google sign-in.
- Provider linking through Firebase-supported account linking.
- One Firebase UID mapped to one immutable internal PostgreSQL \`user_id\`.
- Same user profile, platform UID, game account, teams, registrations and history on web and Android.

Web uses Firebase Web SDK, backend token verification and secure HttpOnly/Secure/SameSite session cookies where applicable; add CSRF protection for cookie-authenticated mutations. Android uses Firebase SDK and supported Google/Credential Manager flow; store session material via Android Keystore-backed secure storage.

Backend verifies token signature, issuer, audience/project ID, expiry and disabled/revoked status using Firebase Admin SDK. Role and resource scope are read from PostgreSQL for protected requests. Service-account credentials remain server-side.

Do not merge accounts solely because email strings match unless identity ownership is proven. Financial history must never be rewritten during account recovery/merge.

Identifier distinction:
- \`platform_uid\`: random public-safe identifier for platform search/team invitation.
- \`game_uid\`: Free Fire account identifier entered by player.
- Platform UID is not proof of Free Fire account ownership. Do not claim official Garena verification without authorized integration.

## 7. Roles and permission boundaries

Roles:
- \`PLAYER\`
- \`ORGANIZER_OWNER\`: legal/contractual owner of a tournament and settlement profile.
- \`TOURNAMENT_MODERATOR\`: operational user assigned to specific tournaments.
- \`FINANCE_REVIEWER\`
- \`ADMIN\`
- \`SUPER_ADMIN\`: restricted break-glass access.

| Capability | Player | Organizer owner | Assigned moderator | Finance reviewer | Admin |
|---|---|---|---|---|---|
| Browse events | Yes | Yes | Yes | Yes | Yes |
| Manage own profile/team | Yes | Yes | Yes | Yes | Yes |
| Register/pay | Eligible | Eligible | No by role alone | No by role alone | Test-only |
| Create/publish event | No | Yes | Explicit delegation only | No | Yes |
| Edit own draft price/prize | No | Yes | Delegated only | No | Yes |
| Change material terms after paid entry | No | Amendment flow only | No | No | Controlled exception |
| See own registrations | Own | Yes | Assigned scope | Read-only scope | Yes |
| See another organizer's finance | No | No | No | Finance-scoped | Yes |
| Room/match operations | No | Yes | Assigned | No | Yes |
| Verify high-risk result | No | Subject to separation | Assigned, not own submission | No | Yes |
| Refund/settlement exception | No | Request only | No | Authorized | Authorized |
| Confirm prize paid | No | Submit evidence only | No | Verify | Verify/escalate |
| Change beneficiary | No | Re-onboard only | No | Review | Suspend/review |
| Change global commission/roles | No | No | No | No | Authorized admin |
| Delete ledger/audit records | No | No | No | No | No |

Backend checks role + resource ownership + permission on every protected request. Organizer queries are scoped by \`organizer_profile_id\`. A moderator assignment is not finance access. UI hiding is not authorization. Sensitive actions are audited; high-risk financial exceptions use maker-checker.

## 8. Organizer ownership model

A moderator who independently creates, publishes and commercially operates tournaments is an **organizer owner**. The organizer profile represents the legal person/entity responsible for the event and payment-provider onboarding; operational moderators are separate event assignments.

Each published event versions and snapshots its:
- Legal organizer profile and settlement beneficiary reference.
- Game/mode/format and rules.
- Capacity, schedule and registration deadlines.
- Entry price and commission policy version.
- Prize configuration and funding source.
- Tournament scoring rules.

Every payment order snapshots organizer ID/legal identity version, provider beneficiary reference, tournament/registration/roster, price version, commission policy, amount and currency. Delayed webhook uses that snapshot, never the current moderator profile. Editing a UPI ID cannot redirect existing payments.

Operational ownership transfer is a controlled request with old/new owner, reason and time. New organizer completes provider onboarding. Existing payments retain original beneficiary. Prize responsibility transfers only with documented, legally approved assumption/novation accepted by affected parties. Admin cannot silently reassign money.

Pricing/prize locks:
- Draft: editable.
- Published with no paid registrations: new version plus notice.
- First successful paid registration: price/commission/beneficiary snapshot and advertised prize terms lock for existing registrations.
- Material change later requires documented amendment, notice/consent as applicable, cancellation/refund path and audit.
- No silent price increase or prize reduction.

## 9. Database ERD

Logical relationships, not Prisma schema/migration:

\`\`\`mermaid
erDiagram
 USER ||--o| PLAYER_PROFILE : has
 USER ||--o{ GAME_ACCOUNT : links
 USER ||--o{ ROLE_ASSIGNMENT : receives
 USER ||--o| ORGANIZER_PROFILE : owns
 ORGANIZER_PROFILE ||--o{ SETTLEMENT_ACCOUNT : verifies
 TEAM ||--o{ TEAM_MEMBERSHIP : contains
 USER ||--o{ TEAM_MEMBERSHIP : joins
 TEAM ||--o{ TEAM_INVITATION : invites
 ORGANIZER_PROFILE ||--o{ TOURNAMENT : owns
 TOURNAMENT ||--o{ TOURNAMENT_VERSION : versions
 TOURNAMENT ||--o{ PRICING_VERSION : prices
 TOURNAMENT ||--o{ PRIZE_CONFIGURATION : prizes
 TOURNAMENT ||--o{ REGISTRATION : accepts
 TEAM ||--o{ REGISTRATION : team_entry
 USER ||--o{ REGISTRATION : solo_entry
 REGISTRATION ||--o{ REGISTRATION_MEMBER : snapshots
 REGISTRATION ||--o{ PAYMENT_ORDER : pays
 PAYMENT_ORDER ||--o{ PAYMENT_ATTEMPT : attempts
 PAYMENT_ATTEMPT ||--o{ PAYMENT_TRANSACTION : captures
 PAYMENT_TRANSACTION ||--o{ LEDGER_JOURNAL : posts
 LEDGER_JOURNAL ||--|{ LEDGER_ENTRY : balances
 ORGANIZER_PROFILE ||--o{ ORGANIZER_PAYABLE : owed
 PAYMENT_TRANSACTION ||--o{ SETTLEMENT_ALLOCATION : allocates
 TOURNAMENT ||--o{ MATCH : contains
 MATCH ||--o{ RESULT_SUBMISSION : receives
 RESULT_SUBMISSION ||--o{ RESULT_EVIDENCE : proves
 MATCH ||--o| VERIFIED_RESULT : finalizes
 TOURNAMENT ||--o{ MODERATOR_ASSIGNMENT : assigns
 TOURNAMENT ||--o{ PRIZE_COMMITMENT : commits
 PRIZE_COMMITMENT ||--o{ PRIZE_AWARD : allocates
 PRIZE_AWARD ||--o{ PRIZE_DISBURSEMENT : pays
 USER ||--o{ AUDIT_EVENT : acts
\`\`\`

## 10. Database design — core tables and constraints

Conventions: PostgreSQL; UUID primary keys; money \`BIGINT\` integer paise; currency \`CHAR(3)\`, initially INR; timestamps \`TIMESTAMPTZ\` UTC; public IDs/tokens random/non-sequential. Foreign keys and common query columns indexed. Financials, webhook events, audit records and published snapshots are append-only under approved retention schedules. Minimize PII; store provider beneficiary references and masked destination, not payment credentials.

| Table | Key fields | Constraints/indexes | Deletion/security |
|---|---|---|---|
| users | id, firebase_uid, platform_uid, status | Unique firebase/platform UID; status index | Disable, no password field |
| player_profiles | user_id, display_name, avatar_key, region, age_check_status | 1:1 user | PII restricted; retain only necessary DOB |
| game_accounts | id, user_id, game_code, game_uid, in_game_name, verification method/status | Unique active game_code+game_uid | Do not claim official verification without mechanism |
| role_assignments | user_id, role, scope_type/id, granted_by, expires_at | Index user/role/scope | Grant/revoke audited |
| organizer_profiles | owner_user_id, legal_name, display_name, entity_type, verification/provider status | Controlled ownership | Restricted legal identity |
| settlement_accounts | organizer_id, provider, beneficiary_ref, masked_destination, status/version | Unique provider beneficiary | No PIN/OTP/password; typed UPI is not verification |
| organizer_documents | organizer_id, type, object_key, review_status | Index organizer/status | Encrypted private storage |
| teams | platform_team_uid, name, captain_user_id, status | Unique team UID | Archive, retain registrations |
| team_memberships | team_id, user_id, member_role, status | Unique active team/user; one captain | Audit membership changes |
| team_invitations | team_id, inviter, invitee_user/UID, token_hash, status, expires_at | Index team/status and invitee | Single-use expiring hash only |
| tournaments | slug, organizer_id, game_code, mode, registration_kind, status, capacity, starts_at | Positive capacity; indexes organizer/status, mode/status, starts_at | Archive/cancel |
| tournament_versions | tournament_id, version, rules JSONB, published_at, created_by | Unique tournament/version | Immutable after publish |
| pricing_versions | tournament_id, entry_fee_paise, currency, commission_policy_version_id | Nonnegative; immutable when referenced | Historical snapshots |
| prize_configurations | tournament_id, version, total_paise, funding_source, status | Unique event/version; awards <= total | Lock after paid registration |
| moderator_assignments | tournament_id, user_id, permission_set, created_by | Unique event/user | Scoped/audited |
| registrations | tournament_id, player_user_id nullable, team_id nullable, captain_user_id, participant_type, status, price snapshot, currency, roster JSONB | CHECK exactly one of player/team; unique active participant/event | Preserve paid/cancelled history |
| registration_members | registration_id, user_id, game UID/in-game name snapshot | Unique registration/user | Immutable after lock |
| slot_reservations | registration_id, tournament_id, expires_at, status | Partial unique active; atomic capacity check | Expire safely |
| payment_orders | registration_id, provider/merchant ref, expected amount, currency, idempotency key, pricing/beneficiary snapshot, status | Unique scoped idempotency; amount>0 | Immutable commercial snapshots |
| payment_attempts | order_id, method LINK/DYNAMIC_QR, provider_ref, checkout URI/QR ref, expires_at, status | Unique provider attempt | No secrets in logs |
| payment_transactions | order_id, provider_payment_id, merchant_ref, amount/currency/status/captured_at, optional UPI RRN | Unique provider+merchant+payment ID; RRN secondary | Immutable PSP facts |
| webhook_events | provider/merchant/event ID/body hash/received/processed/status | Unique provider+merchant+event ID | Minimize/encrypt payload |
| refunds | transaction_id, provider_refund_id, amount, reason, status | Unique provider refund; sum <= captured | Append history |
| commission_policy_versions | policy/version/basis/rate_bps or fixed_paise/min/max/effective_at | Unique version; validate one basis | Admin audited |
| ledger_accounts | account_code, type, currency, owner_ref | Unique account code | No editable balance |
| ledger_journals | source type/id, journal type, currency, posted_at, reversal_of | Unique source/journal type; balance before post | Append-only |
| ledger_entries | journal/account, debit_paise, credit_paise | Exactly one positive side | Immutable |
| organizer_payables | organizer, payment transaction, amount/currency/status | Unique allocation per transaction | Derived from ledger |
| settlement_transfers | organizer, beneficiary snapshot, provider transfer ID, amount/status | Unique provider transfer; no over-settlement | Append events |
| reconciliation_items | provider reference, internal ref, difference, status | Unique provider statement row | Finance restricted |
| matches | tournament/stage/number/status/schedule/scoring version | Unique tournament/stage/number | Retain |
| match_participants | match_id, registration_id, seed | Unique match/registration | Locked roster |
| room_credentials | match_id, ciphertext, release/expiry | One active set per match | KMS envelope encryption, just-in-time read |
| result_submissions | match_id, submitter, source, status, JSONB payload | Index match/status | Append each submission |
| result_evidence | submission, object key, SHA256, MIME, uploader | Index submission | Private, malware scanned |
| verified_results | match, rules version, verifier/time, calculation | One active official result version | Correction as new audited version |
| disputes | event/match/registration/opener/status/resolution | Status/event index | Scoped evidence |
| prize_commitments | tournament/version/total/source/evidence status | Unique event/version | Not proof funds held by platform |
| prize_awards | commitment/registration/rank/amount/status | Unique recipient/rank | Immutable |
| prize_disbursements | award/payment ref/amount/evidence/status | Index award/status | Evidence is not confirmed payment |
| audit_events | actor/role/action/resource/request ID/before-after hashes/time | Index actor/time and resource/time | Append-only |
| consent_records | user/purpose/policy version/captured/withdrawn | Index user/purpose | Purpose-limited retention |

### Database invariants

- Registration is XOR (one player or one team), never both/neither.
- Clash Squad is team-only.
- Captain pays one team order; members are registration snapshots, not separate charges.
- At most one successful registration payment; excess capture gets refund/reconciliation.
- Provider payment ID unique within provider merchant; webhook event ID likewise.
- Every posted journal balances.
- Published rules, scoring, pricing, commission, beneficiary and prize versions immutable.
- Order preserves amount, pricing, commission and beneficiary snapshot.
- Foreign keys/indexes; partial unique indexes for active invite, membership, slot and successful registration payment.
- Capacity is enforced with row lock/serializable transaction, not read-then-write client logic.
- No hard-delete financial/audit/published/paid-registration records. Privacy erase/anonymize only where legally possible while preserving required records.

## 11. API contract outline

Base \`/v1\`; REST JSON; OpenAPI generated from NestJS DTOs. UTC ISO timestamps, integer paise + currency. Errors contain safe code/message/request ID. All actions enforce server-side authorization. Write operations that can be retried use \`Idempotency-Key\`. Webhooks verify signature against exact raw body and persist inbox event before acknowledgement.

| Method/path | Access | Contract |
|---|---|---|
| POST /auth/session | Authenticated Firebase identity | Verify token; resolve internal ID/platform UID |
| GET /me | Signed-in | Own profile and roles |
| PATCH /me/profile | Player | Allowlisted fields only |
| POST /me/game-accounts | Player | Game UID and honest verification status |
| GET /players/search?platformUid= | Signed-in player | Limited platform UID lookup; never expose phone/email |
| POST /teams | Player | Create team; captain derived server-side |
| POST /teams/:id/invitations/link | Captain | Expiring single-use link; token shown once, hash stored |
| POST /teams/:id/invitations | Captain | Invite existing user by platform UID |
| POST /team-invitations/:id/accept | Invitee | Authenticated atomic acceptance |
| POST /team-invitations/:id/decline | Invitee | Decline |
| GET /tournaments | Public | Published event search; no room credentials |
| GET /tournaments/:id | Public | Public rules/price/eligibility |
| POST /organizer/tournaments | Organizer | Create own draft |
| PATCH /organizer/tournaments/:id | Owner/delegated | Versioned edit; rejects locked financial terms |
| POST /organizer/tournaments/:id/publish | Owner | Publish after content and compliance gates |
| POST /tournaments/:id/registrations | Player/captain | Participant/team only; backend snapshots roster/price/beneficiary |
| GET /registrations/:id | Participant/owner/admin | Safe status and payment summary |
| POST /registrations/:id/cancel | Policy-scoped | Cancellation/refund workflow, never delete |
| POST /registrations/:id/payment-orders | Captain/solo player | Idempotency + LINK or DYNAMIC_QR; backend derives amount; blocked when paid gate false |
| GET /payment-orders/:id | Order owner/finance/admin | Status and safe retry details |
| POST /payment-orders/:id/retry | Order owner | New attempt, not new registration |
| POST /webhooks/payments/:provider | PSP signature | Raw-body verification, unique inbox, async process |
| POST /admin/payments/:id/reconcile | Finance admin | PSP lookup and discrepancy |
| POST /admin/refunds | Finance | Original payment, amount, reason, idempotency |
| POST /organizer/settlement-onboarding | Organizer | Provider-hosted KYC/connected account |
| GET /organizer/financial-summary | Organizer owner | Derived gross/commission/fees/refunds/payable/settled |
| GET /organizer/settlements | Organizer owner | Own transfer records only |
| POST /organizer/matches/:id/room-credentials | Assigned manager | Encrypted, timed secret; never echo stored password |
| POST /organizer/matches/:id/results | Assigned moderator | Candidate results/evidence, not final |
| POST /organizer/results/:id/verify | Authorized verifier | Verify/reject; separation of duties for high risk |
| POST /disputes | Participant | Reason/evidence |
| POST /organizer/tournaments/:id/prize-commitments | Owner | Funding source and schedule |
| POST /organizer/prize-awards/:id/disbursements | Owner | Reference/evidence; EVIDENCE_SUBMITTED only |
| POST /admin/prize-awards/:id/verify | Finance | Independent supported verification |

Error codes: VALIDATION_ERROR, UNAUTHENTICATED, FORBIDDEN, NOT_FOUND (no tenant leak), CONFLICT, BUSINESS_RULE_VIOLATION, RATE_LIMITED, PROVIDER_UNAVAILABLE and COMPLIANCE_GATE_CLOSED. Browser redirect is never payment truth.

## 12. Tournament lifecycle

Draft → Published → Registration Open → Registration Closed → Check-in → Ready → Live → Results Pending → Dispute/Review (if any) → Completed → Archived. Cancellation has its own reason/refund path. Status transitions are server-controlled and audited.

Battle Royale scoring is versioned and configurable (placement + eliminations) with tie-break rules; do not claim sample values are official. Clash Squad is round/bracket-based; support best-of series and brackets as tournament configuration. All official ranking is computed server-side from verified results and immutable rules version.

Room creation is manual until an authorized official API exists: authorized organizer creates Free Fire custom room, records encrypted ID/password, sets release time, eligible participants receive just-in-time credentials, match runs, moderator reviews evidence, backend calculates final result. Do not assume a Garena tournament API exists.
