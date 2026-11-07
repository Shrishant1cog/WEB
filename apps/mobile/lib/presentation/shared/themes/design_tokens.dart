/// FFT Design Tokens - Tactical Slate / Competitive Amber
/// Single source of truth for all visual design decisions.

library design_tokens;

import 'package:flutter/material.dart';

/// ===========================================================================
/// COLOUR PALETTE
/// ===========================================================================

/// Dark mode surfaces (default)
class DarkSurfaces {
  static const Color background = Color(0xFF181E29);
  static const Color surface = Color(0xFF1F2735);
  static const Color card = Color(0xFF252F3F);
  static const Color cardElevated = Color(0xFF2D3A4E);
  static const Color overlay = Color(0xFF141A24);
}

class LightSurfaces {
  static const Color background = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFEDF2F7);
  static const Color card = Color(0xFFF8FAFC);
  static const Color cardElevated = Color(0xFFFFFFFF);
  static const Color overlay = Color(0xFFE2E8F0);
}

/// Brand colours
class Brand {
  static const Color primaryAmber = Color(0xFFE58E26);
  static const Color primaryAmberLight = Color(0xFFF0A846);
  static const Color primaryAmberDark = Color(0xFFC4761A);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryBlueLight = Color(0xFF60A5FA);
  static const Color secondaryBlueDark = Color(0xFF2563EB);
  static const Color tealAccent = Color(0xFF14B8A6);
  static const Color tealAccentLight = Color(0xFF2DD4BF);
  static const Color tealAccentDark = Color(0xFF0D9488);
}

/// Semantic colours
class Semantic {
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);
  static const Color infoDark = Color(0xFF0891B2);
}

/// Tournament status colours
class Status {
  static const Color draft = Color(0xFF64748B);
  static const Color published = Color(0xFF06B6D4);
  static const Color registrationOpen = Color(0xFF10B981);
  static const Color registrationClosed = Color(0xFF64748B);
  static const Color live = Color(0xFFEF4444);
  static const Color finalized = Color(0xFF8B5CF6);
  static const Color cancelled = Color(0xFF64748B);
}

/// Text colours
class TextColors {
  // Dark mode
  static const Color darkPrimary = Color(0xFFF8FAFC);
  static const Color darkSecondary = Color(0xFF94A3B8);
  static const Color darkTertiary = Color(0xFF64748B);
  static const Color darkInverse = Color(0xFF181E29);

  // Light mode
  static const Color lightPrimary = Color(0xFF181E29);
  static const Color lightSecondary = Color(0xFF475569);
  static const Color lightTertiary = Color(0xFF64748B);
  static const Color lightInverse = Color(0xFFF8FAFC);
}

/// Border & divider colours
class BorderColors {
  static const Color darkPrimary = Color(0xFF334155);
  static const Color darkSubtle = Color(0xFF1E293B);
  static const Color lightPrimary = Color(0xFFCBD5E1);
  static const Color lightSubtle = Color(0xFFE2E8F0);
}

/// Focus & interaction states
class FocusColors {
  static const Color ring = Color(0xFFE58E26);
  static const Color ringOffset = Color(0xFF181E29);
  static const Color hoverOverlay = Color(0xFFFFFFFF);
  static const Color pressOverlay = Color(0x000000);
  static const double hoverOpacity = 0.08;
  static const double pressOpacity = 0.12;
}

