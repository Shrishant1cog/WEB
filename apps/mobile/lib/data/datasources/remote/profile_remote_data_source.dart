/// Remote data source for profile operations

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/profile_repository.dart'
    hide Profile;
import '../../../data/models/profile_models.dart';
import '../../../core/errors/failures.dart';

@injectable
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Right(Profile(
        id: response['id'],
        displayName: response['display_name'] ?? '',
        username: response['username'],
        avatarUrl: response['avatar_url'],
        inGameName: response['in_game_name'],
        inGameUid: response['in_game_uid'],
        privacyProfileVisibility:
            response['privacy_profile_visibility'] ?? 'public',
        privacyShowInGameInfo: response['privacy_show_in_game_info'] ?? false,
        notificationPrefs:
            response['notification_prefs'] as Map<String, dynamic>? ?? {},
        createdAt: response['created_at'],
        updatedAt: response['updated_at'],
        deletedAt: response['deleted_at'],
      ));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Left(NotFoundFailure(
          message: 'Profile not found',
          code: 'PROFILE_NOT_FOUND',
          originalError: e,
        ));
      }
      return Left(ServerFailure(
        message: 'Failed to get profile: ${e.message}',
        code: 'GET_PROFILE_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to get profile: ${e.toString()}',
        code: 'GET_PROFILE_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateDisplayName({
    required String displayName,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      await _client
          .from('profiles')
          .update({'display_name': displayName.trim()})
          .eq('id', user.id);

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update display name: ${e.message}',
        code: 'UPDATE_DISPLAY_NAME_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update display name: ${e.toString()}',
        code: 'UPDATE_DISPLAY_NAME_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateUsername({
    required String username,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      // Check uniqueness
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('username', username.trim().toLowerCase())
          .neq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        return Left(ValidationFailure(
          message: 'Username is already taken',
          code: 'USERNAME_TAKEN',
        ));
      }

      await _client
          .from('profiles')
          .update({'username': username.trim().toLowerCase()})
          .eq('id', user.id);

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update username: ${e.message}',
        code: 'UPDATE_USERNAME_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update username: ${e.toString()}',
        code: 'UPDATE_USERNAME_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateInGameInfo({
    String? inGameName,
    String? inGameUid,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      final updates = <String, dynamic>{};
      if (inGameName != null) updates['in_game_name'] = inGameName.trim();
      if (inGameUid != null) updates['in_game_uid'] = inGameUid.trim();

      if (updates.isNotEmpty) {
        await _client
            .from('profiles')
            .update(updates)
            .eq('id', user.id);
      }

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update in-game info: ${e.message}',
        code: 'UPDATE_IN_GAME_INFO_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update in-game info: ${e.toString()}',
        code: 'UPDATE_IN_GAME_INFO_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updatePrivacySettings({
    required String profileVisibility,
    required bool showInGameInfo,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      await _client
          .from('profiles')
          .update({
            'privacy_profile_visibility': profileVisibility,
            'privacy_show_in_game_info': showInGameInfo,
          })
          .eq('id', user.id);

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update privacy settings: ${e.message}',
        code: 'UPDATE_PRIVACY_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update privacy settings: ${e.toString()}',
        code: 'UPDATE_PRIVACY_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateNotificationPreferences({
    required Map<String, dynamic> prefs,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      await _client
          .from('profiles')
          .update({'notification_prefs': prefs})
          .eq('id', user.id);

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update notification preferences: ${e.message}',
        code: 'UPDATE_NOTIF_PREFS_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update notification preferences: ${e.toString()}',
        code: 'UPDATE_NOTIF_PREFS_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateAvatar({
    required String avatarUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      await _client
          .from('profiles')
          .update({'avatar_url': avatarUrl})
          .eq('id', user.id);

      return getProfile();
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update avatar: ${e.message}',
        code: 'UPDATE_AVATAR_ERROR',
        originalError: e,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update avatar: ${e.toString()}',
        code: 'UPDATE_AVATAR_ERROR',
        originalError: e,
      ));
    }
  }
}

abstract class ProfileRemoteDataSource {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateDisplayName({
    required String displayName,
  });
  Future<Either<Failure, Profile>> updateUsername({
    required String username,
  });
  Future<Either<Failure, Profile>> updateInGameInfo({
    String? inGameName,
    String? inGameUid,
  });
  Future<Either<Failure, Profile>> updatePrivacySettings({
    required String profileVisibility,
    required bool showInGameInfo,
  });
  Future<Either<Failure, Profile>> updateNotificationPreferences({
    required Map<String, dynamic> prefs,
  });
  Future<Either<Failure, Profile>> updateAvatar({
    required String avatarUrl,
  });
}