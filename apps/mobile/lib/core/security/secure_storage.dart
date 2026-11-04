/// Secure storage wrapper using flutter_secure_storage.
/// Uses Android Keystore / iOS Keychain for hardware-backed encryption.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@singleton
class SecureStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastAuthMethodKey = 'last_auth_method';

  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  /// Android options with hardware-backed keystore
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm: 'AES/GCM/NoPadding',
    sharedPreferencesName: 'fft_secure_prefs',
    keyAlias: 'fft_key',
  );

  /// iOS options with Keychain
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  /// Create instance with platform-specific options
  factory SecureStorage.create() {
    return SecureStorage(
      const FlutterSecureStorage(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
        wOptions: WindowsOptions(),
        lOptions: LinuxOptions(),
        mOptions: MacOsOptions(),
      ),
    );
  }

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Biometric Settings
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // Auth Method Tracking
  Future<void> setLastAuthMethod(String method) async {
    await _storage.write(key: _lastAuthMethodKey, value: method);
  }

  Future<String?> getLastAuthMethod() async {
    return _storage.read(key: _lastAuthMethodKey);
  }

  // Generic Key-Value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }
}