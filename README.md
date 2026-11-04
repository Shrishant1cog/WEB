# FFT — Independent Free Fire India Tournament Management Platform

> **FFT is an independent tournament management platform. It is not affiliated with, endorsed by, or operated by Garena.**

## Overview

FFT is a platform that helps players and organizers manage community tournaments for Free Fire India. This is an independent product with no official affiliation with Garena or Free Fire India.

## Project Structure

```
FFT/
├── apps/
│   ├── mobile/          # Flutter Android application (players)
│   └── web/             # Next.js dashboard (organizers/admins) + public website
├── supabase/
│   ├── config.toml      # Supabase local configuration
│   ├── migrations/      # Versioned SQL migrations
│   ├── functions/       # Supabase Edge Functions
│   ├── tests/           # Database tests (pgTAP)
│   └── seed.sql         # Development seed data
├── docs/                # Project documentation
├── scripts/             # Utility scripts
├── .github/workflows/   # CI/CD pipelines
└── package.json         # Root workspace configuration
```

## Technology Stack

- **Mobile**: Flutter 3.47.9+ (stable), Dart 3.13+, Android API 36+
- **Web**: Next.js 16.4.5+, TypeScript strict, React 18+, Supabase SSR
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Runtime**: Node.js 26 LTS (for Next.js and tooling)
- **Package Manager**: pnpm 12+ (workspace)

## Development Prerequisites

- Flutter SDK 3.47.9+ (stable channel)
- Android SDK with API 36
- Node.js 26 LTS
- pnpm 12+
- Supabase CLI 3+
- Docker Desktop (for local Supabase)
- GitHub CLI (authenticated)

## Getting Started

```bash
# Install dependencies
pnpm install

# Start local Supabase
supabase start

# Run database migrations
supabase db reset

# Start web development server
cd apps/web && pnpm dev

# Run Flutter app (in separate terminal)
cd apps/mobile && flutter run
```

## Documentation

- [Product Requirements](docs/PRODUCT_REQUIREMENTS.md)
- [MVP Scope](docs/MVP_SCOPE.md)
- [Architecture](docs/architecture/ARCHITECTURE.md)
- [Data Model](docs/architecture/DATA_MODEL.md)
- [Workflows](docs/architecture/WORKFLOWS.md)
- [Security Model](docs/security/SECURITY_MODEL.md)
- [Threat Model](docs/security/THREAT_MODEL.md)
- [Privacy & Data Map](docs/privacy/PRIVACY_AND_DATA_MAP.md)
- [Research Baseline](docs/legal/RESEARCH_BASELINE.md)
- [Legal Launch Gates](docs/legal/LEGAL_LAUNCH_GATES.md)
- [Project Decisions](docs/decisions/PROJECT_DECISIONS.md)
- [Open Owner Decisions](docs/decisions/OPEN_OWNER_DECISIONS.md)
- [Test Strategy](docs/testing/TEST_STRATEGY.md)
- [Local Setup](docs/operations/LOCAL_SETUP.md)
- [Build & Release](docs/operations/BUILD_AND_RELEASE.md)
- [Backup & Recovery](docs/operations/BACKUP_AND_RECOVERY.md)
- [Project Status](docs/PROJECT_STATUS.md)

## Legal Notice

This platform is for managing community tournaments only. It does not:
- Provide real-money prizes, wallets, or payouts
- Claim official Garena affiliation
- Use unauthorized game assets, APIs, or data
- Scrape game servers or reverse-engineer the client

See [LEGAL_LAUNCH_GATES.md](docs/legal/LEGAL_LAUNCH_GATES.md) for launch blockers.

## License

Proprietary — All rights reserved.