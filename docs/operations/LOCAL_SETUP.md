# Local Development Setup — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline for Phase 1

---

## 1. Prerequisites

### 1.1 Required Software

| Tool | Version | Install Method | Verify |
|------|---------|----------------|--------|
| **Git** | 2.40+ | winget/choco/scoop | `git --version` |
| **GitHub CLI** | 2.40+ | winget: `GitHub.cli` | `gh --version` |
| **Flutter** | 3.47.9 (stable) | Official installer | `flutter --version` |
| **Dart** | 3.13.7 | Bundled with Flutter | `dart --version` |
| **Android SDK** | API 36 + Build Tools 36+ | Android Studio / cmdline-tools | `flutter doctor -v` |
| **Java/JDK** | 21 LTS | Eclipse Temurin / winget | `java -version` |
| **Node.js** | 26 LTS | fnm/nvm/volta | `node --version` |
| **pnpm** | 12+ | `npm install -g pnpm` | `pnpm --version` |
| **Docker Desktop** | 4.30+ | winget: `Docker.DockerDesktop` | `docker --version` |
| **Supabase CLI** | 3.0+ | `npm install -g supabase` | `supabase --version` |

### 1.2 Windows-Specific Setup

```powershell
# Enable long paths (required for Flutter)
git config --system core.longpaths true

# Set execution policy for scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Android SDK environment variables (add to User PATH)
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin"

# Java home (if not auto-detected)
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
```

### 1.3 Android Device/Emulator

```bash
# List available emulators
flutter emulators

# Create emulator (API 36)
flutter emulators --create --name fft_pixel --device-id pixel_7

# Start emulator
flutter emulators --launch fft_pixel

# Or use physical device (USB debugging on)
flutter devices
```

---

## 2. Repository Setup

```bash
# Clone (after GitHub repo created)
git clone https://github.com/<your-account>/FFT.git
cd FFT

# Verify clean state
git status

# Create development branch
git checkout -b agent/fft-development
git push -u origin agent/fft-development
```

---

## 3. Supabase Local Development

### 3.1 Start Local Stack

```bash
# From project root
supabase start

# This starts:
# - PostgreSQL (port 54322)
# - Auth (port 54321)
# - Storage (port 54323)
# - Realtime (port 54324)
# - Studio (port 54325) - http://localhost:54325
```

### 3.2 Apply Migrations

```bash
# Reset database (applies all migrations + seed)
supabase db reset

# Or apply specific migration
supabase migration up

# Check status
supabase migration list
```

### 3.3 Local Configuration

```bash
# Copy environment template
cp .env.example .env.local

# Edit with local Supabase credentials (from `supabase start` output)
# SUPABASE_URL=http://localhost:54321
# SUPABASE_ANON_KEY=your-anon-key
# SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3.4 Generate TypeScript Types (for web)

```bash
cd apps/web
pnpm supabase:types  # Runs: supabase gen types typescript --local > src/types/supabase.ts
```

### 3.5 Generate Dart Types (for mobile)

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
# Or use: flutter pub run build_runner build
```

---

## 4. Web Application (Next.js)

### 4.1 Install Dependencies

```bash
cd apps/web
pnpm install
```

### 4.2 Development Server

```bash
pnpm dev
# Runs at http://localhost:3000
```

### 4.3 Available Scripts

| Script | Command | Purpose |
|--------|---------|---------|
| `dev` | `next dev` | Development server |
| `build` | `next build` | Production build |
| `start` | `next start` | Production server |
| `lint` | `next lint` | ESLint |
| `typecheck` | `tsc --noEmit` | TypeScript check |
| `test` | `vitest run` | Unit/Component tests |
| `test:e2e` | `playwright test` | E2E tests |
| `supabase:types` | `supabase gen types...` | Generate TS types |

---

## 5. Mobile Application (Flutter)

### 5.1 Install Dependencies

```bash
cd apps/mobile
flutter pub get
```

### 5.2 Code Generation (Freezed, JSON Serialization)

```bash
dart run build_runner build --delete-conflicting-outputs
# Or for watch mode:
dart run build_runner watch --delete-conflicting-outputs
```

### 5.3 Run on Device/Emulator

```bash
# Debug mode
flutter run

# Release mode (for performance testing)
flutter run --release

# Specific device
flutter run -d <device_id>
```

### 5.4 Available Commands

| Command | Purpose |
|---------|---------|
| `flutter analyze` | Static analysis |
| `flutter test` | Unit + Widget tests |
| `flutter test integration_test/` | Integration tests |
| `flutter build apk --release` | Android APK |
| `flutter build appbundle --release` | Android App Bundle (AAB) |
| `flutter doctor -v` | Environment check |

---

## 6. Environment Variables

