# Android Production Signing Guide

## Overview

This document describes the production signing configuration for the FFT Android app.

**CRITICAL**: Never commit keystores, passwords, or `key.properties` to version control.

## Keystore Generation (One-time Setup)

```bash
# Generate a production keystore (run once, store securely)
keytool -genkey -v \
  -keystore android/app/keystore/release.keystore \
  -alias release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=FFT Mobile, O=FFT, C=IN"
```

## Secure Backup Procedure

**The keystore is irreplaceable. If lost, you cannot update the app on Play Store.**

1. **Primary backup**: Encrypted USB drive stored in secure location
2. **Secondary backup**: Printed QR codes of passwords + base64 keystore in fireproof safe
3. **Team access**: Shared via password manager (1Password/Bitwarden) with restricted access

```bash
# Create encrypted backup (example using age)
base64 -w0 android/app/keystore/release.keystore | age -r <recipient> > release.keystore.b64.age

# Store passwords in password manager
# - keystore_password
# - key_password
# - key_alias (release)
```

## Local Development

For local production builds:

```bash
# 1. Copy example to actual config
cp android/key.properties.example android/key.properties

# 2. Edit with your values
# 3. Build
flutter build apk --release
```

## CI/CD Configuration (GitHub Actions)

Required encrypted secrets in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `KEYSTORE_BASE64` | `base64 -w0 android/app/keystore/release.keystore` |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias (e.g., `release`) |
| `KEY_PASSWORD` | Key password |

The workflow:
1. Decodes keystore from `KEYSTORE_BASE64`
2. Creates `key.properties` at build time
3. Builds release APK with production signing
4. Verifies certificate is NOT debug
5. Fails if debug signing detected

## Signing Verification

### Local verification:
```bash
# Check certificate
keytool -list -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk

# Verify not debug
keytool -list -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk | grep -i "CN=Android Debug" && echo "DEBUG KEY DETECTED!" || echo "Production key OK"
```

### CI verification:
Automatic in GitHub Actions - checks for debug certificate and fails build if found.

## Application ID

**Current**: `com.example.fft_mobile` (placeholder)

**Production**: Must be changed before Play Store submission.
Recommended format: `com.fft.mobile` or organization-specific identifier.

Change in `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "com.fft.mobile"  // Update this
    ...
}
```

## Release Build Commands

```bash
# Debug (QA) - uses debug keystore
flutter build apk --debug

# Release (Production) - requires key.properties with valid keystore
flutter build apk --release

# Release with obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## Key Rotation (If Compromised)

1. Generate new keystore
2. Contact Google Play Support for key upgrade
3. Update all secrets in CI/CD
4. Document rotation date and reason

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `key.properties missing` | File not created | Create from example |
| `Keystore was tampered` | Wrong password | Verify passwords in key.properties |
| `Debug certificate detected` | key.properties missing/incomplete | Ensure all 4 values present |
| `APK not found` | Build failed earlier | Check Gradle logs above |

## Security Checklist

- [ ] Keystore generated with 2048-bit RSA, 25+ year validity
- [ ] Passwords stored in password manager (not plaintext)
- [ ] Keystore backed up to 2+ secure locations
- [ ] `key.properties` in `.gitignore` (verified)
- [ ] Keystore file in `.gitignore` (verified)
- [ ] GitHub secrets configured (not in code)
- [ ] CI verifies production certificate
- [ ] CI fails on debug certificate
- [ ] Application ID updated for production