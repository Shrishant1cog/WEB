/// FFT Design System - Material 3 Theme Configuration
/// Professional esports operations aesthetic with strong visual hierarchy

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppTheme {
  // ===========================================================================
  // COLOR PALETTE
  // ===========================================================================

  // Primary - Deep esports blue
  static const Color _primaryBase = Color(0xFF1E3A8A); // Blue 900
  static const Color _primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color _primaryDark = Color(0xFF1E1B4B); // Indigo 950

  // Secondary - Tournament gold/amber
  static const Color _secondaryBase = Color(0xFFF59E0B); // Amber 500
  static const Color _secondaryLight = Color(0xFFFBBF24); // Amber 400
  static const Color _secondaryDark = Color(0xFFB45309); // Amber 700

  // Surface variants
  static const Color _surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color _surfaceVariantDark = Color(0xFF1E293B); // Slate 800

  // Status colors
  static const Color _successBase = Color(0xFF059669); // Emerald 600
  static const Color _warningBase = Color(0xFFD97706); // Amber 600
  static const Color _errorBase = Color(0xFFDC2626); // Red 600
  static const Color _infoBase = Color(0xFF0284C7); // Sky 600

  // Tournament status colors
  static const Color _statusDraft = Color(0xFF64748B); // Slate 500
  static const Color _statusPublished = Color(0xFF0284C7); // Sky 600
  static const Color _statusRegistrationOpen = Color(0xFF059669); // Emerald 600
  static const Color _statusLive = Color(0xFFDC2626); // Red 600
  static const Color _statusFinalized = Color(0xFF7C3AED); // Violet 600
  static const Color _statusCancelled = Color(0xFF64748B); // Slate 500

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: _primaryBase,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFDBEAFE), // Blue 100
          onPrimaryContainer: _primaryDark,
          secondary: _secondaryBase,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFEF3C7), // Amber 100
          onSecondaryContainer: _secondaryDark,
          tertiary: _successBase,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFD1FAE5), // Emerald 100
          onTertiaryContainer: Color(0xFF064E3B), // Emerald 900
          error: _errorBase,
          onError: Colors.white,
          errorContainer: Color(0xFFFEF2F2), // Red 50
          onErrorContainer: Color(0xFF7F1D1D), // Red 900
          surface: Colors.white,
          onSurface: Color(0xFF0F172A), // Slate 900
          surfaceContainerHighest: _surfaceVariantLight,
          onSurfaceVariant: Color(0xFF334155), // Slate 700
          outline: Color(0xFFCBD5E1), // Slate 300
          outlineVariant: Color(0xFFE2E8F0), // Slate 200
          shadow: Colors.black26,
          scrim: Colors.black54,
          inverseSurface: Color(0xFF0F172A),
          onInverseSurface: Colors.white,
          inversePrimary: _primaryLight,
        ),

        // Typography
        textTheme: _textTheme(isDark: false),

        // Component themes
        appBarTheme: _appBarTheme(isDark: false),
        cardTheme: _cardTheme(isDark: false),
        elevatedButtonTheme: _elevatedButtonTheme(isDark: false),
        filledButtonTheme: _filledButtonTheme(isDark: false),
        outlinedButtonTheme: _outlinedButtonTheme(isDark: false),
        textButtonTheme: _textButtonTheme(isDark: false),
        inputDecorationTheme: _inputDecorationTheme(isDark: false),
        chipTheme: _chipTheme(isDark: false),
        dialogTheme: _dialogTheme(isDark: false),
        bottomSheetTheme: _bottomSheetTheme(isDark: false),
        navigationBarTheme: _navigationBarTheme(isDark: false),
        navigationDrawerTheme: _navigationDrawerTheme(isDark: false),
        tabBarTheme: _tabBarTheme(isDark: false),
        dividerTheme: _dividerTheme(isDark: false),
        listTileTheme: _listTileTheme(isDark: false),
        floatingActionButtonTheme: _fabTheme(isDark: false),
        tooltipTheme: _tooltipTheme(isDark: false),
        snackBarTheme: _snackBarTheme(isDark: false),
        progressIndicatorTheme: _progressIndicatorTheme(isDark: false),
        checkboxTheme: _checkboxTheme(isDark: false),
        radioTheme: _radioTheme(isDark: false),
        switchTheme: _switchTheme(isDark: false),
        sliderTheme: _sliderTheme(isDark: false),
        datePickerTheme: _datePickerTheme(isDark: false),
        timePickerTheme: _timePickerTheme(isDark: false),
      );

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primaryLight,
          onPrimary: _primaryDark,
          primaryContainer: _primaryDark,
          onPrimaryContainer: Color(0xFFDBEAFE),
          secondary: _secondaryLight,
          onSecondary: _secondaryDark,
          secondaryContainer: _secondaryDark,
          onSecondaryContainer: Color(0xFFFEF3C7),
          tertiary: _successBase,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFF064E3B),
          onTertiaryContainer: Color(0xFFD1FAE5),
          error: Color(0xFFEF4444), // Red 500
          onError: Colors.white,
          errorContainer: Color(0xFF7F1D1D),
          onErrorContainer: Color(0xFFFEF2F2),
          surface: Color(0xFF0F172A), // Slate 900
          onSurface: Color(0xFFF8FAFC), // Slate 50
          surfaceContainerHighest: _surfaceVariantDark,
          onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
          outline: Color(0xFF475569), // Slate 600
          outlineVariant: Color(0xFF334155), // Slate 700
          shadow: Colors.black,
          scrim: Colors.black87,
          inverseSurface: Color(0xFFF8FAFC),
          onInverseSurface: Color(0xFF0F172A),
          inversePrimary: _primaryBase,
        ),

        textTheme: _textTheme(isDark: true),
        appBarTheme: _appBarTheme(isDark: true),
        cardTheme: _cardTheme(isDark: true),
        elevatedButtonTheme: _elevatedButtonTheme(isDark: true),
        filledButtonTheme: _filledButtonTheme(isDark: true),
        outlinedButtonTheme: _outlinedButtonTheme(isDark: true),
        textButtonTheme: _textButtonTheme(isDark: true),
        inputDecorationTheme: _inputDecorationTheme(isDark: true),
        chipTheme: _chipTheme(isDark: true),
        dialogTheme: _dialogTheme(isDark: true),
        bottomSheetTheme: _bottomSheetTheme(isDark: true),
        navigationBarTheme: _navigationBarTheme(isDark: true),
        navigationDrawerTheme: _navigationDrawerTheme(isDark: true),
        tabBarTheme: _tabBarTheme(isDark: true),
        dividerTheme: _dividerTheme(isDark: true),
        listTileTheme: _listTileTheme(isDark: true),
        floatingActionButtonTheme: _fabTheme(isDark: true),
        tooltipTheme: _tooltipTheme(isDark: true),
        snackBarTheme: _snackBarTheme(isDark: true),
        progressIndicatorTheme: _progressIndicatorTheme(isDark: true),
        checkboxTheme: _checkboxTheme(isDark: true),
        radioTheme: _radioTheme(isDark: true),
        switchTheme: _switchTheme(isDark: true),
        sliderTheme: _sliderTheme(isDark: true),
        datePickerTheme: _datePickerTheme(isDark: true),
        timePickerTheme: _timePickerTheme(isDark: true),
      );

  // ===========================================================================
  // TYPOGRAPHY
  // ===========================================================================

  static TextTheme _textTheme({required bool isDark}) => TextTheme(
        // Display
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          height: 1.12,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),

        // Headline
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),

        // Title
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),

        // Body
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: isDark ? Colors.white : const Color(0xFF334155),
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),

        // Label
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      );

  // ===========================================================================
  // COMPONENT THEMES
  // ===========================================================================

  static AppBarTheme _appBarTheme({required bool isDark}) => AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          size: 24,
        ),
      );

  static CardThemeData _cardTheme({required bool isDark}) => CardThemeData(
        elevation: 0,
        shadowColor: isDark ? Colors.black : Colors.black26,
        surfaceTintColor: Colors.transparent,
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme({required bool isDark}) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: _primaryBase,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return _primaryDark.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.hovered)) {
                return _primaryDark.withValues(alpha: 0.05);
              }
              return null;
            },
          ),
        ),
      );

  static FilledButtonThemeData _filledButtonTheme({required bool isDark}) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryBase,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme({required bool isDark}) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBase,
          disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          side: BorderSide(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme({required bool isDark}) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBase,
          disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
        errorStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _errorBase,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _primaryBase,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primaryBase,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _errorBase,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _errorBase,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      );

  static ChipThemeData _chipTheme({required bool isDark}) => ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        disabledColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        selectedColor: _primaryBase.withValues(alpha: 0.15),
        secondarySelectedColor: _secondaryBase.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: isDark ? Brightness.dark : Brightness.light,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      );

  static DialogThemeData _dialogTheme({required bool isDark}) => DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: isDark ? Colors.black : Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      );

  static BottomSheetThemeData _bottomSheetTheme({required bool isDark}) => BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: isDark ? Colors.black : Colors.black26,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        constraints: const BoxConstraints(maxWidth: 600),
      );

  static NavigationBarThemeData _navigationBarTheme({required bool isDark}) =>
      NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: isDark ? Colors.black : Colors.black12,
        indicatorColor: _primaryBase.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryBase,
              );
            }
            return TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: _primaryBase, size: 24);
            }
            return IconThemeData(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 24,
            );
          },
        ),
      );

  static NavigationDrawerThemeData _navigationDrawerTheme({required bool isDark}) =>
      NavigationDrawerThemeData(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primaryBase,
              );
            }
            return TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            );
          },
        ),
      );

  static TabBarThemeData _tabBarTheme({required bool isDark}) => TabBarThemeData(
        labelColor: _primaryBase,
        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        indicatorColor: _primaryBase,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return _primaryBase.withValues(alpha: 0.1);
            }
            return null;
          },
        ),
      );

  static DividerThemeData _dividerTheme({required bool isDark}) => DividerThemeData(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      );

  static ListTileThemeData _listTileTheme({required bool isDark}) => ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        iconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        selectedColor: _primaryBase,
        selectedTileColor: _primaryBase.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static FloatingActionButtonThemeData _fabTheme({required bool isDark}) =>
      FloatingActionButtonThemeData(
        backgroundColor: _primaryBase,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static TooltipThemeData _tooltipTheme({required bool isDark}) => TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        verticalOffset: 8,
      );

  static SnackBarThemeData _snackBarTheme({required bool isDark}) => SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        actionTextColor: _secondaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      );

  static ProgressIndicatorThemeData _progressIndicatorTheme({required bool isDark}) =>
      ProgressIndicatorThemeData(
        color: _primaryBase,
        linearTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        circularTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      );

  static CheckboxThemeData _checkboxTheme({required bool isDark}) => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryBase;
            }
            if (states.contains(WidgetState.disabled)) {
              return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            }
            return null;
          },
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        visualDensity: VisualDensity.compact,
      );

  static RadioThemeData _radioTheme({required bool isDark}) => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryBase;
            }
            if (states.contains(WidgetState.disabled)) {
              return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
            }
            return null;
          },
        ),
        visualDensity: VisualDensity.compact,
      );

  static SwitchThemeData _switchTheme({required bool isDark}) => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryBase;
            }
            if (states.contains(WidgetState.disabled)) {
              return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
            }
            return null;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryBase.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.disabled)) {
              return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            }
            return null;
          },
        ),
      );

  static SliderThemeData _sliderTheme({required bool isDark}) => SliderThemeData(
        activeTrackColor: _primaryBase,
        inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        thumbColor: _primaryBase,
        overlayColor: _primaryBase.withValues(alpha: 0.2),
        valueIndicatorColor: _primaryBase,
        valueIndicatorTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );

  static DatePickerThemeData _datePickerTheme({required bool isDark}) => DatePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primaryBase,
        headerForegroundColor: Colors.white,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryBase;
            }
            if (states.contains(WidgetState.selected) && states.contains(WidgetState.pressed)) {
              return _primaryDark;
            }
            return null;
          },
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            if (states.contains(WidgetState.disabled)) {
              return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
            }
            return isDark ? Colors.white : const Color(0xFF1E293B);
          },
        ),
        todayForegroundColor: WidgetStateProperty.all(_primaryBase),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static TimePickerThemeData _timePickerTheme({required bool isDark}) => TimePickerThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        hourMinuteTextColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return isDark ? Colors.white : const Color(0xFF1E293B);
          },
        ),
        dayPeriodTextColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return isDark ? Colors.white : const Color(0xFF1E293B),
          },
        ),
        dialHandColor: _primaryBase,
        dialBackgroundColor: _primaryBase.withValues(alpha: 0.1),
        entryModeIconColor: _primaryBase,
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  // ===========================================================================
  // TOURNAMENT STATUS COLOR HELPERS
  // ===========================================================================

  /// Get color for tournament status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return _statusDraft;
      case 'published':
        return _statusPublished;
      case 'registration_open':
        return _statusRegistrationOpen;
      case 'registration_closed':
        return _statusPublished;
      case 'scheduled':
        return _statusPublished;
      case 'check_in':
        return _warningBase;
      case 'live':
        return _statusLive;
      case 'provisional_results':
        return _infoBase;
      case 'dispute_period':
        return _warningBase;
      case 'finalized':
        return _statusFinalized;
      case 'cancelled':
        return _statusCancelled;
      default:
        return _statusDraft;
    }
  }

  /// Get status chip for tournament status
  static Widget statusChip(String status) {
    final color = getStatusColor(status);
    final label = status.replaceAll('_', ' ').toUpperCase();
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}