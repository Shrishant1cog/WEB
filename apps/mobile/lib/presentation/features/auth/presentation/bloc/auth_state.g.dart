// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthState _$AuthStateFromJson(Map<String, dynamic> json) => AuthState(
  status:
      $enumDecodeNullable(_$AuthStatusEnumMap, json['status']) ??
      AuthStatus.initial,
  userId: json['userId'] as String?,
  email: json['email'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  mfaRequired: json['mfaRequired'] as bool? ?? false,
  aalLevel: json['aalLevel'] as String? ?? 'aal1',
  error: json['error'] as String?,
  authResponse: json['authResponse'] == null
      ? null
      : AuthResponse.fromJson(json['authResponse'] as Map<String, dynamic>),
  profile: json['profile'] == null
      ? null
      : Profile.fromJson(json['profile'] as Map<String, dynamic>),
  mfaEnrollment: json['mfaEnrollment'] == null
      ? null
      : MfaEnrollResponse.fromJson(
          json['mfaEnrollment'] as Map<String, dynamic>,
        ),
  mfaChallenge: json['mfaChallenge'] == null
      ? null
      : MfaChallengeResponse.fromJson(
          json['mfaChallenge'] as Map<String, dynamic>,
        ),
  mfaFactors:
      (json['mfaFactors'] as List<dynamic>?)
          ?.map((e) => MfaFactorModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isPasswordResetSent: json['isPasswordResetSent'] as bool? ?? false,
  isPasswordChanged: json['isPasswordChanged'] as bool? ?? false,
  isEmailChangePending: json['isEmailChangePending'] as bool? ?? false,
  isDeletingAccount: json['isDeletingAccount'] as bool? ?? false,
  isLoading: json['isLoading'] as bool? ?? false,
);

Map<String, dynamic> _$AuthStateToJson(AuthState instance) => <String, dynamic>{
  'status': _$AuthStatusEnumMap[instance.status]!,
  'userId': instance.userId,
  'email': instance.email,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'emailVerified': instance.emailVerified,
  'mfaRequired': instance.mfaRequired,
  'aalLevel': instance.aalLevel,
  'error': instance.error,
  'authResponse': instance.authResponse,
  'profile': instance.profile,
  'mfaEnrollment': instance.mfaEnrollment,
  'mfaChallenge': instance.mfaChallenge,
  'mfaFactors': instance.mfaFactors,
  'isPasswordResetSent': instance.isPasswordResetSent,
  'isPasswordChanged': instance.isPasswordChanged,
  'isEmailChangePending': instance.isEmailChangePending,
  'isDeletingAccount': instance.isDeletingAccount,
  'isLoading': instance.isLoading,
};

const _$AuthStatusEnumMap = {
  AuthStatus.initial: 'initial',
  AuthStatus.unauthenticated: 'unauthenticated',
  AuthStatus.loading: 'loading',
  AuthStatus.authenticated: 'authenticated',
  AuthStatus.verificationPending: 'verificationPending',
  AuthStatus.mfaRequired: 'mfaRequired',
  AuthStatus.mfaEnrollment: 'mfaEnrollment',
  AuthStatus.mfaChallenge: 'mfaChallenge',
  AuthStatus.failure: 'failure',
};
