/// Supabase client initialization and configuration for Flutter.
/// Provides a singleton instance with proper configuration.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseClientManager {
  SupabaseClientManager._();

  static SupabaseClient? _client;
  static bool _initialized = false;

  /// Initialize Supabase client (call once at app startup)
  static Future<void> initialize() async {
    if (_initialized) return;

    AppConfig.validate();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      // Optional: configure auth options
      authOptions: const AuthClientOptions(
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false, // We handle deep links manually
      ),
      // Optional: configure realtime
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      // Optional: configure storage
      storageClientOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  /// Get the initialized Supabase client
  static SupabaseClient get client {
    if (!_initialized || _client == null) {
      throw StateError('SupabaseClientManager not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Check if initialized
  static bool get isInitialized => _initialized && _client != null;

  /// Get current authenticated user (if any)
  static User? get currentUser => _client?.auth.currentUser;

  /// Get current session (if any)
  static Session? get currentSession => _client?.auth.currentSession;

  /// Auth state stream
  static Stream<AuthState> get authStateChanges => _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Dispose (for testing)
  static void dispose() {
    _client = null;
    _initialized = false;
  }
}