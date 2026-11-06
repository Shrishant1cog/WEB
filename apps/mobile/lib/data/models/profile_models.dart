/// Profile data models

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String displayName,
    String? username,
    String? avatarUrl,
    String? inGameName,
    String? inGameUid,
    @Default('public') String privacyProfileVisibility,
    @Default(false) bool privacyShowInGameInfo,
    @Default({}) Map<String, dynamic> notificationPrefs,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? displayName,
    String? username,
    String? inGameName,
    String? inGameUid,
    String? privacyProfileVisibility,
    bool? privacyShowInGameInfo,
    Map<String, dynamic>? notificationPrefs,
    String? avatarUrl,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}