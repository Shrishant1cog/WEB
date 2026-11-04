# Build & Release — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline for Phase 8

---

## 1. Release Principles

- **No public release without all legal gates cleared** (see LEGAL_LAUNCH_GATES.md)
- **No merge to main/default branch without owner approval**
- **Development branch:** `agent/fft-development` (force-push protected)
- **Release tags:** `v<major>.<minor>.<patch>-<stage>` (e.g., `v0.1.0-beta.1`)
- **Artifacts:** Android AAB + Next.js build + migration files

---

## 2. Android Release Build

### 2.1 Keystore Setup (One-time)

```bash
# Generate upload keystore (store securely!)
keytool -genkeypair -v -keystore fft-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fft-upload

# Create key.properties (DO NOT COMMIT)
cat > apps/mobile/android/key.properties <<EOF
storePassword=<store_password>
keyPassword=<key_password>
keyAlias=fft-upload
storeFile=../fft-upload-key.jks
EOF

# Add to .gitignore
echo "android/key.properties" >> apps/mobile/.gitignore
echo "*.jks" >> apps/mobile/.gitignore
```

### 2.2 Build Configuration (apps/mobile/android/app/build.gradle.kts)

```kotlin
android {
    namespace = "com.fft.mobile"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.fft.mobile"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.0"
        
        // Test instrumentation
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        create("release") {
            val keyProps = Properties().apply { load(FileInputStream(rootProject.file("key.properties"))) }
            storeFile = file(keyProps["storeFile"] as String)
            storePassword = keyProps["storePassword"] as String
            keyAlias = keyProps["keyAlias"] as String
            keyPassword = keyProps["keyPassword"] as String
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Build variants for flavor (future)
    // flavorDimensions += "environment"
    // productFlavors {
    //     create("dev") { dimension = "environment" }
    //     create("prod") { dimension = "environment" }
    // }
}
```

### 2.3 Build Commands

```bash
cd apps/mobile

# Debug APK (for testing)
flutter build apk --debug

# Release APK (for sideloading)
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Verify AAB
bundletool validate --bundle build/app/outputs/bundle/release/app-release.aab
```

### 2.4 Version Management

```yaml
# apps/mobile/pubspec.yaml
version: 0.1.0+1  # versionName+versionCode
```

**Version Strategy:**
- `major`: Breaking API changes, major legal gate
- `minor`: New features (tournament formats, team features)
- `patch`: Bug fixes, security patches
- `versionCode`: Monotonically increasing integer (Play Store requirement)

---

## 3. Web Release Build (Next.js)

### 3.1 Build Configuration (apps/web/next.config.mjs)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  
  // Security headers
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
        ],
      },
    ];
  },

  // Image optimization
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '*.supabase.co' },
    ],
  },

  // Output for Vercel (default) or standalone
  // output: 'standalone', // For Docker/VM deployment

  // Experimental
  experimental: {
    // serverActions: { bodySizeLimit: '2mb' }, // Default
  },
};

export default nextConfig;
```

### 3.2 Build Commands

```bash
cd apps/web

# Production build
pnpm build

# Output: .next/ (Vercel) or standalone/ (if configured)

# Preview locally
pnpm start
```

### 3.3 Environment Variables (Production)

```bash
# Vercel Project Settings → Environment Variables
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
NEXT_PUBLIC_APP_URL=https://fft.app
SENTRY_DSN=xxx
# ... other secrets
```

---

## 4. Database Migration Release

### 4.1 Migration Checklist (Pre-Release)

- [ ] All migrations have `up.sql` and `down.sql` (where reversible)
- [ ] `supabase db reset` passes locally
- [ ] `supabase test db` passes (pgTAP)
- [ ] Migration reviewed by backend lead
- [ ] No destructive changes without data migration plan
- [ ] Indexes added for new query patterns
- [ ] RLS policies updated for new tables/columns

### 4.2 Deployment Process

```bash
# 1. Link to production project (one-time)
supabase link --project-ref <project-ref>

# 2. Push migrations (reviewed in CI)
supabase db push

# 3. Verify
supabase migration list
supabase db diff --linked

# 4. Generate types for production
supabase gen types typescript --project-ref <project-ref> > apps/web/src/types/supabase.ts
```

### 4.3 Rollback Procedure

```bash
# If migration causes issues:
# 1. Revert migration file in Git
# 2. Create new migration with down.sql logic
# 3. Push new migration
supabase db push

# OR: Point-in-Time Recovery (Supabase PITR)
# Supabase Dashboard → Database → Backups → Restore
```

---

## 5. CI/CD Pipeline (GitHub Actions)

### 5.1 Workflow: `.github/workflows/ci.yml`

```yaml
name: CI
on:
  push:
    branches: [agent/fft-development]
  pull_request:
    branches: [main, agent/fft-development]

permissions:
  contents: read
  security-events: write