/// Shadow elevations
class Shadows {
  static const List<BoxShadow> level0 = [];
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

/// ===========================================================================
/// SPACING SYSTEM
/// ===========================================================================

class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// ===========================================================================
/// BORDER RADIUS
/// ===========================================================================

class Radii {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 999.0;
}

/// ===========================================================================
/// ICON SIZES
/// ===========================================================================

class IconSizes {
  static const double xs = 14.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double xxl = 32.0;
}

/// ===========================================================================
/// TYPOGRAPHY SCALE
/// ===========================================================================

class TypeScale {
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Mono (for numeric data)
  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
}

/// ===========================================================================
/// TOURNAMENT STATUS HELPERS
/// ===========================================================================

/// Get color for tournament status
Color getStatusColor(String status, {bool isDark = true}) {
  switch (status) {
    case 'draft':
      return Status.draft;
    case 'published':
      return Status.published;
    case 'registration_open':
      return Status.registrationOpen;
    case 'registration_closed':
      return Status.registrationClosed;
    case 'live':
      return Status.live;
    case 'finalized':
      return Status.finalized;
    case 'cancelled':
      return Status.cancelled;
    default:
      return Status.draft;
  }
}

/// Get status label
String getStatusLabel(String status) {
  return status.replaceAll('_', ' ').toUpperCase();
}

/// Get status chip
Widget statusChip(String status, {bool isDark = true, Color? color}) {
  final c = color ?? getStatusColor(status);
  final label = status.replaceAll('_', ' ').toUpperCase();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(Radii.round),
      border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
    ),
    child: Text(
      label,
      style: TypeScale.labelSmall.copyWith(
        color: c,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// ===========================================================================
/// COMPONENT THEME BUILDERS
/// ===========================================================================

/// Card theme data
class FFCardThemeData {
  static CardThemeData dark() => CardThemeData(
        color: const Color(0xFF252F3F),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: const BorderSide(color: BorderColors.darkPrimary, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      );

  static CardThemeData light() => CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: const BorderSide(color: BorderColors.lightPrimary, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      );
}

/// Button theme data
class FFButtonThemeData {
  static FilledButtonThemeData filledDark() => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Brand.primaryAmber,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Brand.primaryAmber.withValues(alpha: 0.38),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
      );

  static FilledButtonThemeData filledLight() => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Brand.primaryAmber,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      );

  static ElevatedButtonThemeData elevatedLight() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.primaryAmber,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      );

  static ElevatedButtonThemeData elevatedDark() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.primaryAmber,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Brand.primaryAmber.withValues(alpha: 0.38),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Brand.primaryAmberDark.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
      );

  static OutlinedButtonThemeData outlinedDark() => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Brand.primaryAmber,
          disabledForegroundColor: const Color(0xFF64748B),
          side: const BorderSide(color: BorderColors.darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      );

  static OutlinedButtonThemeData outlinedLight() => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Brand.primaryAmber,
          disabledForegroundColor: const Color(0xFF94A3B8),
          side: const BorderSide(color: BorderColors.lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      );

  static TextButtonThemeData textDark() => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Brand.primaryAmber,
          disabledForegroundColor: const Color(0xFF64748B),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      );

  static TextButtonThemeData textLight() => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Brand.primaryAmber,
          disabledForegroundColor: const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      );
}

/// Input decoration theme
class FFInputTheme {
  static InputDecorationTheme dark() => InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2735),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TypeScale.bodyMedium.copyWith(color: TextColors.darkSecondary),
        hintStyle: TypeScale.bodyMedium.copyWith(color: TextColors.darkTertiary),
        errorStyle: TypeScale.bodySmall.copyWith(color: Semantic.error),
        floatingLabelStyle: TypeScale.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: Brand.primaryAmber,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.darkPrimary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.darkPrimary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Brand.primaryAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Semantic.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Semantic.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.darkSubtle, width: 1),
        ),
      );

  static InputDecorationTheme light() => InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TypeScale.bodyMedium.copyWith(color: TextColors.lightSecondary),
        hintStyle: TypeScale.bodyMedium.copyWith(color: TextColors.lightTertiary),
        errorStyle: TypeScale.bodySmall.copyWith(color: Semantic.error),
        floatingLabelStyle: TypeScale.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: Brand.primaryAmber,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.lightPrimary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.lightPrimary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Brand.primaryAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Semantic.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: Semantic.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: BorderColors.lightSubtle, width: 1),
        ),
      );
}

/// Chip theme
class FFChipThemeData {
  static ChipThemeData dark() => ChipThemeData(
        backgroundColor: const Color(0xFF1F2735),
        disabledColor: const Color(0xFF181E29),
        selectedColor: Brand.primaryAmber.withValues(alpha: 0.15),
        secondarySelectedColor: Brand.secondaryBlue.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TypeScale.labelMedium.copyWith(color: TextColors.darkPrimary),
        secondaryLabelStyle: TypeScale.labelMedium.copyWith(color: Colors.white),
        brightness: Brightness.dark,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          side: const BorderSide(color: BorderColors.darkPrimary, width: 1),
        ),
      );

  static ChipThemeData light() => ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        disabledColor: const Color(0xFFE2E8F0),
        selectedColor: Brand.primaryAmber.withValues(alpha: 0.15),
        secondarySelectedColor: Brand.secondaryBlue.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TypeScale.labelMedium.copyWith(color: TextColors.lightPrimary),
        secondaryLabelStyle: TypeScale.labelMedium.copyWith(color: Colors.white),
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          side: const BorderSide(color: BorderColors.lightPrimary, width: 1),
        ),
      );
}

