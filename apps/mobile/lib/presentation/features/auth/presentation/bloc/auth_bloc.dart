/// Auth Bloc
/// Manages authentication state and operations

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../../core/network/supabase_client.dart';
import '../../../../../domain/usecases/auth/sign_up_use_case.dart';
import '../../../../../domain/usecases/auth/sign_in_use_case.dart';
import '../../../../../domain/usecases/auth/sign_out_use_case.dart';
import '../../../../../domain/usecases/auth/reset_password_use_case.dart';
import '../../../../../domain/usecases/auth/verify_email_use_case.dart';
import '../../../../../domain/usecases/auth/get_current_user_use_case.dart';
import '../../../../../domain/usecases/auth/delete_account_use_case.dart';
import '../../../../../domain/usecases/auth/change_password_use_case.dart';
import '../../../../../domain/usecases/auth/update_email_use_case.dart';
import '../../../../../domain/usecases/auth/enroll_mfa_totp_use_case.dart';
import '../../../../../domain/usecases/auth/challenge_mfa_totp_use_case.dart';
import '../../../../../domain/usecases/auth/verify_mfa_totp_use_case.dart';
import '../../../../../domain/usecases/auth/list_mfa_factors_use_case.dart';
import '../../../../../domain/usecases/auth/unenroll_mfa_factor_use_case.dart';
import '../../../../../domain/usecases/auth/update_password_use_case.dart';
import '../../../../../domain/usecases/profile/get_profile_use_case.dart';
import '../../../../../domain/usecases/profile/update_profile_use_case.dart';
import '../../../../../domain/usecases/profile/update_privacy_settings_use_case.dart';
import '../../../../../data/models/profile_models.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_state.g.dart';

