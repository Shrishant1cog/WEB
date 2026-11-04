# Free Fire Tournament Platform

An independent tournament operations platform for Free Fire India, with a Flutter player application, separate admin and organizer portals, and a cloud-hosted backend.

## Current status

**Phase 0 — Architecture and repository baseline.** This repository is documentation-first. No player application, web portal, backend, database, payment collection, or live tournament functionality has been implemented.

Paid entry, commission settlement, and prize payouts are disabled by design until the applicable legal, game-publisher, platform-distribution, and payment-provider requirements are confirmed in writing.

## Phase 0 documentation

See [`docs/phase-0/README.md`](docs/phase-0/README.md) for the scope, decisions, architecture specifications, validation approach, unresolved gates, and Phase 0 acceptance report.

## Intended stack

- Player app: Flutter / Dart
- Web portals: Next.js / TypeScript
- Backend: NestJS / TypeScript
- Database: managed PostgreSQL with Prisma
- Identity: Firebase Authentication with server-side token verification
- Cache/jobs: Redis / BullMQ
- Evidence storage: private object storage
- Notifications: Firebase Cloud Messaging

## Project identity

Working project name: **Free Fire Tournament Platform**.
The connected GitHub repository currently has the slug `WEB`; repository rename is a separate GitHub administration action.
