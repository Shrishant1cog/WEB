/// Phase 5 notification domain models.
///
/// Plain classes so the mobile app stays compatible with the pinned
/// analyzer/Freezed versions.

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String? body;
  final String category;
  final bool read;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.category,
    required this.read,
    this.createdAt,
    required this.data,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString(),
      category: map['category']?.toString() ?? 'system',
      read: map['read_at'] != null,
      createdAt: _date(map['created_at']),
      data: _object(map['data']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return const <String, dynamic>{};
  }
}

class NotificationPreference {
  final String category;
  final bool inApp;
  final bool push;
  final bool email;

  const NotificationPreference({
    required this.category,
    required this.inApp,
    required this.push,
    required this.email,
  });

  factory NotificationPreference.fromMap(Map<String, dynamic> map) {
    return NotificationPreference(
      category: map['category']?.toString() ?? 'system',
      inApp: map['in_app'] == true,
      push: map['push'] == true,
      email: map['email'] == true,
    );
  }
}

class DeviceTokenInfo {
  final String token;
  final String platform;
  final String? deviceName;
  final DateTime? createdAt;
  final DateTime? revokedAt;

  const DeviceTokenInfo({
    required this.token,
    required this.platform,
    this.deviceName,
    this.createdAt,
    this.revokedAt,
  });

  bool get isActive => revokedAt == null;

  factory DeviceTokenInfo.fromMap(Map<String, dynamic> map) {
    return DeviceTokenInfo(
      token: map['token']?.toString() ?? '',
      platform: map['platform']?.toString() ?? 'unknown',
      deviceName: map['device_name']?.toString(),
      createdAt: _date(map['created_at']),
      revokedAt: _date(map['revoked_at']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
