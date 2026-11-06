# Phase 2 Authentication Design

## Overview

This document describes the authentication system for the FFT mobile application, implemented with Supabase as the backend and Flutter Bloc for state management.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Login     │  │  Register   │  │  Password Reset     │  │
│  │   Page      │  │   Page      │  │  Request/Confirm    │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
│         ▼                ▼                     ▼             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   AuthBloc                           │   │
│  │  Events: SignUp, SignIn, SignOut, ResetPassword,    │   │
│  │  VerifyEmail, UpdatePassword, UpdateEmail,          │   │
│  │  EnrollMFA, ChallengeMFA, VerifyMFA, DeleteAccount  │   │
│  └────────────────────────┬────────────────────────────┘   │
└───────────────────────────│──────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Auth     │  │   Profile   │  │       MFA           │  │
│  │ Repository  │  │ Repository  │  │    Use Cases        │  │
│  │ Interface   │  │ Interface   │  │                     │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────│─────────────────│────────────────────│─────────────┘
          │                 │                    │
          ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ AuthRemote      │  │ ProfileRemote   │                  │
│  │ DataSource      │  │ DataSource      │                  │
│  │ (Supabase SDK)  │  │ (Supabase SDK)  │                  │
│  └─────────────────┘  └─────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Backend                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Auth     │  │  Database   │  │      Storage        │  │
│  │  (GoTrue)   │  │ (PostgreSQL)│  │   (Avatars, etc.)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Authentication Flows

### 1. Email/Password Signup

```
User → RegisterPage → AuthBloc.add(SignUpRequested)
                                    │
                                    ▼
                          SignUpUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.signUp()
                                    │
                                    ▼
                          Supabase Auth.signUp()
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │  Email Sent         │
                          │  User Created       │
                          │  Session: None*     │
                          └─────────────────────┘
                                    │
                                    ▼
                          Navigate to EmailVerifyPage
                          Show "Check your email" message
```

*With email confirmation enabled, Supabase returns a user but no session until email is verified.

### 2. Email Verification

```
User clicks link in email
        │
        ▼
Deep link / Web callback → /auth/callback
        │
        ▼
Supabase verifies token → Creates session
        │
        ▼
App receives session → AuthBloc.add(AuthRestoreSession)
        │
        ▼
AuthBloc → GetCurrentUserUseCase → Profile loaded
        │
        ▼
Navigate to Home/MyTournaments
```

### 3. Login

```
User → LoginPage → AuthBloc.add(SignInRequested)
                                    │
                                    ▼
                          SignInUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.signIn()
                                    │
                                    ▼
                          Supabase Auth.signInWithPassword()
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │  Session Created    │
                          │  AuthState Updated  │
                          │  Profile Loaded     │
                          └─────────────────────┘
                                    │
                                    ▼
                          Navigate to MyTournaments
```

### 4. Password Reset

```
User → PasswordResetRequestPage → AuthBloc.add(ResetPasswordRequested)
                                    │
                                    ▼
                          ResetPasswordUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.resetPassword()
                                    │
                                    ▼
                          Supabase Auth.resetPasswordForEmail()
                                    │
                                    ▼
                          Email sent with reset link
                                    │
                                    ▼
                          Show "Check your email" message
```

```
User clicks reset link → /reset-password?token=...
        │
        ▼
PasswordResetConfirmPage → User enters new password
        │
        ▼
AuthBloc.add(UpdatePasswordRequested)
                                    │
                                    ▼
                          UpdatePasswordUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.updatePassword()
                                    │
                                    ▼
                          Supabase Auth.updateUser(password: ...)
                                    │
                                    ▼
                          Password updated → Navigate to Login
```

### 5. Password Change (Authenticated)

```
User → Settings → Change Password
        │
        ▼
AuthBloc.add(ChangePasswordRequested)
                                    │
                                    ▼
                          ChangePasswordUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.changePassword()
                                    │
                                    ▼
                          Supabase Auth.updateUser(password: ...)
                                    │
                                    ▼
                          Success → Show confirmation
```

### 6. Email Change (Authenticated)

```
User → Settings → Change Email
        │
        ▼
AuthBloc.add(UpdateEmailRequested)
                                    │
                                    ▼
                          UpdateEmailUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.updateEmail()
                                    │
                                    ▼
                          Supabase Auth.updateUser(email: ...)
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │  Confirmation Email │
                          │  Sent to NEW email  │
                          │  Status: Pending    │
                          └─────────────────────┘
                                    │
                                    ▼
                          Show "Check new email" message
```

