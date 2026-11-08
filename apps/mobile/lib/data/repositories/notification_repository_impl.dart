/// Phase 5 notification repository implementation.
///
/// Delegates to the remote data source which calls PostgreSQL SECURITY DEFINER
/// RPCs. All authorization is enforced server-side.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../datasources/remote/notification_remote_data_source.dart';
import '../models/notification_models.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications() =>
      _remoteDataSource.getNotifications();

  @override
  Future<Either<Failure, bool>> markNotificationRead(String notificationId) =>
      _remoteDataSource.markNotificationRead(notificationId);

  @override
  Future<Either<Failure, int>> markAllNotificationsRead() =>
      _remoteDataSource.markAllNotificationsRead();

  @override
  Future<Either<Failure, List<NotificationPreference>>>
      getNotificationPreferences() =>
      _remoteDataSource.getNotificationPreferences();

  @override
  Future<Either<Failure, void>> setNotificationPreference({
    required String category,
    required bool inApp,
    required bool push,
    required bool? email,
  }) =>
      _remoteDataSource.setNotificationPreference(
        category: category,
        inApp: inApp,
        push: push,
        email: email,
      );

  @override
  Future<Either<Failure, String>> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceName,
  }) =>
      _remoteDataSource.registerDeviceToken(
        token: token,
        platform: platform,
        deviceName: deviceName,
      );

  @override
  Future<Either<Failure, bool>> removeDeviceToken(String token) =>
      _remoteDataSource.removeDeviceToken(token);

  @override
  Future<Either<Failure, List<DeviceTokenInfo>>> getDeviceTokens() =>
      _remoteDataSource.getDeviceTokens();
}
