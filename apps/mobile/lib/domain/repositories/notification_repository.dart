/// Phase 5 notification repository interface.
///
/// Defines the contract for notification persistence, preferences, and
/// device token management. Implementations may use Supabase RPCs or a
/// local cache.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/notification_models.dart';

abstract class NotificationRepository {
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
