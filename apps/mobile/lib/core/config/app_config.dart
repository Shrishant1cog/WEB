/// Application configuration and environment variables.
/// Values are passed via `--dart-define` at build time.
/// See `.env.example` for available variables.

class AppConfig {
  const AppConfig._();

  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://10.0.2.2:54321',
  );

  /// Supabase anon key (public)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Minimum player age (configurable for legal compliance)
  static const int minAge = int.fromEnvironment('FFT_MIN_AGE', defaultValue: 18);

  /// Enable push notifications (Phase 7)
  static const bool enablePush = bool.fromEnvironment('FFT_ENABLE_PUSH', defaultValue: false);

  /// Enable substitute players (deferred)
  static const bool enableSubstitutes = bool.fromEnvironment('FFT_ENABLE_SUBSTITUTES', defaultValue: false);

  /// Default squad size for Free Fire India
  static const int defaultSquadSize = int.fromEnvironment('FFT_DEFAULT_SQUAD_SIZE', defaultValue: 4);

  /// Dispute window in hours
  static const int disputeWindowHours = int.fromEnvironment('FFT_DISPUTE_WINDOW_HOURS', defaultValue: 2);

  /// Privacy policy version
  static const String privacyPolicyVersion = String.fromEnvironment(
    'FFT_PRIVACY_POLICY_VERSION',
    defaultValue: '1.0',
  );

  /// Terms of service version
  static const String tosVersion = String.fromEnvironment(
    'FFT_TOS_VERSION',
    defaultValue: '1.0',
  );

  /// Grievance officer email (DPDP requirement)
  static const String grievanceEmail = String.fromEnvironment(
    'FFT_GRIEVANCE_EMAIL',
    defaultValue: 'grievance@fft.app',
  );

  /// Support email
  static const String supportEmail = String.fromEnvironment(
    'FFT_SUPPORT_EMAIL',
    defaultValue: 'support@fft.app',
  );

  /// Whether running in debug mode
  static const bool isDebug = bool.fromEnvironment('FLUTTER_DEBUG', defaultValue: true);

  /// App name for display
  static const String appName = 'FFT';

  /// App tagline
  static const String appTagline = 'Independent Free Fire India Tournament Platform';

  /// Legal disclaimer (must be visible)
  static const String legalDisclaimer =
      'FFT is an independent tournament management platform. '
      'It is not affiliated with, endorsed by, or operated by Garena.';

  /// Validates required configuration
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw StateError('SUPABASE_URL is not configured');
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError('SUPABASE_ANON_KEY is not configured');
    }
    if (!supabaseUrl.startsWith('http')) {
      throw StateError('SUPABASE_URL must be a valid HTTP/HTTPS URL');
    }
  }
}