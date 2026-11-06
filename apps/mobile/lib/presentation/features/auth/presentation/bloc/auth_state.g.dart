// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthState _$AuthStateFromJson(Map<String, dynamic> json) => _AuthState(
  status: json['status'] == null
      ? const AuthStatus.initial()
      : const AuthStatusConverter().fromJson(json['status'] as String),
  userId: json['userId'] as String?,
  email: json['email'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  mfaRequired: json['mfaRequired'] as bool? ?? false,
  aalLevel: json['aalLevel'] as String? ?? 'aal1',
  error: json['error'] as String?,
  authResponse: const AuthResponseConverter().fromJson(
    json['authResponse'] as Map<String, dynamic>?,
  ),
  profile: const ProfileConverter().fromJson(
    json['profile'] as Map<String, dynamic>?,
  ),
  mfaEnrollment: const MfaEnrollResponseConverter().fromJson(
    json['mfaEnrollment'] as Map<String, dynamic>?,
  ),
  mfaChallenge: const MfaChallengeResponseConverter().fromJson(
    json['mfaChallenge'] as Map<String, dynamic>?,
  ),
  mfaFactors: json['mfaFactors'] == null
      ? const []
      : const MfaFactorModelConverter().fromJson(json['mfaFactors'] as List),
  isPasswordResetSent: json['isPasswordResetSent'] as bool? ?? false,
  isPasswordChanged: json['isPasswordChanged'] as bool? ?? false,
  isEmailChangePending: json['isEmailChangePending'] as bool? ?? false,
  isDeletingAccount: json['isDeletingAccount'] as bool? ?? false,
  isLoading: json['isLoading'] as bool? ?? false,
);

Map<String, dynamic> _$AuthStateToJson(
  _AuthState instance,
) => <String, dynamic>{
  'status': const AuthStatusConverter().toJson(instance.status),
  'userId': instance.userId,
  'email': instance.email,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'emailVerified': instance.emailVerified,
  'mfaRequired': instance.mfaRequired,
  'aalLevel': instance.aalLevel,
  'error': instance.error,
  'authResponse': const AuthResponseConverter().toJson(instance.authResponse),
  'profile': const ProfileConverter().toJson(instance.profile),
  'mfaEnrollment': const MfaEnrollResponseConverter().toJson(
    instance.mfaEnrollment,
  ),
  'mfaChallenge': const MfaChallengeResponseConverter().toJson(
    instance.mfaChallenge,
  ),
  'mfaFactors': const MfaFactorModelConverter().toJson(instance.mfaFactors),
  'isPasswordResetSent': instance.isPasswordResetSent,
  'isPasswordChanged': instance.isPasswordChanged,
  'isEmailChangePending': instance.isEmailChangePending,
  'isDeletingAccount': instance.isDeletingAccount,
  'isLoading': instance.isLoading,
};