/// Dialog theme
class FFDialogThemeData {
  static DialogThemeData dark() => DialogThemeData(
        backgroundColor: const Color(0xFF1F2735),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: TypeScale.titleLarge.copyWith(
          color: TextColors.darkPrimary,
        ),
        contentTextStyle: TypeScale.bodyMedium.copyWith(
          color: TextColors.darkSecondary,
        ),
      );

  static DialogThemeData light() => DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: TypeScale.titleLarge.copyWith(color: TextColors.lightPrimary),
        contentTextStyle: TypeScale.bodyMedium.copyWith(color: TextColors.lightSecondary),
      );
}

/// Navigation bar theme
class FFNavigationBarThemeData {
  static NavigationBarThemeData dark() => NavigationBarThemeData(
        height: 72,
        backgroundColor: const Color(0xFF181E29),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black,
        indicatorColor: Brand.primaryAmber.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TypeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Brand.primaryAmber,
            );
          }
          return TypeScale.labelMedium.copyWith(
            color: TextColors.darkTertiary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: Brand.primaryAmber, size: IconSizes.lg);
          }
          return IconThemeData(
            color: TextColors.darkTertiary,
            size: IconSizes.lg,
          );
        }),
      );

  static NavigationBarThemeData light() => NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        indicatorColor: Brand.primaryAmber.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TypeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Brand.primaryAmber,
            );
          }
          return TypeScale.labelMedium.copyWith(
            color: TextColors.lightTertiary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: Brand.primaryAmber, size: IconSizes.lg);
          }
          return IconThemeData(
            color: TextColors.lightTertiary,
            size: IconSizes.lg,
          );
        }),
      );
}

/// Navigation drawer theme
class FFNavigationDrawerThemeData {
  static NavigationDrawerThemeData dark() => NavigationDrawerThemeData(
        backgroundColor: const Color(0xFF181E29),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TypeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Brand.primaryAmber,
            );
          }
          return TypeScale.labelMedium.copyWith(
            color: TextColors.darkSecondary,
            fontWeight: FontWeight.w400,
          );
        }),
      );

  static NavigationDrawerThemeData light() => NavigationDrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TypeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Brand.primaryAmber,
            );
          }
          return TypeScale.labelMedium.copyWith(
            color: TextColors.lightSecondary,
            fontWeight: FontWeight.w400,
          );
        }),
      );
}

/// Tab bar theme
class FFTabBarThemeData {
  static TabBarThemeData dark() => TabBarThemeData(
        labelColor: Brand.primaryAmber,
        unselectedLabelColor: TextColors.darkTertiary,
        indicatorColor: Brand.primaryAmber,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TypeScale.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TypeScale.labelMedium.copyWith(fontWeight: FontWeight.w500),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Brand.primaryAmber.withValues(alpha: 0.1);
          }
          return null;
        }),
      );

  static TabBarThemeData light() => TabBarThemeData(
        labelColor: Brand.primaryAmber,
        unselectedLabelColor: TextColors.lightTertiary,
        indicatorColor: Brand.primaryAmber,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TypeScale.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TypeScale.labelMedium.copyWith(fontWeight: FontWeight.w500),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Brand.primaryAmber.withValues(alpha: 0.1);
          }
          return null;
        }),
      );
}

/// Divider theme
class FFDividerThemeData {
  static DividerThemeData dark() => DividerThemeData(
        color: BorderColors.darkPrimary,
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      );

  static DividerThemeData light() => DividerThemeData(
        color: BorderColors.lightPrimary,
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      );
}

/// List tile theme
class FFListTileThemeData {
  static ListTileThemeData dark() => ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TypeScale.titleMedium.copyWith(color: TextColors.darkPrimary),
        subtitleTextStyle: TypeScale.bodyMedium.copyWith(color: TextColors.darkSecondary),
        leadingAndTrailingTextStyle: TypeScale.labelMedium.copyWith(color: TextColors.darkTertiary),
        iconColor: TextColors.darkTertiary,
        selectedColor: Brand.primaryAmber,
        selectedTileColor: Brand.primaryAmber.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      );

  static ListTileThemeData light() => ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TypeScale.titleMedium.copyWith(color: TextColors.lightPrimary),
        subtitleTextStyle: TypeScale.bodyMedium.copyWith(color: TextColors.lightSecondary),
        leadingAndTrailingTextStyle: TypeScale.labelMedium.copyWith(color: TextColors.lightTertiary),
        iconColor: TextColors.lightTertiary,
        selectedColor: Brand.primaryAmber,
        selectedTileColor: Brand.primaryAmber.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      );
}