jobs:
  flutter:
    name: Flutter (Mobile)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          version: '3.47.9'
          cache: true
      - name: Get dependencies
        run: cd apps/mobile && flutter pub get
      - name: Generate code
        run: cd apps/mobile && dart run build_runner build --delete-conflicting-outputs
      - name: Analyze
        run: cd apps/mobile && flutter analyze
      - name: Test
        run: cd apps/mobile && flutter test --coverage
      - name: Build APK
        run: cd apps/mobile && flutter build apk --release
      - name: Build AAB
        run: cd apps/mobile && flutter build appbundle --release
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: flutter-build
          path: |
            apps/mobile/build/app/outputs/apk/release/*.apk
            apps/mobile/build/app/outputs/bundle/release/*.aab

  nextjs:
    name: Next.js (Web)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '26'
          cache: 'pnpm'
      - name: Install dependencies
        run: cd apps/web && pnpm install --frozen-lockfile
      - name: Generate types
        run: cd apps/web && pnpm supabase:types
      - name: Lint
        run: cd apps/web && pnpm lint
      - name: Type check
        run: cd apps/web && pnpm typecheck
      - name: Test
        run: cd apps/web && pnpm test
      - name: Build
        run: cd apps/web && pnpm build

  supabase:
    name: Supabase (Backend)
    runs-on: ubuntu-latest
    services:
      postgres:
        image: supabase/postgres:17
        env:
          POSTGRES_PASSWORD: postgres
        ports: [5432:5432]
        options: >-
          --health-cmd="pg_isready -U postgres"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - name: Reset database
        run: supabase db reset
        env:
          SUPABASE_DB_URL: postgresql://postgres:postgres@localhost:5432/postgres
      - name: Run pgTAP tests
        run: supabase test db
        env:
          SUPABASE_DB_URL: postgresql://postgres:postgres@localhost:5432/postgres

  security:
    name: Security Scans
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Secret scan
        uses: trufflesecurity/trufflehog@v3
        with:
          path: ./
          base: main
          head: HEAD
      - name: Dependency audit (Node)
        run: cd apps/web && pnpm audit --audit-level=high
      - name: Dependency audit (Flutter)
        run: cd apps/mobile && flutter pub outdated --mode=null-safety
      - name: SAST (CodeQL)
        uses: github/codeql-action/init@v3
        with:
          languages: typescript, dart
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3

  notify:
    name: Notify on Failure
    needs: [flutter, nextjs, supabase, security]
    if: failure()
    runs-on: ubuntu-latest
    steps:
      - name: Send failure notification
        run: |
          # Integrate with Slack/Discord/Email
          echo "CI failed for ${{ github.sha }}"
```

### 5.2 Required Secrets (GitHub Repository Settings)

| Secret | Purpose |
|--------|---------|
| `SUPABASE_ACCESS_TOKEN` | Supabase CLI auth for `db push` |
| `SUPABASE_PROJECT_REF` | Production project ref |
| `FIREBASE_SERVER_KEY` | FCM (if used in CI) |
| `SENTRY_DSN` | Error tracking |
| `CODEQL_REPO_TOKEN` | CodeQL (auto-provided) |

---

## 6. Release Checklist (Phase 8)

### 6.1 Pre-Release Validation

- [ ] All CI jobs pass on `agent/fft-development`
- [ ] All legal gates cleared (LEGAL_LAUNCH_GATES.md)
- [ ] Security review complete (penetration test, ASVS/MASVS)
- [ ] Accessibility audit passes (WCAG 2.1 AA)
- [ ] Performance benchmarks met
- [ ] Account deletion flow verified end-to-end
- [ ] Database migration tested on staging
- [ ] Rollback procedure documented + tested
- [ ] Owner approval for release

### 6.2 Android Release

- [ ] AAB built with release keystore
- [ ] Version code incremented
- [ ] ProGuard/R8 rules tested (no crashes)
- [ ] Play Console pre-launch report clean
- [ ] Data Safety form accurate
- [ ] Privacy policy URL accessible
- [ ] Account deletion URL accessible
- [ ] Content rating questionnaire complete

### 6.3 Web Release

- [ ] Vercel production deployment successful
- [ ] Custom domain configured (fft.app)
- [ ] SSL/TLS valid (HSTS, cert transparency)
- [ ] Security headers verified
- [ ] SEO meta tags present
- [ ] Sitemap.xml generated
- [ ] Robots.txt configured

### 6.4 Database Release

- [ ] All migrations applied to production
- [ ] PITR verified working
- [ ] Backup schedule confirmed
- [ ] Monitoring alerts configured

### 6.5 Post-Release

- [ ] Tag release: `git tag v0.1.0-beta.1 && git push origin v0.1.0-beta.1`
- [ ] Release notes published
- [ ] Monitoring dashboard watched for 24h
- [ ] Support channel active
- [ ] Rollback plan ready

---

## 7. Versioning & Changelog

### 7.1 Conventional Commits

```
feat(tournaments): add squad registration
fix(auth): handle expired refresh token
docs: update API documentation
chore: update dependencies
```

### 7.2 Changelog Generation

```bash
# Automated via GitHub Actions on tag
# Uses: conventional-changelog
```

---

## 8. Emergency Hotfix Process

1. Create `hotfix/<issue>` branch from latest production tag
2. Apply minimal fix
3. Run full CI
4. Build artifacts
5. Deploy to production (with owner approval)
6. Tag `v0.1.1-hotfix.1`
7. Backport to `agent/fft-development` via cherry-pick or merge