```
User clicks confirmation link
        │
        ▼
Email verified → Supabase updates auth identity
        │
        ▼
AuthBloc restores session → New email active
```

### 7. TOTP MFA Enrollment

```
User → Settings → Security → Enable MFA
        │
        ▼
AuthBloc.add(EnrollMfaTotpRequested)
                                    │
                                    ▼
                          EnrollMfaTotpUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.enrollMfaTotp()
                                    │
                                    ▼
                          Supabase Auth.enrollTotp()
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │  QR Code / Secret   │
                          │  URI for Authenticator│
                          │  Factor ID          │
                          └─────────────────────┘
                                    │
                                    ▼
                          Show QR code → User scans
                                    │
                                    ▼
                          User enters 6-digit code
                                    │
                                    ▼
                          AuthBloc.add(VerifyMfaTotpRequested)
                                    │
                                    ▼
                          VerifyMfaTotpUseCase → AuthRepository
                                    │
                                    ▼
                          Supabase Auth.verifyTotp()
                                    │
                                    ▼
                          MFA Enrolled → Show recovery codes
```

### 8. MFA Challenge (Login with MFA)

```
User → LoginPage → SignInRequested
        │
        ▼
Supabase returns: MFA Required (AAL1 session)
        │
        ▼
AuthBloc emits AuthStatus.mfaRequired()
        │
        ▼
Navigate to MFA Challenge Page
        │
        ▼
AuthBloc.add(ChallengeMfaTotpRequested)
                                    │
                                    ▼
                          ChallengeMfaTotpUseCase
                                    │
                                    ▼
                          Supabase Auth.challengeTotp()
                                    │
                                    ▼
                          Challenge ID returned
                                    │
                                    ▼
                          User enters 6-digit code
                                    │
                                    ▼
                          AuthBloc.add(VerifyMfaTotpRequested)
                                    │
                                    ▼
                          Supabase Auth.verifyTotp()
                                    │
                                    ▼
                          AAL2 Session created → Full access
```

### 9. Account Deletion

```
User → Settings → Danger Zone → Delete Account
        │
        ▼
Show confirmation dialog (warn: irreversible)
        │
        ▼
User confirms + enters password
        │
        ▼
AuthBloc.add(DeleteAccountRequested)
                                    │
                                    ▼
                          DeleteAccountUseCase → AuthRepository
                                    │
                                    ▼
                          AuthRemoteDataSource.deleteAccount()
                                    │
                                    ▼
                          ┌─────────────────────┐
                          │  Supabase Auth      │
                          │  .deleteUser()      │
                          │  (requires recent   │
                          │   reauthentication) │
                          └─────────────────────┘
                                    │
                                    ▼
                          Profile data deleted (RLS)
                                    │
                                    ▼
                          AuthState → Initial
                                    │
                                    ▼
                          Navigate to Login
```

## Supabase Configuration

### Auth Settings

```sql
-- Enable email confirmation
UPDATE auth.config SET email_confirm_required = true;

-- Set password requirements
UPDATE auth.config SET password_min_length = 8;

-- Rate limits
UPDATE auth.config SET rate_limit_email_sent = 3;  -- per hour
UPDATE auth.config SET rate_limit_sms_sent = 3;    -- per hour
UPDATE auth.config SET rate_limit_token_refresh = 10; -- per minute
```

### Email Templates

- **Confirm signup**: Sent on signup, contains verification link
- **Reset password**: Sent on password reset request
- **Magic link**: Not used (email/password only)
- **Email change**: Sent when email is updated
- **MFA enrollment**: Not used (QR code shown in-app)

### Deep Links

```
# Android
<activity android:name="io.supabase.flutter.SupabaseFlutterActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="fft" android:host="auth" />
    </intent-filter>
</activity>

# iOS
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array><string>fft</string></array>
    </dict>
</array>
```

Callback URLs:
- `fft://auth/callback` - Email verification, password reset
- `fft://auth/mfa` - MFA challenge (if needed)

## State Management

