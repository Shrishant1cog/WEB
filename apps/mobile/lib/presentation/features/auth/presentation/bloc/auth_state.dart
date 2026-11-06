/// Auth State
/// Manages the authentication state of the application

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/auth_models.dart';
import '../../../../../data/models/profile_models.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

// JsonConverters for freezed models used in AuthState
class AuthResponseConverter implements JsonConverter<AuthResponse?, Map<String, dynamic>?> {
  const AuthResponseConverter();

  @override
  AuthResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AuthResponse.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthResponse? object) => object?.toJson();
}

class MfaEnrollResponseConverter implements JsonConverter<MfaEnrollResponse?, Map<String, dynamic>?> {
  const MfaEnrollResponseConverter();

  @override
  MfaEnrollResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return MfaEnrollResponse.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(MfaEnrollResponse? object) => object?.toJson();
}

class MfaChallengeResponseConverter implements JsonConverter<MfaChallengeResponse?, Map<String, dynamic>?> {
  const MfaChallengeResponseConverter();

  @override
  MfaChallengeResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return MfaChallengeResponse.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(MfaChallengeResponse? object) => object?.toJson();
}

class MfaFactorModelConverter implements JsonConverter<List<MfaFactorModel>, List<dynamic>> {
  const MfaFactorModelConverter();

  @override
  List<MfaFactorModel> fromJson(List<dynamic> json) {
    return json.map((e) => MfaFactorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<dynamic> toJson(List<MfaFactorModel> object) => object.map((e) => e.toJson()).toList();
}

class ProfileConverter implements JsonConverter<Profile?, Map<String, dynamic>?> {
  const ProfileConverter();

  @override
  Profile? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Profile.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(Profile? object) => object?.toJson();
}

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

class AuthStatusConverter implements JsonConverter<AuthStatus, String> {
  const AuthStatusConverter();

  @override
  AuthStatus fromJson(String json) {
    switch (json) {
      case 'initial':
        return const AuthStatus.initial();
      case 'unauthenticated':
        return const AuthStatus.unauthenticated();
      case 'loading':
        return const AuthStatus.loading();
      case 'authenticated':
        return const AuthStatus.authenticated();
      case 'verificationPending':
        return const AuthStatus.verificationPending();
      case 'mfaRequired':
        return const AuthStatus.mfaRequired();
      case 'mfaEnrollment':
        return const AuthStatus.mfaEnrollment();
      case 'mfaChallenge':
        return const AuthStatus.mfaChallenge();
      case 'failure':
        return const AuthStatus.failure();
      default:
        return const AuthStatus.initial();
    }
  }

  @override
  String toJson(AuthStatus object) {
    return object.when(
      initial: () => 'initial',
      unauthenticated: () => 'unauthenticated',
      loading: () => 'loading',
      authenticated: () => 'authenticated',
      verificationPending: () => 'verificationPending',
      mfaRequired: () => 'mfaRequired',
      mfaEnrollment: () => 'mfaEnrollment',
      mfaChallenge: () => 'mfaChallenge',
      failure: () => 'failure',
    );
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial()) @AuthStatusConverter() AuthStatus status,
    String? userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    @Default(false) bool emailVerified,
    @Default(false) bool mfaRequired,
    @Default('aal1') String aalLevel,
    String? error,
    @AuthResponseConverter() AuthResponse? authResponse,
    @ProfileConverter() Profile? profile,
    @MfaEnrollResponseConverter() MfaEnrollResponse? mfaEnrollment,
    @MfaChallengeResponseConverter() MfaChallengeResponse? mfaChallenge,
    @MfaFactorModelConverter() @Default([]) List<MfaFactorModel> mfaFactors,
    @Default(false) bool isPasswordResetSent,
    @Default(false) bool isPasswordChanged,
    @Default(false) bool isEmailChangePending,
    @Default(false) bool isDeletingAccount,
    @Default(false) bool isLoading,
  }) = _AuthState;

  factory AuthState.initial() => const AuthState(
        status: AuthStatus.initial(),
      );
}