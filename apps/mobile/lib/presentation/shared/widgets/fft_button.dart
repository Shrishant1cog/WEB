/// FFT Button Component
/// Modern button with consistent styling using design tokens

import 'package:flutter/material.dart';

import '../themes/design_tokens.dart';

enum ButtonSize { sm, md, lg, xl }
enum ButtonVariant { filled, outlined, text, elevated, tonal, destructive }

class FFTButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonSize size;
  final ButtonVariant variant;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const FFTButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.size = ButtonSize.md,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    final (horizontalPadding, verticalPadding, fontSize, iconSize, minHeight) = switch (size) {
      ButtonSize.sm => (12.0, 8.0, 13.0, 14.0, 36.0),
      ButtonSize.md => (20.0, 12.0, 14.0, 18.0, 44.0),
      ButtonSize.lg => (28.0, 14.0, 16.0, 20.0, 52.0),
      ButtonSize.xl => (36.0, 18.0, 18.0, 22.0, 60.0),
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonStyle = switch (variant) {
      ButtonVariant.filled => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? Brand.primaryAmber,
        foregroundColor: foregroundColor ?? Colors.white,
        disabledBackgroundColor: isDark
            ? Brand.primaryAmber.withValues(alpha: 0.38)
            : Brand.primaryAmber.withValues(alpha: 0.38),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(
          fontSize: fontSize,
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

      ButtonVariant.outlined => OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? Brand.primaryAmber,
        side: BorderSide(
          color: backgroundColor ?? Brand.primaryAmber,
          width: 1.5,
        ),
        disabledForegroundColor: isDark
            ? Brand.primaryAmber.withValues(alpha: 0.38)
            : Brand.primaryAmber.withValues(alpha: 0.38),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(fontSize: fontSize),
      ),

      ButtonVariant.text => TextButton.styleFrom(
        foregroundColor: foregroundColor ?? Brand.primaryAmber,
        disabledForegroundColor: isDark
            ? Brand.primaryAmber.withValues(alpha: 0.38)
            : Brand.primaryAmber.withValues(alpha: 0.38),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),

      ButtonVariant.elevated => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Brand.primaryAmber,
        foregroundColor: foregroundColor ?? Colors.white,
        disabledBackgroundColor: isDark
            ? Brand.primaryAmber.withValues(alpha: 0.38)
            : Brand.primaryAmber.withValues(alpha: 0.38),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(fontSize: fontSize),
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

      ButtonVariant.tonal => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? Brand.secondaryBlue.withValues(alpha: 0.15),
        foregroundColor: foregroundColor ?? Brand.secondaryBlue,
        disabledBackgroundColor: isDark
            ? Brand.secondaryBlue.withValues(alpha: 0.1)
            : Brand.secondaryBlue.withValues(alpha: 0.05),
        disabledForegroundColor: isDark
            ? Brand.secondaryBlue.withValues(alpha: 0.38)
            : Brand.secondaryBlue.withValues(alpha: 0.38),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(fontSize: fontSize),
      ),

      ButtonVariant.destructive => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? Semantic.error,
        foregroundColor: foregroundColor ?? Colors.white,
        disabledBackgroundColor: Semantic.error.withValues(alpha: 0.38),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        minimumSize: Size(0, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: TypeScale.titleMedium.copyWith(fontSize: fontSize),
      ),
    };

    final button = switch (variant) {
      ButtonVariant.filled => FilledButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
      ButtonVariant.outlined => OutlinedButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
      ButtonVariant.text => TextButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
      ButtonVariant.elevated => ElevatedButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
      ButtonVariant.tonal => FilledButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
      ButtonVariant.destructive => FilledButton(
        style: buttonStyle,
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(theme, fontSize, iconSize),
      ),
    };

    return SizedBox(
      width: width,
      child: button,
    );
  }

  Widget _buildChild(ThemeData theme, double fontSize, double iconSize) {
    if (isLoading) {
      final color = variant == ButtonVariant.filled ||
              variant == ButtonVariant.elevated ||
              variant == ButtonVariant.destructive
          ? Colors.white
          : Brand.primaryAmber;

      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon!, size: iconSize),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'SpaceGrotesk',
      ),
    );
  }
}