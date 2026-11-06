/// Repository implementation for profile management

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/remote/profile_remote_data_source.dart';
import '../../data/models/profile_models.dart';
import '../../domain/repositories/profile_repository.dart';

@injectable
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<Either<Failure, Profile>> updateDisplayName({
    required String displayName,
  }) async {
    final validationError = Validators.validateDisplayName(displayName);
    if (validationError != null) {
      return Left(ValidationFailure(
        message: validationError,
        code: 'INVALID_DISPLAY_NAME',
      ));
    }

    return _remoteDataSource.updateDisplayName(displayName: displayName);
  }

  @override
  Future<Either<Failure, Profile>> updateUsername({
    required String username,
  }) async {
    if (username.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Username cannot be empty',
        code: 'EMPTY_USERNAME',
      ));
    }
    if (username.trim().length < 3) {
      return Left(ValidationFailure(
        message: 'Username must be at least 3 characters',
        code: 'USERNAME_TOO_SHORT',
      ));
    }
    if (username.trim().length > 30) {
      return Left(ValidationFailure(
        message: 'Username must be at most 30 characters',
        code: 'USERNAME_TOO_LONG',
      ));
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username.trim())) {
      return Left(ValidationFailure(
        message: 'Username can only contain letters, numbers, and underscores',
        code: 'INVALID_USERNAME_FORMAT',
      ));
    }

    return _remoteDataSource.updateUsername(username: username);
  }

  @override
  Future<Either<Failure, Profile>> updateInGameInfo({
    String? inGameName,
    String? inGameUid,
  }) async {
    if (inGameName != null) {
      final validationError = Validators.validateInGameName(inGameName);
      if (validationError != null) {
        return Left(ValidationFailure(
          message: validationError,
          code: 'INVALID_IN_GAME_NAME',
        ));
      }
    }

    if (inGameUid != null) {
      final validationError = Validators.validateInGameUid(inGameUid);
      if (validationError != null) {
        return Left(ValidationFailure(
          message: validationError,
          code: 'INVALID_IN_GAME_UID',
        ));
      }
    }

    return _remoteDataSource.updateInGameInfo(
      inGameName: inGameName,
      inGameUid: inGameUid,
    );
  }

  @override
  Future<Either<Failure, Profile>> updatePrivacySettings({
    required String profileVisibility,
    required bool showInGameInfo,
  }) async {
    const validVisibilities = ['public', 'organizers_only', 'private'];
    if (!validVisibilities.contains(profileVisibility)) {
      return Left(ValidationFailure(
        message: 'Invalid profile visibility',
        code: 'INVALID_VISIBILITY',
      ));
    }

    return _remoteDataSource.updatePrivacySettings(
      profileVisibility: profileVisibility,
      showInGameInfo: showInGameInfo,
    );
  }

  @override
  Future<Either<Failure, Profile>> updateNotificationPreferences({
    required Map<String, dynamic> prefs,
  }) async {
    return _remoteDataSource.updateNotificationPreferences(prefs: prefs);
  }

  @override
  Future<Either<Failure, Profile>> updateAvatar({
    required String avatarUrl,
  }) async {
    return _remoteDataSource.updateAvatar(avatarUrl: avatarUrl);
  }
}