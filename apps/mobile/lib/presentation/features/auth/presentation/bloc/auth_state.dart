/// Auth State
/// Manages the authentication state of the application

import 'package:json_annotation/json_annotation.dart';

import '../../../../../data/models/auth_models.dart';
import '../../../../../data/models/profile_models.dart';

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

enum AuthStatus {
  initial,
  unauthenticated,
  loading,
  authenticated,
  verificationPending,
  mfaRequired,
  mfaEnrollment,
  mfaChallenge,
  failure;
}

class AuthStatusConverter implements JsonConverter<AuthStatus, String> {
  const AuthStatusConverter();

  @override
  AuthStatus fromJson(String json) {
    switch (json) {
      case 'initial':
        return AuthStatus.initial;
      case 'unauthenticated':
        return AuthStatus.unauthenticated;
      case 'loading':
        return AuthStatus.loading;
      case 'authenticated':
        return AuthStatus.authenticated;
      case 'verificationPending':
        return AuthStatus.verificationPending;
      case 'mfaRequired':
        return AuthStatus.mfaRequired;
      case 'mfaEnrollment':
        return AuthStatus.mfaEnrollment;
      case 'mfaChallenge':
        return AuthStatus.mfaChallenge;
      case 'failure':
        return AuthStatus.failure;
      default:
        return AuthStatus.initial;
    }
  }

  @override
  String toJson(AuthStatus object) {
    switch (object) {
      case AuthStatus.initial:
        return 'initial';
      case AuthStatus.unauthenticated:
        return 'unauthenticated';
      case AuthStatus.loading:
        return 'loading';
      case AuthStatus.authenticated:
        return 'authenticated';
      case AuthStatus.verificationPending:
        return 'verificationPending';
      case AuthStatus.mfaRequired:
        return 'mfaRequired';
      case AuthStatus.mfaEnrollment:
        return 'mfaEnrollment';
      case AuthStatus.mfaChallenge:
        return 'mfaChallenge';
      case AuthStatus.failure:
        return 'failure';
    }
  }
}

@JsonSerializable()
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.accessToken,
    this.refreshToken,
    this.emailVerified = false,
    this.mfaRequired = false,
    this.aalLevel = 'aal1',
    this.error,
    this.authResponse,
    this.profile,
    this.mfaEnrollment,
    this.mfaChallenge,
    this.mfaFactors = const [],
    this.isPasswordResetSent = false,
    this.isPasswordChanged = false,
    this.isEmailChangePending = false,
    this.isDeletingAccount = false,
    this.isLoading = false,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? accessToken;
  final String? refreshToken;
  final bool emailVerified;
  final bool mfaRequired;
  final String aalLevel;
  final String? error;
  final AuthResponse? authResponse;
  final Profile? profile;
  final MfaEnrollResponse? mfaEnrollment;
  final MfaChallengeResponse? mfaChallenge;
  final List<MfaFactorModel> mfaFactors;
  final bool isPasswordResetSent;
  final bool isPasswordChanged;
  final bool isEmailChangePending;
  final bool isDeletingAccount;
  final bool isLoading;

  factory AuthState.initial() => const AuthState();

  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);

  Map<String, dynamic> toJson() => _$AuthStateToJson(this);

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    bool? emailVerified,
    bool? mfaRequired,
    String? aalLevel,
    String? error,
    AuthResponse? authResponse,
    Profile? profile,
    MfaEnrollResponse? mfaEnrollment,
    MfaChallengeResponse? mfaChallenge,
    List<MfaFactorModel>? mfaFactors,
    bool? isPasswordResetSent,
    bool? isPasswordChanged,
    bool? isEmailChangePending,
    bool? isDeletingAccount,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      emailVerified: emailVerified ?? this.emailVerified,
      mfaRequired: mfaRequired ?? this.mfaRequired,
      aalLevel: aalLevel ?? this.aalLevel,
      error: error ?? this.error,
      authResponse: authResponse ?? this.authResponse,
      profile: profile ?? this.profile,
      mfaEnrollment: mfaEnrollment ?? this.mfaEnrollment,
      mfaChallenge: mfaChallenge ?? this.mfaChallenge,
      mfaFactors: mfaFactors ?? this.mfaFactors,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      isPasswordChanged: isPasswordChanged ?? this.isPasswordChanged,
      isEmailChangePending: isEmailChangePending ?? this.isEmailChangePending,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.userId == userId &&
        other.email == email &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.emailVerified == emailVerified &&
        other.mfaRequired == mfaRequired &&
        other.aalLevel == aalLevel &&
        other.error == error &&
        other.authResponse == authResponse &&
        other.profile == profile &&
        other.mfaEnrollment == mfaEnrollment &&
        other.mfaChallenge == mfaChallenge &&
        other.mfaFactors == mfaFactors &&
        other.isPasswordResetSent == isPasswordResetSent &&
        other.isPasswordChanged == isPasswordChanged &&
        other.isEmailChangePending == isEmailChangePending &&
        other.isDeletingAccount == isDeletingAccount &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      userId,
      email,
      accessToken,
      refreshToken,
      emailVerified,
      mfaRequired,
      aalLevel,
      error,
      authResponse,
      profile,
      mfaEnrollment,
      mfaChallenge,
      mfaFactors,
      isPasswordResetSent,
      isPasswordChanged,
      isEmailChangePending,
      isDeletingAccount,
      isLoading,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, userId: $userId, email: $email, accessToken: $accessToken, refreshToken: $refreshToken, emailVerified: $emailVerified, mfaRequired: $mfaRequired, aalLevel: $aalLevel, error: $error, authResponse: $authResponse, profile: $profile, mfaEnrollment: $mfaEnrollment, mfaChallenge: $mfaChallenge, mfaFactors: $mfaFactors, isPasswordResetSent: $isPasswordResetSent, isPasswordChanged: $isPasswordChanged, isEmailChangePending: $isEmailChangePending, isDeletingAccount: $isDeletingAccount, isLoading: $isLoading)';
  }
}