/// Update Profile Use Case
/// Updates user profile information

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/profile_repository.dart';
import '\.\./\.\./\.\./data/models/profile_models.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, Profile>> call({
    String? displayName,
    String? username,
    String? inGameName,
    String? inGameUid,
    String? privacyProfileVisibility,
    bool? privacyShowInGameInfo,
    Map<String, dynamic>? notificationPrefs,
    String? avatarUrl,
  }) async {
    // Apply updates sequentially
    Profile? currentProfile;

    if (displayName != null) {
      final result = await _repository.updateDisplayName(displayName: displayName);
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    if (username != null) {
      final result = await _repository.updateUsername(username: username);
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    if (inGameName != null || inGameUid != null) {
      final result = await _repository.updateInGameInfo(
        inGameName: inGameName,
        inGameUid: inGameUid,
      );
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    if (privacyProfileVisibility != null || privacyShowInGameInfo != null) {
      final visibility = privacyProfileVisibility ?? 'public';
      const showInGameInfo = false;
      final result = await _repository.updatePrivacySettings(
        profileVisibility: visibility,
        showInGameInfo: showInGameInfo,
      );
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    if (notificationPrefs != null) {
      final result =
          await _repository.updateNotificationPreferences(prefs: notificationPrefs);
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    if (avatarUrl != null) {
      final result = await _repository.updateAvatar(avatarUrl: avatarUrl);
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    // If no updates were made, fetch current profile
    if (currentProfile == null) {
      final result = await _repository.getProfile();
      if (result.isLeft()) return result;
      currentProfile = result.getOrElse(() => throw StateError('Should not happen'));
    }

    return Right(currentProfile);
  }
}