@injectable
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final UpdateEmailUseCase _updateEmailUseCase;
  final EnrollMfaTotpUseCase _enrollMfaTotpUseCase;
  final ChallengeMfaTotpUseCase _challengeMfaTotpUseCase;
  final VerifyMfaTotpUseCase _verifyMfaTotpUseCase;
  final ListMfaFactorsUseCase _listMfaFactorsUseCase;
  final UnenrollMfaFactorUseCase _unenrollMfaFactorUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdatePrivacySettingsUseCase _updatePrivacySettingsUseCase;

  AuthBloc(
    this._signUpUseCase,
    this._signInUseCase,
    this._signOutUseCase,
    this._resetPasswordUseCase,
    this._verifyEmailUseCase,
    this._getCurrentUserUseCase,
    this._deleteAccountUseCase,
    this._changePasswordUseCase,
    this._updateEmailUseCase,
    this._enrollMfaTotpUseCase,
    this._challengeMfaTotpUseCase,
    this._verifyMfaTotpUseCase,
    this._listMfaFactorsUseCase,
    this._unenrollMfaFactorUseCase,
    this._updatePasswordUseCase,
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._updatePrivacySettingsUseCase,
  ) : super(AuthState.initial()) {
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthVerifyEmailRequested>(_onVerifyEmailRequested);
    on<AuthResendVerificationRequested>(_onResendVerificationRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
    on<AuthUpdateEmailRequested>(_onUpdateEmailRequested);
    on<AuthEnrollMfaTotpRequested>(_onEnrollMfaTotpRequested);
    on<AuthChallengeMfaTotpRequested>(_onChallengeMfaTotpRequested);
    on<AuthVerifyMfaTotpRequested>(_onVerifyMfaTotpRequested);
    on<AuthListMfaFactorsRequested>(_onListMfaFactorsRequested);
    on<AuthUnenrollMfaFactorRequested>(_onUnenrollMfaFactorRequested);
    on<AuthUpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<AuthRestoreSession>(_onRestoreSession);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUpdatePrivacySettingsRequested>(_onUpdatePrivacySettingsRequested);
    on<AuthLoadProfile>(_onLoadProfile);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthMfaRequired>(_onMfaRequired);
    on<AuthAuthCallback>(_onAuthCallback);
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _signUpUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      termsAccepted: event.termsAccepted,
      ageAttestation: event.ageAttestation,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (response) {
        if (response.emailVerified == true) {
          emit(state.copyWith(
            status: AuthStatus.authenticated(),
            userId: response.userId,
            email: response.email,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            emailVerified: true,
            error: null,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.verificationPending(),
            userId: response.userId,
            email: response.email,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            emailVerified: false,
            error: response.message,
          ));
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _signInUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (response) {
        emit(state.copyWith(
          status: AuthStatus.authenticated(),
          userId: response.userId,
          email: response.email,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          emailVerified: response.emailVerified ?? false,
          mfaRequired: false,
          error: null,
        ));
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (_) => emit(AuthState.initial()),
    );
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading(), isPasswordResetSent: false));
    final result = await _resetPasswordUseCase(email: event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
        isPasswordResetSent: false,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated(),
        isPasswordResetSent: true,
        error: 'Password reset email sent',
      )),
    );
  }

  Future<void> _onVerifyEmailRequested(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Email verification is handled by Supabase via deep link
    // This event is for resending verification
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _verifyEmailUseCase(email: event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.verificationPending(),
        error: 'Verification email sent',
      )),
    );
  }

  Future<void> _onResendVerificationRequested(
    AuthResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _verifyEmailUseCase(email: event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.verificationPending(),
        error: 'Verification email resent',
      )),
    );
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading(), isDeletingAccount: true));
    final result = await _deleteAccountUseCase(password: event.password);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
        isDeletingAccount: false,
      )),
      (_) => emit(AuthState.initial()),
    );
  }

  Future<void> _onChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading(), isPasswordChanged: false));
    final result = await _changePasswordUseCase(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
        isPasswordChanged: false,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        isPasswordChanged: true,
        error: 'Password changed successfully',
      )),
    );
  }

  Future<void> _onUpdateEmailRequested(
    AuthUpdateEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading(), isEmailChangePending: true));
    final result = await _updateEmailUseCase(email: event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
        isEmailChangePending: false,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        isEmailChangePending: true,
        error: 'Email change requested. Please check your new email to confirm.',
      )),
    );
  }

  Future<void> _onEnrollMfaTotpRequested(
    AuthEnrollMfaTotpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _enrollMfaTotpUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: AuthStatus.mfaEnrollment(),
        mfaEnrollment: response,
        error: null,
      )),
    );
  }

  Future<void> _onChallengeMfaTotpRequested(
    AuthChallengeMfaTotpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _challengeMfaTotpUseCase(factorId: event.factorId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: AuthStatus.mfaChallenge(),
        mfaChallenge: response,
        error: null,
      )),
    );
  }

  Future<void> _onVerifyMfaTotpRequested(
    AuthVerifyMfaTotpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _verifyMfaTotpUseCase(
      factorId: event.factorId,
      challengeId: event.challengeId,
      code: event.code,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        aalLevel: 'aal2',
        error: null,
      )),
    );
  }

  Future<void> _onListMfaFactorsRequested(
    AuthListMfaFactorsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _listMfaFactorsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (factors) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        mfaFactors: factors,
      )),
    );
  }

  Future<void> _onUnenrollMfaFactorRequested(
    AuthUnenrollMfaFactorRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _unenrollMfaFactorUseCase(factorId: event.factorId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        error: 'MFA factor removed',
      )),
    );
  }

  Future<void> _onUpdatePasswordRequested(
    AuthUpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _updatePasswordUseCase(password: event.password);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        error: 'Password updated successfully',
      )),
    );
  }

  Future<void> _onRestoreSession(
    AuthRestoreSession event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthState.initial()),
      (response) {
        emit(state.copyWith(
          status: AuthStatus.authenticated(),
          userId: response.userId,
          email: response.email,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          emailVerified: response.emailVerified ?? false,
          error: null,
        ));
        // Load profile
        add(AuthLoadProfile());
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _updateProfileUseCase(
      displayName: event.displayName,
      username: event.username,
      inGameName: event.inGameName,
      inGameUid: event.inGameUid,
      privacyProfileVisibility: event.privacyProfileVisibility,
      privacyShowInGameInfo: event.privacyShowInGameInfo,
      notificationPrefs: event.notificationPrefs,
      avatarUrl: event.avatarUrl,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        profile: profile,
        error: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _onUpdatePrivacySettingsRequested(
    AuthUpdatePrivacySettingsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    final result = await _updatePrivacySettingsUseCase(
      profileVisibility: event.profileVisibility,
      showInGameInfo: event.showInGameInfo,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure(),
        error: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: AuthStatus.authenticated(),
        profile: profile,
        error: 'Privacy settings updated',
      )),
    );
  }

  Future<void> _onLoadProfile(
    AuthLoadProfile event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
      )),
      (Profile profile) => emit(state.copyWith(
        profile: profile,
      )),
    );
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.initial());
  }

  Future<void> _onMfaRequired(
    AuthMfaRequired event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.mfaRequired(),
      mfaRequired: true,
    ));
  }

  Future<void> _onAuthCallback(
    AuthAuthCallback event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading()));
    try {
      final client = Supabase.instance.client;
      final response = await client.auth.getSessionFromUrl(Uri.parse(event.token));
      if (response.session != null) {
        final user = response.session!.user;
        emit(state.copyWith(
          status: AuthStatus.authenticated(),
          userId: user.id,
          email: user.email,
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken,
          emailVerified: user.emailConfirmedAt != null,
          error: null,
        ));
        // Load profile
        add(AuthLoadProfile());
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure(),
          error: 'Invalid or expired link',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure(),
        error: 'Failed to verify link: ${e.toString()}',
      ));
    }
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    return _$AuthStateFromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return _$AuthStateToJson(state as _AuthState);
  }
}