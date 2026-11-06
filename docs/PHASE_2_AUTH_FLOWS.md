# Phase 2 Authentication Flows

## Flow Diagrams

### 1. Signup Flow

```mermaid
sequenceDiagram
    participant U as User
    participant RP as RegisterPage
    participant AB as AuthBloc
    participant UC as SignUpUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    U->>RP: Enters email, password, display name, accepts terms, attests 18+
    RP->>AB: SignUpRequested(email, password, displayName, terms, age)
    AB->>UC: call(email, password, displayName, terms, age)
    UC->>AR: signUp(email, password, displayName, terms, age)
    AR->>DS: signUp(email, password, displayName, terms, age)
    DS->>SB: signUp(email, password)
    SB-->>DS: User (no session) + Email sent
    DS-->>AR: AuthResponse(userId, email, null, null, false, message)
    AR-->>UC: Right(AuthResponse)
    UC-->>AB: Right(AuthResponse)
    AB->>AB: emit(AuthStatus.verificationPending)
    AB-->>RP: Navigate to EmailVerifyPage
    RP-->>U: "Check your email to verify"
```

### 2. Email Verification Flow

```mermaid
sequenceDiagram
    participant U as User
    participant E as Email Client
    participant DL as Deep Link / Web
    participant SB as Supabase Auth
    participant AB as AuthBloc
    participant UC as GetCurrentUserUseCase

    U->>E: Receives verification email
    U->>DL: Clicks verification link (fft://auth/callback?token=...)
    DL->>SB: Verifies token
    SB-->>DL: Session created
    DL->>AB: AuthRestoreSession (via deep link handler)
    AB->>UC: call()
    UC->>SB: getUser()
    SB-->>UC: User + Session
    UC-->>AB: Right(AuthResponse)
    AB->>AB: emit(AuthStatus.authenticated, profile loaded)
    AB-->>U: Navigate to Home/MyTournaments
```

### 3. Login Flow

```mermaid
sequenceDiagram
    participant U as User
    participant LP as LoginPage
    participant AB as AuthBloc
    participant UC as SignInUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    U->>LP: Enters email, password
    LP->>AB: SignInRequested(email, password)
    AB->>UC: call(email, password)
    UC->>AR: signIn(email, password)
    AR->>DS: signIn(email, password)
    DS->>SB: signInWithPassword(email, password)
    alt MFA not enrolled
        SB-->>DS: Session (AAL1)
        DS-->>AR: AuthResponse(userId, email, accessToken, refreshToken, true)
        AR-->>UC: Right(AuthResponse)
        UC-->>AB: Right(AuthResponse)
        AB->>AB: emit(AuthStatus.authenticated)
    else MFA enrolled
        SB-->>DS: MFA Required (AAL1 session, factors)
        DS-->>AR: AuthResponse(..., mfaRequired: true, factors: [...])
        AR-->>UC: Right(AuthResponse)
        UC-->>AB: Right(AuthResponse)
        AB->>AB: emit(AuthStatus.mfaRequired)
    end
    AB-->>LP: Navigate to Home or MFA Challenge
```

### 4. MFA Challenge Flow

```mermaid
sequenceDiagram
    participant U as User
    participant MFA as MFAChallengePage
    participant AB as AuthBloc
    participant UC as ChallengeMfaTotpUseCase
    participant VUC as VerifyMfaTotpUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    Note over U,SB: After login with MFA enrolled
    AB->>AB: emit(AuthStatus.mfaRequired)
    AB-->>MFA: Navigate to MFA Challenge Page
    U->>MFA: Enters 6-digit TOTP code
    MFA->>AB: VerifyMfaTotpRequested(factorId, challengeId, code)
    AB->>VUC: call(factorId, challengeId, code)
    VUC->>AR: verifyMfaTotp(factorId, challengeId, code)
    AR->>DS: verifyMfaTotp(factorId, challengeId, code)
    DS->>SB: verifyTotp(factorId, challengeId, code)
    SB-->>DS: Session (AAL2)
    DS-->>AR: AuthResponse(..., aalLevel: 'aal2', accessToken, refreshToken)
    AR-->>VUC: Right(AuthResponse)
    VUC-->>AB: Right(AuthResponse)
    AB->>AB: emit(AuthStatus.authenticated, aalLevel: 'aal2')
    AB-->>U: Navigate to Home
```

### 5. Password Reset Request Flow

