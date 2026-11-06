/// Supabase client initialization and configuration for Flutter.
/// Provides a singleton instance with proper configuration.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';
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
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
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

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    Map<String, dynamic>? data,
  }) async {
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
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client!.auth.signOut();
  }

  /// Request password reset email
  static Future<void> resetPassword({
    required String email,
  }) async {
    await _client!.auth.resetPasswordForEmail(email);
  }

  /// Update password (requires authenticated session)
  static Future<UserResponse> updatePassword({
    required String password,
  }) async {
    return await _client!.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  /// Update email (requires confirmation)
  static Future<UserResponse> updateEmail({
    required String email,
  }) async {
    return await _client!.auth.updateUser(
      UserAttributes(email: email),
    );
  }

  /// Get current user profile
  static Future<User?> getCurrentUser() async {
    return _client!.auth.currentUser;
  }

  /// Resend email verification
  static Future<void> resendVerificationEmail({
    required String email,
  }) async {
    await _client!.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// Enroll TOTP MFA factor
  static Future<AuthMFAEnrollResponse> enrollMfaTotp() async {
    return await _client!.auth.mfa.enroll(
      factorType: FactorType.totp,
      friendlyName: 'Authenticator App',
    );
  }

  /// Challenge TOTP MFA factor
  static Future<AuthMFAChallengeResponse> challengeMfaTotp({
    required String factorId,
  }) async {
    return await _client!.auth.mfa.challenge(
      factorId: factorId,
    );
  }

  /// Verify TOTP MFA code
  static Future<AuthMFAVerifyResponse> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    return await _client!.auth.mfa.verify(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
  }

  /// List enrolled MFA factors
  static Future<List<Factor>> listMfaFactors() async {
    final response = await _client!.auth.mfa.listFactors();
    return response.all;
  }

  /// Unenroll MFA factor
  static Future<void> unenrollMfaFactor({
    required String factorId,
  }) async {
    await _client!.auth.mfa.unenroll(factorId);
  }

  /// Dispose (for testing)
  static void dispose() {
    _client = null;
    _initialized = false;
  }
}