/// Floating action button theme
class FFFABThemeData {
  static FloatingActionButtonThemeData dark() => FloatingActionButtonThemeData(
        backgroundColor: Brand.primaryAmber,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        extendedTextStyle: TypeScale.titleMedium.copyWith(fontWeight: FontWeight.w600),
      );

  static FloatingActionButtonThemeData light() => FloatingActionButtonThemeData(
        backgroundColor: Brand.primaryAmber,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        extendedTextStyle: TypeScale.titleMedium.copyWith(fontWeight: FontWeight.w600),
      );
}

/// Tooltip theme
class FFTooltipThemeData {
  static TooltipThemeData dark() => TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2735),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: TypeScale.labelSmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        verticalOffset: 8,
      );

  static TooltipThemeData light() => TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2735),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: TypeScale.labelSmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        verticalOffset: 8,
      );
}

/// Snack bar theme
class FFSnackBarThemeData {
  static SnackBarThemeData dark() => SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2735),
        contentTextStyle: TypeScale.bodyMedium.copyWith(color: Colors.white),
        actionTextColor: Brand.primaryAmberLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        elevation: 4,
      );

  static SnackBarThemeData light() => SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2735),
        contentTextStyle: TypeScale.bodyMedium.copyWith(color: Colors.white),
        actionTextColor: Brand.primaryAmberLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        elevation: 4,
      );
}

/// Progress indicator theme
class FFProgressThemeData {
  static ProgressIndicatorThemeData dark() => ProgressIndicatorThemeData(
        color: Brand.primaryAmber,
        linearTrackColor: const Color(0xFF334155),
        circularTrackColor: const Color(0xFF334155),
      );

  static ProgressIndicatorThemeData light() => ProgressIndicatorThemeData(
        color: Brand.primaryAmber,
        linearTrackColor: const Color(0xFFE2E8F0),
        circularTrackColor: const Color(0xFFE2E8F0),
      );
}

/// Checkbox theme
class FFCheckboxThemeData {
  static CheckboxThemeData dark() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFF334155);
          return null;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: BorderColors.darkPrimary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xs)),
        visualDensity: VisualDensity.compact,
      );

  static CheckboxThemeData light() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFFE2E8F0);
          return null;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: BorderColors.lightPrimary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xs)),
        visualDensity: VisualDensity.compact,
      );
}

/// Radio theme
class FFRadioThemeData {
  static RadioThemeData dark() => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFF64748B);
          return null;
        }),
        visualDensity: VisualDensity.compact,
      );

  static RadioThemeData light() => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFF94A3B8);
          return null;
        }),
        visualDensity: VisualDensity.compact,
      );
}

/// Switch theme
class FFSwitchThemeData {
  static SwitchThemeData dark() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFF64748B);
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber.withValues(alpha: 0.5);
          if (states.contains(WidgetState.disabled)) return const Color(0xFF334155);
          return null;
        }),
      );

  static SwitchThemeData light() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.disabled)) return const Color(0xFF94A3B8);
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber.withValues(alpha: 0.5);
          if (states.contains(WidgetState.disabled)) return const Color(0xFFE2E8F0);
          return null;
        }),
      );
}

/// Slider theme
class FFSliderThemeData {
  static SliderThemeData dark() => SliderThemeData(
        activeTrackColor: Brand.primaryAmber,
        inactiveTrackColor: const Color(0xFF334155),
        thumbColor: Brand.primaryAmber,
        overlayColor: Brand.primaryAmber.withValues(alpha: 0.2),
        valueIndicatorColor: Brand.primaryAmber,
        valueIndicatorTextStyle: TypeScale.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      );

  static SliderThemeData light() => SliderThemeData(
        activeTrackColor: Brand.primaryAmber,
        inactiveTrackColor: const Color(0xFFE2E8F0),
        thumbColor: Brand.primaryAmber,
        overlayColor: Brand.primaryAmber.withValues(alpha: 0.2),
        valueIndicatorColor: Brand.primaryAmber,
        valueIndicatorTextStyle: TypeScale.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      );
}