```mermaid
sequenceDiagram
    participant U as User
    participant PRP as PasswordResetRequestPage
    participant AB as AuthBloc
    participant UC as ResetPasswordUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth
    participant E as Email Service

    U->>PRP: Enters email
    PRP->>AB: ResetPasswordRequested(email)
    AB->>UC: call(email)
    UC->>AR: resetPassword(email)
    AR->>DS: resetPassword(email)
    DS->>SB: resetPasswordForEmail(email)
    SB->>E: Sends reset email with token
    E-->>U: Email received
    SB-->>DS: Ok
    DS-->>AR: Unit
    AR-->>UC: Right(Unit)
    UC-->>AB: Right(Unit)
    AB->>AB: emit(isPasswordResetSent: true)
    AB-->>PRP: Show "Email sent" state
```

### 6. Password Reset Confirm Flow

```mermaid
sequenceDiagram
    participant U as User
    participant E as Email Client
    participant DL as Deep Link / Web
    participant PRC as PasswordResetConfirmPage
    participant AB as AuthBloc
    participant UC as UpdatePasswordUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    U->>E: Receives reset email
    U->>DL: Clicks reset link (fft://auth/callback?token=...)
    DL->>SB: Verifies token, shows reset page
    DL->>PRC: Opens with token in URL
    U->>PRC: Enters new password, confirms
    PRC->>AB: UpdatePasswordRequested(password)
    AB->>UC: call(password)
    UC->>AR: updatePassword(password)
    AR->>DS: updatePassword(password)
    DS->>SB: updateUser(password: newPassword)
    SB-->>DS: Updated User
    DS-->>AR: AuthResponse
    AR-->>UC: Right(AuthResponse)
    UC-->>AB: Right(AuthResponse)
    AB->>AB: emit(AuthStatus.authenticated) or emit(isPasswordChanged: true)
    AB-->>PRC: Navigate to Login
```

### 7. Profile Management Flow

```mermaid
sequenceDiagram
    participant U as User
    participant PP as ProfilePage
    participant AB as AuthBloc
    participant UC as GetProfileUseCase / UpdateProfileUseCase
    participant PR as ProfileRepository
    participant DS as ProfileRemoteDataSource
    participant DB as Supabase DB (profiles table)

    Note over U,DB: View Profile
    U->>PP: Opens Profile tab
    PP->>AB: AuthLoadProfile()
    AB->>UC: call()
    UC->>PR: getProfile()
    PR->>DS: getProfile()
    DS->>DB: SELECT * FROM profiles WHERE id = user.id
    DB-->>DS: Profile row
    DS-->>PR: Profile
    PR-->>UC: Right(Profile)
    UC-->>AB: Right(Profile)
    AB->>AB: emit(profile: Profile)
    AB-->>PP: Display profile

    Note over U,DB: Update Profile
    U->>PP: Taps "Edit Profile" → Edits fields → Saves
    PP->>AB: UpdateProfileRequested(...)
    AB->>UC: call(...)
    UC->>PR: updateProfile(...)
    PR->>DS: updateProfile(...)
    DS->>DB: UPDATE profiles SET ... WHERE id = user.id
    DB-->>DS: Updated row
    DS-->>PR: Profile
    PR-->>UC: Right(Profile)
    UC-->>AB: Right(Profile)
    AB->>AB: emit(profile: updatedProfile)
    AB-->>PP: Show updated profile
```

### 8. MFA Enrollment Flow

```mermaid
sequenceDiagram
    participant U as User
    participant SP as SecurityPage
    participant AB as AuthBloc
    participant EUC as EnrollMfaTotpUseCase
    participant VUC as VerifyMfaTotpUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    U->>SP: Taps "Enable MFA"
    SP->>AB: EnrollMfaTotpRequested()
    AB->>EUC: call()
    EUC->>AR: enrollMfaTotp()
    AR->>DS: enrollMfaTotp()
    DS->>SB: enrollTotp()
    SB-->>DS: MfaEnrollResponse(factorId, qrCode, secret, uri)
    DS-->>AR: Right(MfaEnrollResponse)
    AR-->>EUC: Right(MfaEnrollResponse)
    EUC-->>AB: Right(MfaEnrollResponse)
    AB->>AB: emit(AuthStatus.mfaEnrollment, mfaEnrollment: response)
    AB-->>SP: Show QR code + secret
    U->>Authenticator: Scans QR / Enters secret
    U->>SP: Enters 6-digit code
    SP->>AB: VerifyMfaTotpRequested(factorId, challengeId, code)
    AB->>VUC: call(factorId, challengeId, code)
    VUC->>AR: verifyMfaTotp(factorId, challengeId, code)
    AR->>DS: verifyMfaTotp(factorId, challengeId, code)
    DS->>SB: verifyTotp(factorId, challengeId, code)
    SB-->>DS: Verified + Session (AAL2)
    DS-->>AR: Right(MfaVerifyResponse)
    AR-->>VUC: Right(MfaVerifyResponse)
    VUC-->>AB: Right(MfaVerifyResponse)
    AB->>AB: emit(AuthStatus.authenticated, aalLevel: 'aal2')
    AB-->>SP: Show recovery codes
```

