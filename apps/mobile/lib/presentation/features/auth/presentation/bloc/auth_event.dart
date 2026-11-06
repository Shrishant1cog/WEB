/// Auth Events
/// All possible authentication events

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  }) = AuthSignUpRequested;

  const factory AuthEvent.signInRequested({
    required String email,
    required String password,
  }) = AuthSignInRequested;

  const factory AuthEvent.signOutRequested() = AuthSignOutRequested;

  const factory AuthEvent.resetPasswordRequested({
    required String email,
  }) = AuthResetPasswordRequested;

  const factory AuthEvent.verifyEmailRequested({
    required String email,
  }) = AuthVerifyEmailRequested;

  const factory AuthEvent.resendVerificationRequested({
    required String email,
  }) = AuthResendVerificationRequested;

  const factory AuthEvent.deleteAccountRequested({
    required String password,
  }) = AuthDeleteAccountRequested;

  const factory AuthEvent.changePasswordRequested({
    required String currentPassword,
    required String newPassword,
  }) = AuthChangePasswordRequested;

  const factory AuthEvent.updateEmailRequested({
    required String email,
  }) = AuthUpdateEmailRequested;

  const factory AuthEvent.enrollMfaTotpRequested() = AuthEnrollMfaTotpRequested;

  const factory AuthEvent.challengeMfaTotpRequested({
    required String factorId,
  }) = AuthChallengeMfaTotpRequested;

  const factory AuthEvent.verifyMfaTotpRequested({
    required String factorId,
    required String challengeId,
    required String code,
  }) = AuthVerifyMfaTotpRequested;

  const factory AuthEvent.listMfaFactorsRequested() = AuthListMfaFactorsRequested;

  const factory AuthEvent.unenrollMfaFactorRequested({
    required String factorId,
  }) = AuthUnenrollMfaFactorRequested;

  const factory AuthEvent.updatePasswordRequested({
    required String password,
  }) = AuthUpdatePasswordRequested;

  const factory AuthEvent.restoreSession() = AuthRestoreSession;

  const factory AuthEvent.updateProfileRequested({
    String? displayName,
    String? username,
    String? inGameName,
    String? inGameUid,
    String? privacyProfileVisibility,
    bool? privacyShowInGameInfo,
    Map<String, dynamic>? notificationPrefs,
    String? avatarUrl,
  }) = AuthUpdateProfileRequested;

  const factory AuthEvent.updatePrivacySettingsRequested({
    required String profileVisibility,
    required bool showInGameInfo,
  }) = AuthUpdatePrivacySettingsRequested;

  const factory AuthEvent.loadProfile() = AuthLoadProfile;

  const factory AuthEvent.sessionExpired() = AuthSessionExpired;

  const factory AuthEvent.mfaRequired() = AuthMfaRequired;
}