/// Date picker theme
class FFDatePickerThemeData {
  static DatePickerThemeData dark() => DatePickerThemeData(
        backgroundColor: const Color(0xFF1F2735),
        headerBackgroundColor: Brand.primaryAmber,
        headerForegroundColor: Colors.white,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.pressed)) return Brand.primaryAmberDark;
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white as Color?;
          if (states.contains(WidgetState.disabled)) return TextColors.darkTertiary as Color?;
          return TextColors.darkPrimary as Color?;
        }),
        todayForegroundColor: WidgetStateProperty.all(Brand.primaryAmber),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) => TextColors.darkPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      );

  static DatePickerThemeData light() => DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Brand.primaryAmber,
        headerForegroundColor: Colors.white,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Brand.primaryAmber;
          if (states.contains(WidgetState.pressed)) return Brand.primaryAmberDark;
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white as Color?;
          if (states.contains(WidgetState.disabled)) return TextColors.lightTertiary as Color?;
          return TextColors.lightPrimary as Color?;
        }),
        todayForegroundColor: WidgetStateProperty.all(Brand.primaryAmber),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) => TextColors.lightPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      );
}

/// Time picker theme
class FFTimePickerThemeData {
  static TimePickerThemeData dark() => TimePickerThemeData(
        backgroundColor: const Color(0xFF1F2735),
        hourMinuteTextColor: TextColors.darkPrimary,
        dayPeriodTextColor: TextColors.darkPrimary,
        dialHandColor: Brand.primaryAmber,
        dialBackgroundColor: Brand.primaryAmber.withValues(alpha: 0.1),
        entryModeIconColor: Brand.primaryAmber,
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      );

  static TimePickerThemeData light() => TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteTextColor: TextColors.lightPrimary,
        dayPeriodTextColor: TextColors.lightPrimary,
        dialHandColor: Brand.primaryAmber,
        dialBackgroundColor: Brand.primaryAmber.withValues(alpha: 0.1),
        entryModeIconColor: Brand.primaryAmber,
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      );
}

/// ===========================================================================
/// LIGHT/DARK THEME BUILDERS
/// ===========================================================================

ThemeData buildLightTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Brand.primaryAmber,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFEF3C7),
        onPrimaryContainer: Brand.primaryAmberDark,
        secondary: Brand.secondaryBlue,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFDBEAFE),
        onSecondaryContainer: Brand.secondaryBlueDark,
        tertiary: Brand.tealAccent,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFCCFBF1),
        onTertiaryContainer: Brand.tealAccentDark,
        error: Semantic.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFEF2F2),
        onErrorContainer: Semantic.errorDark,
        surface: Colors.white,
        onSurface: TextColors.lightPrimary,
        surfaceContainerHighest: LightSurfaces.surface,
        onSurfaceVariant: TextColors.lightSecondary,
        outline: BorderColors.lightPrimary,
        outlineVariant: BorderColors.lightSubtle,
        shadow: Colors.black26,
        scrim: Colors.black54,
        inverseSurface: TextColors.lightInverse,
        onInverseSurface: TextColors.lightPrimary,
        inversePrimary: Brand.primaryAmber,
      ),
      textTheme: _buildTextTheme(false),
      appBarTheme: _buildAppBarTheme(false),
      cardTheme: FFCardThemeData.light(),
      elevatedButtonTheme: FFButtonThemeData.elevatedLight(),
      filledButtonTheme: FFButtonThemeData.filledLight(),
      outlinedButtonTheme: FFButtonThemeData.outlinedLight(),
      textButtonTheme: FFButtonThemeData.textLight(),
      inputDecorationTheme: FFInputTheme.light(),
      chipTheme: FFChipThemeData.light(),
      dialogTheme: FFDialogThemeData.light(),
      bottomSheetTheme: _buildBottomSheetTheme(false),
      navigationBarTheme: FFNavigationBarThemeData.light(),
      navigationDrawerTheme: FFNavigationDrawerThemeData.light(),
      tabBarTheme: FFTabBarThemeData.light(),
      dividerTheme: FFDividerThemeData.light(),
      listTileTheme: FFListTileThemeData.light(),
      floatingActionButtonTheme: FFFABThemeData.light(),
      tooltipTheme: FFTooltipThemeData.light(),
      snackBarTheme: FFSnackBarThemeData.light(),
      progressIndicatorTheme: FFProgressThemeData.light(),
      checkboxTheme: FFCheckboxThemeData.light(),
      radioTheme: FFRadioThemeData.light(),
      switchTheme: FFSwitchThemeData.light(),
      sliderTheme: FFSliderThemeData.light(),
      datePickerTheme: FFDatePickerThemeData.light(),
      timePickerTheme: FFTimePickerThemeData.light(),
    );

