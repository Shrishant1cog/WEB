// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  username: json['username'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  inGameName: json['inGameName'] as String?,
  inGameUid: json['inGameUid'] as String?,
  privacyProfileVisibility:
      json['privacyProfileVisibility'] as String? ?? 'public',
  privacyShowInGameInfo: json['privacyShowInGameInfo'] as bool? ?? false,
  notificationPrefs:
      json['notificationPrefs'] as Map<String, dynamic>? ?? const {},
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  deletedAt: json['deletedAt'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'username': instance.username,
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

_UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProfileRequest(
  displayName: json['displayName'] as String?,
  username: json['username'] as String?,
  inGameName: json['inGameName'] as String?,
  inGameUid: json['inGameUid'] as String?,
  privacyProfileVisibility: json['privacyProfileVisibility'] as String?,
  privacyShowInGameInfo: json['privacyShowInGameInfo'] as bool?,
  notificationPrefs: json['notificationPrefs'] as Map<String, dynamic>?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  _UpdateProfileRequest instance,
) => <String, dynamic>{
  'displayName': instance.displayName,
  'username': instance.username,
  'inGameName': instance.inGameName,
  'inGameUid': instance.inGameUid,
  'privacyProfileVisibility': instance.privacyProfileVisibility,
  'privacyShowInGameInfo': instance.privacyShowInGameInfo,
  'notificationPrefs': instance.notificationPrefs,
  'avatarUrl': instance.avatarUrl,
};
