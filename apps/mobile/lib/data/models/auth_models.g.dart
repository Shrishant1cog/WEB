// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    SignUpRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      displayName: json['displayName'] as String,
      termsAccepted: json['termsAccepted'] as bool,
      ageAttestation: json['ageAttestation'] as bool,
    );

Map<String, dynamic> _$SignUpRequestToJson(SignUpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'displayName': instance.displayName,
      'termsAccepted': instance.termsAccepted,
      'ageAttestation': instance.ageAttestation,
    };

SignInRequest _$SignInRequestFromJson(Map<String, dynamic> json) =>
    SignInRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignInRequestToJson(SignInRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

UpdatePasswordRequest _$UpdatePasswordRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePasswordRequest(password: json['password'] as String);

Map<String, dynamic> _$UpdatePasswordRequestToJson(
  UpdatePasswordRequest instance,
) => <String, dynamic>{'password': instance.password};

UpdateEmailRequest _$UpdateEmailRequestFromJson(Map<String, dynamic> json) =>
    UpdateEmailRequest(email: json['email'] as String);

Map<String, dynamic> _$UpdateEmailRequestToJson(UpdateEmailRequest instance) =>
    <String, dynamic>{'email': instance.email};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  userId: json['userId'] as String,
  email: json['email'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  emailVerified: json['emailVerified'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'emailVerified': instance.emailVerified,
      'message': instance.message,
    };

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
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

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
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

MfaEnrollResponse _$MfaEnrollResponseFromJson(Map<String, dynamic> json) =>
    MfaEnrollResponse(
      factorId: json['factorId'] as String,
      qrCode: json['qrCode'] as String,
      secret: json['secret'] as String,
      uri: json['uri'] as String,
    );

Map<String, dynamic> _$MfaEnrollResponseToJson(MfaEnrollResponse instance) =>
    <String, dynamic>{
      'factorId': instance.factorId,
      'qrCode': instance.qrCode,
      'secret': instance.secret,
      'uri': instance.uri,
    };

MfaChallengeResponse _$MfaChallengeResponseFromJson(
  Map<String, dynamic> json,
) => MfaChallengeResponse(
  factorId: json['factorId'] as String,
  challengeId: json['challengeId'] as String,
);

Map<String, dynamic> _$MfaChallengeResponseToJson(
  MfaChallengeResponse instance,
) => <String, dynamic>{
  'factorId': instance.factorId,
  'challengeId': instance.challengeId,
};

MfaVerifyResponse _$MfaVerifyResponseFromJson(Map<String, dynamic> json) =>
    MfaVerifyResponse(
      verified: json['verified'] as bool,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$MfaVerifyResponseToJson(MfaVerifyResponse instance) =>
    <String, dynamic>{
      'verified': instance.verified,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

SessionState _$SessionStateFromJson(Map<String, dynamic> json) => SessionState(
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

Map<String, dynamic> _$SessionStateToJson(SessionState instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'emailVerified': instance.emailVerified,
      'aalLevel': instance.aalLevel,
      'factors': instance.factors,
    };

MfaFactorModel _$MfaFactorModelFromJson(Map<String, dynamic> json) =>
    MfaFactorModel(
      id: json['id'] as String,
      factorType: json['factorType'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$MfaFactorModelToJson(MfaFactorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'factorType': instance.factorType,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

AccountDeletionRequest _$AccountDeletionRequestFromJson(
  Map<String, dynamic> json,
) => AccountDeletionRequest(password: json['password'] as String);

Map<String, dynamic> _$AccountDeletionRequestToJson(
  AccountDeletionRequest instance,
) => <String, dynamic>{'password': instance.password};