ThemeData buildDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Brand.primaryAmber,
        onPrimary: Colors.white,
        primaryContainer: Brand.primaryAmberDark,
        onPrimaryContainer: Color(0xFFFEF3C7),
        secondary: Brand.secondaryBlue,
        onSecondary: Colors.white,
        secondaryContainer: Brand.secondaryBlueDark,
        onSecondaryContainer: Color(0xFFDBEAFE),
        tertiary: Brand.tealAccent,
        onTertiary: Colors.white,
        tertiaryContainer: Brand.tealAccentDark,
        onTertiaryContainer: Color(0xFFCCFBF1),
        error: Semantic.error,
        onError: Colors.white,
        errorContainer: Semantic.errorDark,
        onErrorContainer: Semantic.error,
        surface: DarkSurfaces.surface,
        onSurface: TextColors.darkPrimary,
        surfaceContainerHighest: DarkSurfaces.surface,
        onSurfaceVariant: TextColors.darkSecondary,
        outline: BorderColors.darkPrimary,
        outlineVariant: BorderColors.darkSubtle,
        shadow: Colors.black,
        scrim: Colors.black87,
        inverseSurface: Colors.white,
        onInverseSurface: TextColors.darkInverse,
        inversePrimary: Brand.primaryAmber,
      ),
      textTheme: _buildTextTheme(true),
      appBarTheme: _buildAppBarTheme(true),
      cardTheme: FFCardThemeData.dark(),
      elevatedButtonTheme: FFButtonThemeData.elevatedDark(),
      filledButtonTheme: FFButtonThemeData.filledDark(),
      outlinedButtonTheme: FFButtonThemeData.outlinedDark(),
      textButtonTheme: FFButtonThemeData.textDark(),
      inputDecorationTheme: FFInputTheme.dark(),
      chipTheme: FFChipThemeData.dark(),
      dialogTheme: FFDialogThemeData.dark(),
      bottomSheetTheme: _buildBottomSheetTheme(true),
      navigationBarTheme: FFNavigationBarThemeData.dark(),
      navigationDrawerTheme: FFNavigationDrawerThemeData.dark(),
      tabBarTheme: FFTabBarThemeData.dark(),
      dividerTheme: FFDividerThemeData.dark(),
      listTileTheme: FFListTileThemeData.dark(),
      floatingActionButtonTheme: FFFABThemeData.dark(),
      tooltipTheme: FFTooltipThemeData.dark(),
      snackBarTheme: FFSnackBarThemeData.dark(),
      progressIndicatorTheme: FFProgressThemeData.dark(),
      checkboxTheme: FFCheckboxThemeData.dark(),
      radioTheme: FFRadioThemeData.dark(),
      switchTheme: FFSwitchThemeData.dark(),
      sliderTheme: FFSliderThemeData.dark(),
      datePickerTheme: FFDatePickerThemeData.dark(),
      timePickerTheme: FFTimePickerThemeData.dark(),
    );

TextTheme _buildTextTheme(bool isDark) => TextTheme(
      displayLarge: TypeScale.displayLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      displayMedium: TypeScale.displayMedium.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      displaySmall: TypeScale.displaySmall.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      headlineLarge: TypeScale.headlineLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      headlineMedium: TypeScale.headlineMedium.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      headlineSmall: TypeScale.headlineSmall.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      titleLarge: TypeScale.titleLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      titleMedium: TypeScale.titleMedium.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      titleSmall: TypeScale.titleSmall.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      bodyLarge: TypeScale.bodyLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      bodyMedium: TypeScale.bodyMedium.copyWith(
        color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
      ),
      bodySmall: TypeScale.bodySmall.copyWith(
        color: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
      ),
      labelLarge: TypeScale.labelLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      labelMedium: TypeScale.labelMedium.copyWith(
        color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
      ),
      labelSmall: TypeScale.labelSmall.copyWith(
        color: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
      ),
    );

AppBarTheme _buildAppBarTheme(bool isDark) => AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: isDark ? DarkSurfaces.background : Colors.white,
      foregroundColor: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      titleTextStyle: TypeScale.titleLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      iconTheme: IconThemeData(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
        size: IconSizes.lg,
      ),
      actionsIconTheme: IconThemeData(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
        size: IconSizes.lg,
      ),
    );

BottomSheetThemeData _buildBottomSheetTheme(bool isDark) => BottomSheetThemeData(
      backgroundColor: isDark ? DarkSurfaces.surface : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: isDark ? Colors.black : Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      modalBackgroundColor: isDark ? DarkSurfaces.surface : Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
    );