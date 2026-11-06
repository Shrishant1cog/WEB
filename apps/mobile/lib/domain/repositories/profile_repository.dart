/// Domain repository interface for profile management

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/profile_models.dart';

abstract class ProfileRepository {
  /// Get current user's profile
  Future<Either<Failure, Profile>> getProfile();

  /// Update user's display name
  Future<Either<Failure, Profile>> updateDisplayName({
    required String displayName,
  });

  /// Update user's username
  Future<Either<Failure, Profile>> updateUsername({
    required String username,
  });

  /// Update user's in-game info
  Future<Either<Failure, Profile>> updateInGameInfo({
    String? inGameName,
    String? inGameUid,
  });

  /// Update privacy settings
  Future<Either<Failure, Profile>> updatePrivacySettings({
    required String profileVisibility,
    required bool showInGameInfo,
  });

  /// Update notification preferences
  Future<Either<Failure, Profile>> updateNotificationPreferences({
    required Map<String, dynamic> prefs,
  });

  /// Update avatar
  Future<Either<Failure, Profile>> updateAvatar({
    required String avatarUrl,
  });
}