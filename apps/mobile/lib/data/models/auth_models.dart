/// Authentication data models
/// JSON serializable models for API requests/responses

import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class SignUpRequest {
  const SignUpRequest({
    required this.email,
    required this.password,
    required this.displayName,
    required this.termsAccepted,
    required this.ageAttestation,
  });

  final String email;
  final String password;
  final String displayName;
  final bool termsAccepted;
  final bool ageAttestation;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}

@JsonSerializable()
class SignInRequest {
  const SignInRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignInRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  const ResetPasswordRequest({required this.email});

  final String email;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class UpdatePasswordRequest {
  const UpdatePasswordRequest({required this.password});

  final String password;

  factory UpdatePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePasswordRequestToJson(this);
}

@JsonSerializable()
class UpdateEmailRequest {
  const UpdateEmailRequest({required this.email});

  final String email;

  factory UpdateEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEmailRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  const AuthResponse({
    required this.userId,
    this.email,
    this.accessToken,
    this.refreshToken,
    this.emailVerified,
    this.message,
  });

  final String userId;
  final String? email;
  final String? accessToken;
  final String? refreshToken;
  final bool? emailVerified;
  final String? message;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.inGameName,
    this.inGameUid,
    this.privacyProfileVisibility,
    this.privacyShowInGameInfo,
    this.notificationPrefs,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? inGameName;
  final String? inGameUid;
  final String? privacyProfileVisibility;
  final bool? privacyShowInGameInfo;
  final Map<String, dynamic>? notificationPrefs;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}

@JsonSerializable()
class MfaEnrollResponse {
  const MfaEnrollResponse({
    required this.factorId,
    required this.qrCode,
    required this.secret,
    required this.uri,
  });

  final String factorId;
  final String qrCode;
  final String secret;
  final String uri;

  factory MfaEnrollResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaEnrollResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrollResponseToJson(this);
}

@JsonSerializable()
class MfaChallengeResponse {
  const MfaChallengeResponse({
    required this.factorId,
    required this.challengeId,
  });

  final String factorId;
  final String challengeId;

  factory MfaChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaChallengeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MfaChallengeResponseToJson(this);
}

@JsonSerializable()
class MfaVerifyResponse {
  const MfaVerifyResponse({
    required this.verified,
    this.accessToken,
    this.refreshToken,
  });

  final bool verified;
  final String? accessToken;
  final String? refreshToken;

  factory MfaVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaVerifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MfaVerifyResponseToJson(this);
}

@JsonSerializable()
class SessionState {
  const SessionState({
    this.userId,
    this.email,
    this.accessToken,
    this.refreshToken,
    this.emailVerified,
    this.aalLevel,
    this.factors,
  });

  final String? userId;
  final String? email;
  final String? accessToken;
  final String? refreshToken;
  final bool? emailVerified;
  final String? aalLevel;
  final List<String>? factors;

  factory SessionState.fromJson(Map<String, dynamic> json) =>
      _$SessionStateFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStateToJson(this);
}

@JsonSerializable()
class MfaFactorModel {
  const MfaFactorModel({
    required this.id,
    required this.factorType,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String factorType;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  factory MfaFactorModel.fromJson(Map<String, dynamic> json) =>
      _$MfaFactorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaFactorModelToJson(this);
}

@JsonSerializable()
class AccountDeletionRequest {
  const AccountDeletionRequest({required this.password});

  final String password;

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AccountDeletionRequestToJson(this);
}