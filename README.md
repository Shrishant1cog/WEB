# FFT

FFT is an independent tournament management platform for community Free Fire India tournaments. It is not affiliated with, endorsed by, or operated by Garena.

## Technologies

- Mobile: Flutter, Dart
- Web: Next.js, TypeScript, React, Tailwind CSS
- Backend: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- Tooling: Node.js, pnpm, Supabase CLI

## Verified implemented features

- Authentication and profiles (email/password, verification, password reset, MFA, avatars, privacy settings)
- Tournament and participation management (create/edit/publish, solo and squad registration, teams and invitations, waitlist promotion, organizer dashboard)
- Phase 4 match/results database migration applied (match entries, room credentials, results, disputes)
- Web: 90/90 Vitest tests, production build passes (20 routes)
- Mobile: 20/20 Flutter tests, release APK builds

## Prerequisites

- Flutter 3.47+ (stable) and Android SDK (API 36)
- Node.js 24+ (project declares >= 26) and pnpm 12+
- Supabase CLI 3+ and Docker Desktop
- GitHub CLI (for releases)

## Run the website locally

```bash
pnpm install
cp .env.example .env.local   # Windows: copy .env.example .env.local
# Fill NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY

supabase start
supabase db reset

pnpm dev:web
```

Website: http://localhost:3000

Production build:

```bash
pnpm build:web
```

## Run the Android app locally

```bash
cd apps/mobile
flutter pub get
```

Configure Supabase with `--dart-define`:

```bash
# Android emulator (default host mapping)
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_ANON_KEY=<anon-key>

# Physical device (use the computer's LAN IP)
flutter run --dart-define=SUPABASE_URL=http://<LAN-IP>:54321 --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Build APKs:

```bash
flutter build apk --debug    # apps/mobile/build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release  # apps/mobile/build/app/outputs/flutter-apk/app-release.apk
```

## Environment variables

Copy `.env.example` to `.env.local` (web) or use `--dart-define` (mobile). Use placeholders only; never commit real secrets. See `.env.example` for all variable names.

## Android APK download

Download the release APK from GitHub Releases:

https://github.com/Shrishant1cog/WEB/releases

Current release tag: `v0.1.0` (asset: `app-release.apk`).