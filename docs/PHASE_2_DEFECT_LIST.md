# Phase 2 Defect List and Implementation Plan

## Current State Analysis

### ✅ Working (Verified)
- Flutter mobile app compiles and builds successfully
- Flutter tests pass (1 smoke test)
- `flutter build apk --debug` succeeds
- Database migrations exist (3 migrations)
- Supabase Edge Functions: `delete-account`, `upload-avatar`
- AuthBloc with comprehensive event handling
- Login/Register/Email verification pages exist
- AuthBloc has AuthAuthCallback for deep link handling
- Supabase client configuration for Flutter and Next.js
- Database schema with profiles, tournaments, teams, matches, etc.
- RLS policies on profiles, tournaments, teams, matches, results, notifications, audit_logs
- Storage buckets: avatars, tournament-assets, team-assets
- Auth triggers: profile creation, email change, soft delete

### ❌ Missing / Incomplete (Defects)

#### 1. Database / Auth Hooks Issues
- [ ] **Profile FK CASCADE issue**: The migration 000003 changes FK to RESTRICT but the original schema has `ON DELETE CASCADE`. The soft-delete trigger runs BEFORE DELETE but the FK check happens after. Need to verify the trigger execution order.
- [ ] **Email sync trigger**: The `handle_email_change` function was dropped but profiles table has no email column. If email sync is needed, add email column to profiles.
- [ ] **Profile creation trigger**: `handle_new_user` only sets `display_name` from metadata. Missing `terms_accepted`, `age_attestation` fields.
- [ ] **Soft delete trigger**: Uses `BEFORE DELETE` but FK is now RESTRICT. Need to verify execution order.

#### 2. Storage / Avatar Issues
- [ ] **Avatars bucket is PUBLIC** (`public = true` in migration 000001). Migration 000003 tries to set `public = false` but this may not work if bucket already exists.
- [ ] **Storage RLS**: "Public avatars are readable" policy allows anyone to read any avatar. Should be restricted.
- [ ] **Upload-avatar Edge Function**: Returns public URL but bucket should be private. Should return signed URL.
- [ ] **No file content validation**: Only checks MIME type and magic bytes. No actual image decoding/validation.

#### 3. Auth / AuthBloc Issues
- [ ] **AuthCallback event**: Has `token` and `type` but the deep link callback from Supabase typically provides `type` and `code` parameters, not a token.
- [ ] **AuthCallback handler**: Uses `getSessionFromUrl` but the URL format from Supabase email links contains `type` and `code` params, not a token.
- [ ] **No email verification flow**: The email verification page exists but doesn't actually verify the email - it just waits for deep link.
- [ ] **No password reset flow**: Password reset request/confirm pages exist but not connected to Supabase.
- [ ] **No MFA UI**: MFA enrollment/challenge/verify pages don't exist.
- [ ] **No password change UI**: Change password page doesn't exist.
- [ ] **No email change UI**: Email change page doesn't exist.
- [ ] **No account deletion UI**: Delete account page exists but is just a placeholder.

#### 4. Profile Management
- [ ] Profile edit page doesn't exist (profile_page.dart is just a view)
- [ ] Username availability check not implemented
- [ ] Avatar upload not connected to UI
- [ ] Privacy settings UI doesn't exist

#### 5. Next.js Web App (Almost Empty)
- [ ] No auth pages (login, register, password reset, email verify)
- [ ] No auth callback page
- [ ] No organizer/admin dashboards
- [ ] No profile/account settings pages
- [ ] No MFA management UI
- [ ] No account deletion page
- [ ] No server actions for auth operations
- [ ] No API routes for Edge Functions

#### 5. Database / RLS Issues
- [ ] Profile RLS: "Organizers can read tournament profiles" policy references `tournament_registrations` but that table may not have the right data.
- [ ] Tournament organizer policy: Complex join that may not work correctly.
- [ ] Team members policy: Complex join that may not work.
- [ ] Storage policies: "Public avatars are readable" allows anyone to read any avatar.

#### 6. Edge Functions
- [ ] `delete-account`: Requires password for all users, but OAuth users don't have passwords.
- [ ] `upload-avatar`: Uses `getPublicUrl` but bucket should be private; should return signed URL.
- [ ] No MFA Edge Functions (removed, which is correct - should use SDK).
- [ ] No Edge Function for email verification callback.

#### 7. Testing
- [ ] Only 1 smoke test exists
- [ ] No unit tests for use cases
- [ ] No widget tests for auth pages
- [ ] No integration tests
- [ ] No database/RLS tests
- [ ] No Edge Function tests

#### 7. Documentation
- [ ] No PHASE_2_AUTH_IMPLEMENTATION.md
- [ ] No PHASE_2_PROFILE_IMPLEMENTATION.md
- [ ] No PHASE_2_MFA_VALIDATION.md
- [ ] No PHASE_2_ACCOUNT_DELETION_VALIDATION.md
- [ ] No PHASE_2_STORAGE_SECURITY.md
- [ ] No PHASE_2_TEST_REPORT.md
- [ ] No PHASE_2_PROGRESS.md
- [ ] README.md needs updates

## Implementation Priority

### Phase 1: Critical Database/Auth Fixes (Week 1)
1. Fix profile FK cascade issue (migration 000004)
2. Fix profile creation trigger to include all required fields
3. Fix avatar bucket to be private with signed URLs
4. Fix storage RLS policies
5. Fix delete-account Edge Function for OAuth users

### Week 2: Flutter Auth Implementation
1. Signup flow with validation
2. Email verification flow (resend, deep link callback)
3. Login with session restoration
4. Password recovery flow
5. Email verification UI

### Week 3: Profile & MFA
1. Profile CRUD (view, edit, avatar)
2. MFA enrollment/challenge/verify using Supabase SDK
3. Profile privacy settings

### Week 4: Account Deletion & Web Auth
1. Account deletion flow (in-app + web)
2. Next.js auth pages (login, register, callback, password reset)
3. Next.js protected routes (organizer/admin dashboards)

### Week 5: Testing & Security
1. Write comprehensive tests
2. Security audit
3. Documentation

## Next Steps

1. **Immediate**: Create migration 000004 to fix database issues
2. **Then**: Fix Edge Functions (delete-account, upload-avatar)
3. **Then**: Implement Flutter auth screens
4. **Then**: Implement Next.js auth pages
5. **Then**: Write tests and documentation