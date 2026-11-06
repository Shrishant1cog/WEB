/// Authentication data models
/// Freezed models for API requests/responses

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
}

@freezed
class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    required String email,
    required String password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}

@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({required String email}) =
      _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

@freezed
class UpdatePasswordRequest with _$UpdatePasswordRequest {
  const factory UpdatePasswordRequest({required String password}) =
      _UpdatePasswordRequest;

  factory UpdatePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordRequestFromJson(json);
}

@freezed
class UpdateEmailRequest with _$UpdateEmailRequest {
  const factory UpdateEmailRequest({required String email}) =
      _UpdateEmailRequest;

  factory UpdateEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmailRequestFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    bool? emailVerified,
    String? message,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    required String displayName,
    String? avatarUrl,
    String? inGameName,
    String? inGameUid,
    String? privacyProfileVisibility,
    bool? privacyShowInGameInfo,
    Map<String, dynamic>? notificationPrefs,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

@freezed
class MfaEnrollResponse with _$MfaEnrollResponse {
  const factory MfaEnrollResponse({
    required String factorId,
    required String qrCode,
    required String secret,
    required String uri,
  }) = _MfaEnrollResponse;

  factory MfaEnrollResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaEnrollResponseFromJson(json);
}

@freezed
class MfaChallengeResponse with _$MfaChallengeResponse {
  const factory MfaChallengeResponse({
    required String factorId,
    required String challengeId,
  }) = _MfaChallengeResponse;

  factory MfaChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaChallengeResponseFromJson(json);
}

@freezed
class MfaVerifyResponse with _$MfaVerifyResponse {
  const factory MfaVerifyResponse({
    required bool verified,
    String? accessToken,
    String? refreshToken,
  }) = _MfaVerifyResponse;

  factory MfaVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$MfaVerifyResponseFromJson(json);
}

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    String? userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    bool? emailVerified,
    String? aalLevel,
    List<String>? factors,
  }) = _SessionState;

  factory SessionState.fromJson(Map<String, dynamic> json) =>
      _$SessionStateFromJson(json);
}

@freezed
class MfaFactorModel with _$MfaFactorModel {
  const factory MfaFactorModel({
    required String id,
    required String factorType,
    required String status,
    String? createdAt,
    String? updatedAt,
  }) = _MfaFactorModel;

  factory MfaFactorModel.fromJson(Map<String, dynamic> json) =>
      _$MfaFactorModelFromJson(json);
}

@freezed
class AccountDeletionRequest with _$AccountDeletionRequest {
  const factory AccountDeletionRequest({required String password}) =
      _AccountDeletionRequest;

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionRequestFromJson(json);
}