### 9. Account Deletion Flow

```mermaid
sequenceDiagram
    participant U as User
    participant DP as DangerZonePage
    participant AB as AuthBloc
    participant UC as DeleteAccountUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth
    participant DB as Supabase DB

    U->>DP: Taps "Delete Account"
    DP->>DP: Shows confirmation dialog
    U->>DP: Enters password, confirms
    DP->>AB: DeleteAccountRequested(password)
    AB->>UC: call(password)
    UC->>AR: deleteAccount(password)
    AR->>DS: deleteAccount(password)
    DS->>SB: deleteUser() (requires recent auth)
    alt Password invalid
        SB-->>DS: Error: Weak password / Not authorized
        DS-->>AR: Left(AuthFailure)
        AR-->>UC: Left(AuthFailure)
        UC-->>AB: Left(AuthFailure)
        AB->>AB: emit(AuthStatus.failure, error)
    else Success
        SB-->>DS: User deleted
        DS->>DB: DELETE FROM profiles WHERE id = user.id (RLS)
        DS-->>AR: Right(Unit)
        AR-->>UC: Right(Unit)
        UC-->>AB: Right(Unit)
        AB->>AB: emit(AuthState.initial())
        AB-->>DP: Navigate to Login
    end
```

### 10. Session Restoration Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as App (main.dart)
    participant AB as AuthBloc
    participant UC as GetCurrentUserUseCase
    participant AR as AuthRepository
    participant DS as AuthRemoteDataSource
    participant SB as Supabase Auth

    Note over U,SB: App cold start
    U->>A: Launches app
    A->>A: HydratedBloc restores state
    A->>SB: SupabaseClientManager.initialize()
    SB-->>A: Client ready
    A->>AB: AuthRestoreSession()
    AB->>UC: call()
    UC->>AR: getCurrentUser()
    AR->>DS: getCurrentUser()
    DS->>SB: getUser() / getSession()
    alt Valid session
        SB-->>DS: User + Session
        DS-->>AR: AuthResponse
        AR-->>UC: Right(AuthResponse)
        UC-->>AB: Right(AuthResponse)
        AB->>AB: emit(AuthStatus.authenticated)
        AB->>AB: add(AuthLoadProfile())
    else No session / Expired
        SB-->>DS: null / Error
        DS-->>AR: Left(AuthFailure) or Right(null)
        AR-->>UC: Left(AuthFailure) or Right(null)
        UC-->>AB: Left/Right(null)
        AB->>AB: emit(AuthState.initial())
    end
```

## Screen State Machines

### Login Page

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Validating: Submit pressed
    Validating --> Error: Invalid input
    Validating --> Loading: Valid input
    Loading --> Authenticated: Success
    Loading --> Error: Failure
    Loading --> MFARequired: MFA enrolled
    Error --> Idle: Dismiss
    Authenticated --> [*]: Navigate away
    MFARequired --> [*]: Navigate to MFA
```

### Register Page

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Validating: Submit pressed
    Validating --> Error: Invalid input
    Validating --> Loading: Valid input
    Loading --> VerificationPending: Success
    Loading --> Error: Failure
    VerificationPending --> [*]: Navigate to EmailVerify
    Error --> Idle: Dismiss
```

### Email Verify Page

```mermaid
stateDiagram-v2
    [*] --> Waiting
    Waiting --> Resending: Resend pressed
    Resending --> Waiting: Email sent
    Waiting --> Verified: Deep link received
    Verified --> [*]: Navigate to Home
```

### Password Reset Request

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Validating: Submit pressed
    Validating --> Error: Invalid email
    Validating --> Loading: Valid email
    Loading --> Sent: Success
    Loading --> Error: Failure
    Sent --> [*]: Navigate to Login (or stay)
```

### Password Reset Confirm

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Validating: Submit pressed
    Validating --> Error: Mismatch / Weak
    Validating --> Loading: Valid
    Loading --> Updated: Success
    Loading --> Error: Failure
    Updated --> [*]: Navigate to Login
```

### MFA Enrollment

```mermaid
stateDiagram-v2
    [*] --> ShowQR
    ShowQR --> Verifying: Code entered
    Verifying --> Enrolled: Valid code
    Verifying --> Error: Invalid code
    Error --> ShowQR: Retry
    Enrolled --> ShowRecovery: Success
    ShowRecovery --> [*]: Navigate to Security
