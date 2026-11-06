// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    _SignUpRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      displayName: json['displayName'] as String,
      termsAccepted: json['termsAccepted'] as bool,
      ageAttestation: json['ageAttestation'] as bool,
    );

Map<String, dynamic> _$SignUpRequestToJson(_SignUpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'displayName': instance.displayName,
      'termsAccepted': instance.termsAccepted,
      'ageAttestation': instance.ageAttestation,
    };

_SignInRequest _$SignInRequestFromJson(Map<String, dynamic> json) =>
    _SignInRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignInRequestToJson(_SignInRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ResetPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  _ResetPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

_UpdatePasswordRequest _$UpdatePasswordRequestFromJson(
  Map<String, dynamic> json,
) => _UpdatePasswordRequest(password: json['password'] as String);

Map<String, dynamic> _$UpdatePasswordRequestToJson(
  _UpdatePasswordRequest instance,
) => <String, dynamic>{'password': instance.password};

_UpdateEmailRequest _$UpdateEmailRequestFromJson(Map<String, dynamic> json) =>
    _UpdateEmailRequest(email: json['email'] as String);

Map<String, dynamic> _$UpdateEmailRequestToJson(_UpdateEmailRequest instance) =>
    <String, dynamic>{'email': instance.email};

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      userId: json['userId'] as String,
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'emailVerified': instance.emailVerified,
      'message': instance.message,
    };

_UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    _UserProfileModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      inGameName: json['inGameName'] as String?,
      inGameUid: json['inGameUid'] as String?,
      privacyProfileVisibility: json['privacyProfileVisibility'] as String?,
      privacyShowInGameInfo: json['privacyShowInGameInfo'] as bool?,
      notificationPrefs: json['notificationPrefs'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(_UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'inGameName': instance.inGameName,
      'inGameUid': instance.inGameUid,
      'privacyProfileVisibility': instance.privacyProfileVisibility,
      'privacyShowInGameInfo': instance.privacyShowInGameInfo,
      'notificationPrefs': instance.notificationPrefs,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
    };

_MfaEnrollResponse _$MfaEnrollResponseFromJson(Map<String, dynamic> json) =>
    _MfaEnrollResponse(
      factorId: json['factorId'] as String,
      qrCode: json['qrCode'] as String,
      secret: json['secret'] as String,
      uri: json['uri'] as String,
    );

Map<String, dynamic> _$MfaEnrollResponseToJson(_MfaEnrollResponse instance) =>
    <String, dynamic>{
      'factorId': instance.factorId,
      'qrCode': instance.qrCode,
      'secret': instance.secret,
      'uri': instance.uri,
    };

_MfaChallengeResponse _$MfaChallengeResponseFromJson(
  Map<String, dynamic> json,
) => _MfaChallengeResponse(
  factorId: json['factorId'] as String,
  challengeId: json['challengeId'] as String,
);

Map<String, dynamic> _$MfaChallengeResponseToJson(
  _MfaChallengeResponse instance,
) => <String, dynamic>{
  'factorId': instance.factorId,
  'challengeId': instance.challengeId,
};

_MfaVerifyResponse _$MfaVerifyResponseFromJson(Map<String, dynamic> json) =>
    _MfaVerifyResponse(
      verified: json['verified'] as bool,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$MfaVerifyResponseToJson(_MfaVerifyResponse instance) =>
    <String, dynamic>{
      'verified': instance.verified,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

_SessionState _$SessionStateFromJson(Map<String, dynamic> json) =>
    _SessionState(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      aalLevel: json['aalLevel'] as String?,
      factors: (json['factors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SessionStateToJson(_SessionState instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'emailVerified': instance.emailVerified,
      'aalLevel': instance.aalLevel,
      'factors': instance.factors,
    };

_MfaFactorModel _$MfaFactorModelFromJson(Map<String, dynamic> json) =>
    _MfaFactorModel(
      id: json['id'] as String,
      factorType: json['factorType'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$MfaFactorModelToJson(_MfaFactorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'factorType': instance.factorType,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_AccountDeletionRequest _$AccountDeletionRequestFromJson(
  Map<String, dynamic> json,
) => _AccountDeletionRequest(password: json['password'] as String);

Map<String, dynamic> _$AccountDeletionRequestToJson(
  _AccountDeletionRequest instance,
) => <String, dynamic>{'password': instance.password};
