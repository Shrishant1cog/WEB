# Phase 0 — Architecture baseline

**Project:** Free Fire Tournament Platform  
**Repository:** \`Shrishant1cog/WEB\`  
**Working branch:** \`phase-0/architecture\`  
**Baseline date:** 2026-11-04  
**Status:** Architecture/documentation only; no application implementation.

## Purpose

Phase 0 defines a consistent production architecture before OpenCode writes application code. It covers the player app, separate admin and organizer portals, identity, teams, tournament rules, payment-link/QR checkout, marketplace commission, organizer settlement, prize tracking, security, legal gates, cloud operations, animations and release sequence.

## Locked product decisions

- Free Fire India only in the first release.
- Battle Royale supports solo and squad registration.
- Clash Squad supports squad registration only.
- Captain pays the entire team registration amount once.
- Teammates join through a secure invitation link or platform UID search; they must authenticate and accept.
- One identity across website and Android; email/password and Google sign-in.
- Separate admin and organizer/moderator login experiences and dashboards.
- Organizer can independently create and publish their own tournaments, subject to platform-wide compliance gates.
- Platform commission is deducted from eligible collection; the organizer receives the approved net allocation.
- Organizer is responsible for paying winners from organizer/sponsor funds.
- Checkout choices: hosted payment link or order-specific dynamic UPI QR.
- All authoritative data is cloud PostgreSQL. Local state is non-authoritative UI cache only.
- Original premium esports visual identity with purposeful, accessible animations.

## Architecture decisions

| Domain | Baseline |
|---|---|
| Player Android | Flutter / Dart |
| Public, admin and organizer websites | Next.js / TypeScript |
| Backend | NestJS modular monolith |
| Database | Managed PostgreSQL + Prisma |
| Identity | Firebase Authentication; backend verifies tokens |
| Queue/cache | Redis + BullMQ + PostgreSQL transactional outbox |
| Evidence | Private object storage + short-lived signed URLs |
| Payment | Provider adapter; Cashfree Easy Split is the first technical discovery candidate, not approved |
| Ledger | Append-only double-entry accounting; integer paise |
| Organizer | Verified legal/merchant profile and provider beneficiary, not a free-form UPI ID |
| Hosting | AWS Mumbai is a proposal, not provisioned |
| Distribution | Direct APK and Play Store assessed separately |

## Documents

1. [System, database and API architecture](ARCHITECTURE.md)
2. [Financial, payment and settlement architecture](FINANCIAL_DESIGN.md)
3. [Security, legal compliance and deployment](SECURITY_COMPLIANCE_DEPLOYMENT.md)
4. [Product design, animation and implementation roadmap](PRODUCT_DESIGN_ROADMAP.md)
5. [Repository audit and Phase 0 acceptance report](VALIDATION_REPORT.md)

## Critical launch gates

Paid registrations, organizer settlement and cash-prize features remain disabled until:
- Indian counsel confirms the exact game/event/fee/commission/prize model and required esports determination/recognition/registration path.
- Garena grants any required written commercial permission.
- The payment provider approves the exact tournament marketplace business and verifies both payment methods and settlement model.
- Organizer terms, player terms, refund policy, tax/accounting treatment and prize funding responsibilities are approved.
- Google Play distribution is separately reviewed. A direct APK is not an exemption from law, publisher terms or PSP policy.

The statutory esports definition has cumulative elements; a stand-alone independent tournament app must not assume it qualifies. See [legal gates](SECURITY_COMPLIANCE_DEPLOYMENT.md).

## Validation

Run:

\`\`\`bash
node scripts/validate-phase0.mjs
\`\`\`

The validator checks file completeness, relative Markdown links, key payment/compliance invariants and the illustrative ledger arithmetic. It is not an application test, provider approval, legal opinion, security certification or production acceptance.

## Phase boundary

Phase 0 does not create Flutter, Next.js or NestJS app code, Prisma migrations, live cloud infrastructure, payment credentials, live transactions or real tournament data. Phase 1 begins only after the project owner reviews and accepts the architecture and open gates.

## Repository name

The repository slug remains \`WEB\`. The project files use the name **Free Fire Tournament Platform**. The connected GitHub integration supports file and branch operations but not repository renaming; use GitHub Settings → General → Repository name if you want the URL itself renamed.