### AuthState

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial()) AuthStatus status,
    String? userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    @Default(false) bool emailVerified,
    @Default(false) bool mfaRequired,
    @Default('aal1') String aalLevel,
    String? error,
    AuthResponse? authResponse,
    Profile? profile,
    MfaEnrollResponse? mfaEnrollment,
    MfaChallengeResponse? mfaChallenge,
    @Default([]) List<MfaFactorModel> mfaFactors,
    @Default(false) bool isPasswordResetSent,
    @Default(false) bool isPasswordChanged,
    @Default(false) bool isEmailChangePending,
    @Default(false) bool isDeletingAccount,
    @Default(false) bool isLoading,
  }) = _AuthState;
}
```

### AuthStatus

```dart
@freezed
class AuthStatus with _$AuthStatus {
  const factory AuthStatus.initial() = _Initial;
  const factory AuthStatus.unauthenticated() = _Unauthenticated;
  const factory AuthStatus.loading() = _Loading;
  const factory AuthStatus.authenticated() = _Authenticated;
  const factory AuthStatus.verificationPending() = _VerificationPending;
  const factory AuthStatus.mfaRequired() = _MfaRequired;
  const factory AuthStatus.mfaEnrollment() = _MfaEnrollment;
  const factory AuthStatus.mfaChallenge() = _MfaChallenge;
  const factory AuthStatus.failure() = _Failure;
}
```

### Hydrated Persistence

Only non-sensitive UI state is persisted:
- Last used email (for convenience)
- Theme preference
- Onboarding completion status

**Never persisted:**
- Access tokens
- Refresh tokens
- User credentials
- MFA secrets

## Security Considerations

### Token Storage

- Access/refresh tokens stored in Supabase SDK secure storage
- Flutter Secure Storage for app-specific secrets
- No tokens in SharedPreferences or HydratedBloc

### Session Management

- Automatic token refresh via Supabase SDK
- Session restored on app start via `onAuthStateChange`
- Explicit sign-out clears all local state

### Rate Limiting

- Supabase handles auth rate limits
- Client-side debounce on form submissions
- Exponential backoff on API errors

### Account Enumeration Prevention

- All auth endpoints return generic messages
- "If the email exists, a reset link has been sent"
- No distinction between "user not found" and "email sent"

### MFA

- TOTP only (RFC 6238)
- Supabase handles secret generation/storage
- Recovery codes generated on enrollment
- AAL2 required for privileged operations

## Error Handling

### AuthError Codes

| Code | HTTP | Description |
|---|---|---|
| `INVALID_CREDENTIALS` | 400 | Wrong email/password |
| `EMAIL_NOT_CONFIRMED` | 400 | Verify email first |
| `USER_ALREADY_EXISTS` | 400 | Email already registered |
| `WEAK_PASSWORD` | 400 | Doesn't meet requirements |
| `INVALID_TOKEN` | 400 | Expired/invalid reset token |
| `MFA_REQUIRED` | 400 | AAL2 required |
| `INVALID_MFA_CODE` | 400 | Wrong TOTP code |
| `SESSION_EXPIRED` | 401 | Re-authenticate |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Supabase unavailable |

### Client-Side Mapping

```dart
// In AuthRemoteDataSource
catch (e) {
  if (e is AuthException) {
    switch (e.code) {
      case 'invalid_credentials':
        return Left(AuthFailure(message: 'Invalid email or password'));
      case 'email_not_confirmed':
        return Left(AuthFailure(message: 'Please verify your email first'));
      // ...
    }
  }
  return Left(ServerFailure(message: 'An unexpected error occurred'));
}
```

## Testing Strategy

### Unit Tests
- Use case logic (validation, mapping)
- Repository error mapping
- Bloc event handling

### Widget Tests
- Form validation
- Loading states
- Error display
- Navigation triggers

### Integration Tests
- Full signup → verification → login flow
- Password reset flow
- MFA enrollment → challenge
- Session persistence across restarts

### Supabase Local Testing
- Use `supabase start` for local development
- Test email via Inbucket (local SMTP)
- Test deep links with `adb` / `xcrun`

## Future Enhancements

- [ ] Social login (Google, Apple)
- [ ] Passkeys / WebAuthn
- [ ] Device trust / Remember this device
- [ ] Session management UI (revoke other sessions)
- [ ] Security logs / Login history
- [ ] Backup codes for MFA
- [ ] SSO / SAML for organizations