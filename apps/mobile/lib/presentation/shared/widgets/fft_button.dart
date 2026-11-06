/// FFT Button Component
/// Custom button with consistent styling

import 'package:flutter/material.dart';

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

    final (horizontalPadding, verticalPadding, fontSize, iconSize) = switch (size) {
      ButtonSize.sm => (16.0, 8.0, 13.0, 16.0),
      ButtonSize.md => (24.0, 12.0, 14.0, 18.0),
      ButtonSize.lg => (32.0, 16.0, 16.0, 20.0),
      ButtonSize.xl => (40.0, 20.0, 18.0, 24.0),
    };

    final buttonStyle = switch (variant) {
      ButtonVariant.filled => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.38),
        disabledForegroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.38),
      ),
      ButtonVariant.outlined => OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color: backgroundColor ?? theme.colorScheme.primary,
          width: 1.5,
        ),
        disabledForegroundColor: theme.colorScheme.primary.withValues(alpha: 0.38),
      ),
      ButtonVariant.text => TextButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        disabledForegroundColor: theme.colorScheme.primary.withValues(alpha: 0.38),
      ),
      ButtonVariant.elevated => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.38),
        disabledForegroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.38),
        elevation: 2,
      ),
      ButtonVariant.tonal => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.secondaryContainer,
        foregroundColor: foregroundColor ?? theme.colorScheme.onSecondaryContainer,
        disabledBackgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.38),
        disabledForegroundColor: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.38),
      ),
      ButtonVariant.destructive => FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.error,
        foregroundColor: foregroundColor ?? theme.colorScheme.onError,
        disabledBackgroundColor: theme.colorScheme.error.withValues(alpha: 0.38),
        disabledForegroundColor: theme.colorScheme.onError.withValues(alpha: 0.38),
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
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.filled || variant == ButtonVariant.elevated
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
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
              fontFamily: 'Inter',
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
        fontFamily: 'Inter',
      ),
    );
  }
}