### 6.1 Root `.env.example`

```bash
# Supabase (Local)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-role-key

# Supabase (Production - DO NOT COMMIT)
# SUPABASE_URL=https://xxx.supabase.co
# SUPABASE_ANON_KEY=xxx
# SUPABASE_SERVICE_ROLE_KEY=xxx

# Firebase FCM (for push notifications)
# FIREBASE_PROJECT_ID=xxx
# FIREBASE_SERVER_KEY=xxx

# SMTP (for auth emails)
# SMTP_HOST=smtp.example.com
# SMTP_PORT=587
# SMTP_USER=xxx
# SMTP_PASS=xxx
# SMTP_FROM=noreply@fft.app

# Monitoring
# SENTRY_DSN=xxx

# Feature Flags
FFT_MIN_AGE=18
FFT_ENABLE_PUSH=false
FFT_ENABLE_SUBSTITUTES=false
```

### 6.2 Web `.env.local` (apps/web/.env.local)

```bash
# Same Supabase vars (Next.js reads from root or this file)
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-role-key

# App URL
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 6.3 Mobile Configuration (apps/mobile/lib/core/config/env.dart)

```dart
// Generated from build.yaml or --dart-define
// flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
//   --dart-define=SUPABASE_ANON_KEY=xxx
```

**Android Emulator Note:** Use `10.0.2.2` instead of `localhost` to reach host machine.

---

## 7. IDE Setup

### 7.1 VS Code (Recommended)

**Extensions:**
- Flutter
- Dart
- ES7+ React/Redux/React-Native snippets
- Tailwind CSS IntelliSense
- Supabase
- PostgreSQL
- GitLens
- Error Lens

**Settings (`.vscode/settings.json`):**
```json
{
  "dart.flutterSdkPath": "C:\\flutter",
  "dart.sdkPath": "C:\\flutter\\bin\\cache\\dart-sdk",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "[dart]": { "editor.defaultFormatter": "Dart-Code.dart-code" },
  "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[typescriptreact]": { "editor.defaultFormatter": "esbenp.prettier-vscode" }
}
```

### 7.2 Android Studio (Alternative)

- Install Flutter plugin
- Configure SDK path
- Use for emulator management, profiling

---

## 8. Common Workflows

### 8.1 Start Full Stack

```bash
# Terminal 1: Supabase
supabase start

# Terminal 2: Web
cd apps/web && pnpm dev

# Terminal 3: Mobile
cd apps/mobile && flutter run
```

### 8.2 Database Changes

```bash
# 1. Create migration
supabase migration new add_tournament_rules

# 2. Edit migration file (up.sql + down.sql)
# supabase/migrations/YYYYMMDDHHMMSS_add_tournament_rules/up.sql

# 3. Apply locally
supabase db reset

# 4. Generate types
cd apps/web && pnpm supabase:types
cd apps/mobile && dart run build_runner build

# 5. Test
supabase test db
```

### 8.3 Run Tests

```bash
# All tests
# Flutter
cd apps/mobile && flutter test

# Web
cd apps/web && pnpm test && pnpm test:e2e

# Backend
supabase test db
```

### 8.4 Pre-Commit Checks

```bash
# Run locally before commit
cd apps/mobile && flutter analyze && flutter test
cd apps/web && pnpm lint && pnpm typecheck && pnpm test
supabase db reset && supabase test db
```

---

## 9. Troubleshooting

### 9.1 Flutter Doctor Issues

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Fix JDK path
flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
```

### 9.2 Supabase Start Fails

```bash
# Reset Docker containers
supabase stop --no-backup
docker system prune -f
supabase start
```

### 9.3 Port Conflicts

```bash
# Check what's using ports 54321-54325
netstat -ano | findstr "5432[1-5]"

# Kill process
taskkill /PID <pid> /F
```

### 9.4 Type Generation Fails

```bash
# Ensure Supabase is running
supabase status

# Regenerate
cd apps/web && pnpm supabase:types
cd apps/mobile && dart run build_runner build --delete-conflicting-outputs
```

---

## 10. Useful Aliases (PowerShell Profile)

```powershell
# Add to $PROFILE (notepad $PROFILE)
function fft-web { Set-Location C:\Users\hosam\Desktop\Shri\FFT\apps\web; pnpm dev }
function fft-mobile { Set-Location C:\Users\hosam\Desktop\Shri\FFT\apps\mobile; flutter run }
function fft-supabase { supabase start }
function fft-reset { supabase db reset }
function fft-test { 
  cd C:\Users\hosam\Desktop\Shri\FFT\apps\mobile; flutter test
  cd C:\Users\hosam\Desktop\Shri\FFT\apps\web; pnpm test
  supabase test db
}
```