/// FFT Design System - Material 3 Theme Configuration
/// Tactical Slate / Competitive Amber
/// Professional esports tournament platform with strong visual hierarchy

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// FFT App Theme - Main entry point for theming
class AppTheme {
  /// Light theme - Tactical Slate (light)
  static ThemeData get lightTheme => buildLightTheme();

  /// Dark theme - Tactical Slate (dark) - Default
  static ThemeData get darkTheme => buildDarkTheme();

  /// Status color helpers
  static Color getStatusColor(String status, {bool isDark = true}) {
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

  /// Status chip widget
  static Widget statusChip(String status, {bool isDark = true, Color? color}) {
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
}