/// Common validation utilities for forms and input.

class Validators {
  Validators._();

  /// Email validation (RFC 5322 compliant-ish)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Password validation (min 12 chars, complexity)
  static String? validatePassword(String? value, {int minLength = 12}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Confirm password matches
  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Display name validation
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Display name must be at most 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(value.trim())) {
      return 'Display name can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    return null;
  }

  /// In-game name validation
  static String? validateInGameName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length > 30) {
      return 'In-game name must be at most 30 characters';
    }
    return null;
  }

  /// In-game UID validation (Free Fire India format)
  static String? validateInGameUid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    // Free Fire UIDs are typically 9-12 digits
    if (!RegExp(r'^\d{9,12}$').hasMatch(value.trim())) {
      return 'Enter a valid Free Fire UID (9-12 digits)';
    }
    return null;
  }

  /// Team name validation
  static String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Team name is required';
    }
    if (value.trim().length < 2) {
      return 'Team name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Team name must be at most 50 characters';
    }
    return null;
  }

  /// Team tag validation (short identifier)
  static String? validateTeamTag(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2 || value.trim().length > 5) {
      return 'Team tag must be 2-5 characters';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.trim().toUpperCase())) {
      return 'Team tag can only contain uppercase letters and numbers';
    }
    return null;
  }

  /// Tournament title validation
  static String? validateTournamentTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tournament title is required';
    }
    if (value.trim().length > 200) {
      return 'Title must be at most 200 characters';
    }
    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Numeric range validation
  static String? validateNumericRange(String? value, {int? min, int? max, String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Value'} is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '${fieldName ?? 'Value'} must be a number';
    }
    if (min != null && parsed < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }
    if (max != null && parsed > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }
    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Enter a valid URL (http/https)';
      }
    } catch (_) {
      return 'Enter a valid URL';
    }
    return null;
  }
}