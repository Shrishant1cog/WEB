/// Supabase client initialization and configuration for Flutter.
/// Provides a singleton instance with proper configuration.
/// 
/// Initialization is graceful - if Supabase is not configured, the app
/// can still run in a degraded mode (e.g., showing configuration error screen).

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';
import '../config/app_config.dart';

/// Result of Supabase initialization
sealed class SupabaseInitResult {
  const SupabaseInitResult();
  
  static SupabaseInitResult success() => const _SupabaseInitSuccess();
  static SupabaseInitResult failure(String error) => _SupabaseInitFailure(error);
  
  bool get isSuccess => this is _SupabaseInitSuccess;
  bool get isFailure => this is _SupabaseInitFailure;
  String? get error => switch (this) {
    _SupabaseInitSuccess() => null,
    _SupabaseInitFailure(:final error) => error,
  };
}

class _SupabaseInitSuccess extends SupabaseInitResult {
  const _SupabaseInitSuccess();
}

class _SupabaseInitFailure extends SupabaseInitResult {
  final String error;
  const _SupabaseInitFailure(this.error);
}

class SupabaseClientManager {
  SupabaseClientManager._();

  static SupabaseClient? _client;
  static bool _initialized = false;
  static SupabaseInitResult? _lastInitResult;

  /// Initialize Supabase client (call once at app startup)
  /// Returns a result indicating success or failure with error message.
  /// Does not throw - callers should check the result.
  static Future<SupabaseInitResult> initialize() async {
    if (_initialized) return SupabaseInitResult.success();
    
    // Validate config first
    final configError = AppConfig.validate();
    if (configError != null) {
      _lastInitResult = SupabaseInitResult.failure(configError);
      return _lastInitResult!;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      _client = Supabase.instance.client;
      _initialized = true;
      _lastInitResult = SupabaseInitResult.success();
      return _lastInitResult!;
    } catch (e) {
      _lastInitResult = SupabaseInitResult.failure('Failed to initialize Supabase: $e');
      return _lastInitResult!;
    }
  }

  /// Get the last initialization result
  static SupabaseInitResult? get lastInitResult => _lastInitResult;

  /// Whether Supabase is configured (has valid credentials)
  static bool get isConfigured => AppConfig.hasSupabaseConfig;

  /// Get the initialized Supabase client
  /// Returns null if not initialized (does not throw)
  static SupabaseClient? get client => _client;

  /// Check if initialized and ready to use
  static bool get isInitialized => _initialized && _client != null;

  /// Get current authenticated user (if any and initialized)
  /// Returns null if not initialized or no user
  static User? get currentUser {
    if (!_initialized || _client == null) return null;
    return _client!.auth.currentUser;
  }

  /// Get current session (if any and initialized)
  /// Returns null if not initialized or no session
  static Session? get currentSession {
    if (!_initialized || _client == null) return null;
    return _client!.auth.currentSession;
  }

  /// Auth state stream (empty stream if not initialized)
  static Stream<AuthState> get authStateChanges {
    if (!_initialized || _client == null) return const Stream.empty();
    return _client!.auth.onAuthStateChange;
  }

  /// Sign up with email and password
  /// Throws if not initialized
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    Map<String, dynamic>? data,
  }) async {
    _assertInitialized();
    final response = await _client!.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        ...?data,
      },
    );
    return response;
  }

  /// Sign in with email and password
  /// Throws if not initialized
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _assertInitialized();
    return await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  /// Throws if not initialized
  static Future<void> signOut() async {
    _assertInitialized();
    await _client!.auth.signOut();
  }

  /// Request password reset email
  /// Throws if not initialized
  static Future<void> resetPassword({
    required String email,
  }) async {
    _assertInitialized();
    await _client!.auth.resetPasswordForEmail(email);
  }

  /// Update password (requires authenticated session)
  /// Throws if not initialized
  static Future<UserResponse> updatePassword({
    required String password,
  }) async {
    _assertInitialized();
    return await _client!.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  /// Update email (requires confirmation)
  /// Throws if not initialized
  static Future<UserResponse> updateEmail({
    required String email,
  }) async {
    _assertInitialized();
    return await _client!.auth.updateUser(
      UserAttributes(email: email),
    );
  }

  /// Get current user profile
  /// Throws if not initialized
  static Future<User?> getCurrentUser() async {
    _assertInitialized();
    return _client!.auth.currentUser;
  }

  /// Resend email verification
  /// Throws if not initialized
  static Future<void> resendVerificationEmail({
    required String email,
  }) async {
    _assertInitialized();
    await _client!.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// Enroll TOTP MFA factor
  /// Throws if not initialized
  static Future<AuthMFAEnrollResponse> enrollMfaTotp() async {
    _assertInitialized();
    return await _client!.auth.mfa.enroll(
      factorType: FactorType.totp,
      friendlyName: 'Authenticator App',
    );
  }

  /// Challenge TOTP MFA factor
  /// Throws if not initialized
  static Future<AuthMFAChallengeResponse> challengeMfaTotp({
    required String factorId,
  }) async {
    _assertInitialized();
    return await _client!.auth.mfa.challenge(
      factorId: factorId,
    );
  }

  /// Verify TOTP MFA code
  /// Throws if not initialized
  static Future<AuthMFAVerifyResponse> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    _assertInitialized();
    return await _client!.auth.mfa.verify(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
  }

  /// List enrolled MFA factors
  /// Throws if not initialized
  static Future<List<Factor>> listMfaFactors() async {
    _assertInitialized();
    final response = await _client!.auth.mfa.listFactors();
    return response.all;
  }

  /// Unenroll MFA factor
  /// Throws if not initialized
  static Future<void> unenrollMfaFactor({
    required String factorId,
  }) async {
    _assertInitialized();
    await _client!.auth.mfa.unenroll(factorId);
  }

  /// Assert that Supabase is initialized, throws if not
  static void _assertInitialized() {
    if (!_initialized || _client == null) {
      throw StateError(
        'SupabaseClientManager not initialized. '
        'Call initialize() first and ensure SUPABASE_URL and SUPABASE_ANON_KEY are configured.'
      );
    }
  }

  /// Dispose (for testing)
  static void dispose() {
    _client = null;
    _initialized = false;
    _lastInitResult = null;
  }
}