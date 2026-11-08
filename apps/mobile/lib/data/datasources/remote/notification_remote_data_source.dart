/// Remote data source for Phase 5 notifications.
///
/// All business rules (preferences, dedupe, read state, device tokens) live
/// in PostgreSQL SECURITY DEFINER functions; this data source only calls them.

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../models/notification_models.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<Failure, List<NotificationItem>>> getNotifications();

  Future<Either<Failure, bool>> markNotificationRead(String notificationId);

  Future<Either<Failure, int>> markAllNotificationsRead();

  Future<Either<Failure, List<NotificationPreference>>>
      getNotificationPreferences();

  Future<Either<Failure, void>> setNotificationPreference({
    required String category,
    required bool inApp,
    required bool push,
    required bool? email,
  });

  Future<Either<Failure, String>> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceName,
  });

  Future<Either<Failure, bool>> removeDeviceToken(String token);

  Future<Either<Failure, List<DeviceTokenInfo>>> getDeviceTokens();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient _client;

  NotificationRemoteDataSourceImpl(this._client);

  Failure _failure(Object error) => ServerFailure(
        message: humanizeError(error),
        originalError: error,
    );

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications() async {
    try {
      final response = await _client
          .from('notifications')
          .select(
            'id, type, title, body, category, read_at, created_at, data',
          )
          .eq('in_app_visible', true)
          .order('created_at', ascending: false)
          .limit(100);

      final rows = response as List;
      return Right(
        rows.cast<Map<String, dynamic>>().map(NotificationItem.fromMap).toList(),
    );
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, bool>> markNotificationRead(
    String notificationId,
  ) async {
    try {
      final response = await _client.rpc(
        'mark_notification_read',
        params: {'p_notification_id': notificationId},
      );
      return Right(response as bool);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, int>> markAllNotificationsRead() async {
    try {
      final response = await _client.rpc('mark_all_notifications_read');
      return Right(response as int);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, List<NotificationPreference>>>
      getNotificationPreferences() async {
    try {
      final response = await _client
          .from('notification_preferences')
          .select('category, in_app, push, email');

      final rows = response as List;
      return Right(
        rows
            .cast<Map<String, dynamic>>()
            .map(NotificationPreference.fromMap)
            .toList(),
      );
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationPreference({
    required String category,
    required bool inApp,
    required bool push,
    required bool? email,
  }) async {
    try {
      await _client.rpc('set_notification_preference', params: {
        'p_category': category,
        'p_in_app': inApp,
        'p_push': push,
        'p_email': email,
      });
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceName,
  }) async {
    try {
      final response = await _client.rpc(
        'register_device_token',
        params: {
          'p_token': token,
          'p_platform': platform,
          'p_device_name': deviceName,
        },
      );
      return Right(response as String);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, bool>> removeDeviceToken(String token) async {
    try {
      final response = await _client.rpc(
        'remove_device_token',
        params: {'p_token': token},
      );
      return Right(response as bool);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, List<DeviceTokenInfo>>> getDeviceTokens() async {
    try {
      final response = await _client
          .from('device_tokens')
          .select('token, platform, device_name, created_at, revoked_at')
          .order('created_at', ascending: false);

      final rows = response as List;
      return Right(
        rows.cast<Map<String, dynamic>>().map(DeviceTokenInfo.fromMap).toList(),
      );
    } catch (error) {
      return Left(_failure(error));
    }
  }
}
