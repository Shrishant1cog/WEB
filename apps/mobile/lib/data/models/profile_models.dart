/// Profile data models

import 'package:json_annotation/json_annotation.dart';

part 'profile_models.g.dart';

@JsonSerializable()
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.inGameName,
    this.inGameUid,
    this.privacyProfileVisibility = 'public',
    this.privacyShowInGameInfo = false,
    this.notificationPrefs = const {},
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String? inGameName;
  final String? inGameUid;
  final String privacyProfileVisibility;
  final bool privacyShowInGameInfo;
  final Map<String, dynamic> notificationPrefs;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.displayName,
    this.username,
    this.inGameName,
    this.inGameUid,
    this.privacyProfileVisibility,
    this.privacyShowInGameInfo,
    this.notificationPrefs,
    this.avatarUrl,
  });

  final String? displayName;
  final String? username;
  final String? inGameName;
  final String? inGameUid;
  final String? privacyProfileVisibility;
  final bool? privacyShowInGameInfo;
  final Map<String, dynamic>? notificationPrefs;
  final String? avatarUrl;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}