```

### MFA Challenge

```mermaid
stateDiagram-v2
    [*] --> Waiting
    Waiting --> Verifying: Code entered
    Verifying --> Authenticated: Valid code (AAL2)
    Verifying --> Error: Invalid code
    Error --> Waiting: Retry
    Authenticated --> [*]: Navigate to Home
```

### Profile Page

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> Loaded: Profile fetched
    Loading --> Error: Fetch failed
    Loaded --> Editing: Edit tapped
    Editing --> Saving: Save pressed
    Saving --> Loaded: Success
    Saving --> Error: Failure
    Error --> Loaded: Retry/Dismiss
```

## Error States

| Screen | Error Type | Message | Action |
|---|---|---|---|
| Login | Invalid credentials | "Invalid email or password" | Retry |
| Login | Email not verified | "Please verify your email first" | Go to EmailVerify |
| Login | MFA required | (Navigate to MFA) | Auto-navigate |
| Register | Email exists | "An account with this email already exists" | Go to Login |
| Register | Weak password | "Password must be at least 8 characters" | Fix input |
| Email Verify | Expired link | "This link has expired. Request a new one." | Resend |
| Email Verify | Invalid link | "This verification link is invalid" | Resend |
| Password Reset | Expired token | "This reset link has expired" | Request new |
| Password Reset | Invalid token | "This reset link is invalid" | Request new |
| Password Change | Wrong password | "Current password is incorrect" | Retry |
| Email Change | Pending | "Confirmation sent to new email" | Check email |
| MFA Enrollment | Invalid code | "Invalid code. Try again." | Retry |
| MFA Challenge | Invalid code | "Invalid code. Try again." | Retry |
| MFA Challenge | Rate limited | "Too many attempts. Wait before retrying." | Wait |
| Account Delete | Wrong password | "Password is incorrect" | Retry |
| Account Delete | Network error | "Could not delete account. Try again." | Retry |
| Profile Update | Username taken | "This username is already taken" | Choose another |
| Network | Offline | "No internet connection. Please try again." | Retry |
| Server | 5xx | "Server error. Please try again later." | Retry |

## Loading States

| Screen | Loading Indicator | Disabled Elements |
|---|---|---|
| Login | Button spinner | Email, password, submit |
| Register | Button spinner | All fields, submit |
| Email Verify | Button spinner (resend) | Resend button |
| Password Reset Request | Button spinner | Email, submit |
| Password Reset Confirm | Button spinner | Passwords, submit |
| MFA Enrollment | None (QR static) | Verify button |
| MFA Challenge | Button spinner | Code field, submit |
| Password Change | Button spinner | All fields, submit |
| Email Change | Button spinner | Email, submit |
| Account Delete | Button spinner | Password, confirm, delete |
| Profile | Inline spinner (avatar) | Save button |

## Accessibility

- All form fields have labels
- Error messages announced via `Semantics`
- Focus order logical (top to bottom)
- Color contrast meets WCAG AA
- Touch targets ≥ 48dp
- Screen reader tested (TalkBack, VoiceOver)

## Deep Link Handling

```dart
// main.dart
GoRouter(
  routes: [
    GoRoute(
      path: '/auth/callback',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        final type = state.uri.queryParameters['type'];
        // Handle verification, password reset, MFA
        return AuthCallbackPage(token: token, type: type);
      },
    ),
  ],
)
```

## Platform-Specific Notes

### Android
- `flutter_deep_linking` for app links
- `android:autoVerify="true"` for verified links
- `assetlinks.json` for domain verification

### iOS
- `Associated Domains` entitlement
- `apple-app-site-association` file
- Universal Links for seamless experience

### Web
- Supabase handles OAuth redirects
- PKCE flow for security
- No deep linking needed (same origin)

## Rate Limits (Supabase Defaults)

| Operation | Limit | Window |
|---|---|---|
| Sign up | 3 | hour |
| Sign in | 10 | hour |
| Password reset | 3 | hour |
| Email verification | 3 | hour |
| MFA enroll | 5 | hour |
| MFA verify | 10 | minute |
| Token refresh | 10 | minute |

Client-side: Debounce form submissions (500ms), disable buttons during loading.

## Migration Notes

When adding new auth features:
1. Add event to `AuthEvent`
2. Add state field to `AuthState`
3. Add handler in `AuthBloc`
4. Create use case
5. Add repository method
6. Add data source method
7. Add UI screen
8. Add route in `AppRoutes`
9. Write tests
10. Update this document