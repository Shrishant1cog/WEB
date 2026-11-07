/// FFT Text Field Component
/// Modern text field with consistent styling using design tokens

import 'package:flutter/material.dart';

import '../themes/design_tokens.dart';

class FFTTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final bool autofocus;

  const FFTTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = Radii.md,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      autofocus: autofocus,
      style: TypeScale.bodyLarge.copyWith(
        color: isDark ? TextColors.darkPrimary : TextColors.lightPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: IconSizes.md, color: isDark ? TextColors.darkTertiary : TextColors.lightTertiary)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? (isDark ? const Color(0xFF1F2735) : const Color(0xFFF8FAFC)),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? (isDark ? BorderColors.darkPrimary : BorderColors.lightPrimary),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? (isDark ? BorderColors.darkPrimary : BorderColors.lightPrimary),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? Brand.primaryAmber,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: errorBorderColor ?? Semantic.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Semantic.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: (isDark ? BorderColors.darkSubtle : BorderColors.lightSubtle),
            width: 1,
          ),
        ),
        labelStyle: TypeScale.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
        ),
        hintStyle: TypeScale.bodyMedium.copyWith(
          color: isDark
              ? TextColors.darkTertiary.withValues(alpha: 0.6)
              : TextColors.lightTertiary.withValues(alpha: 0.6),
        ),
        errorStyle: TypeScale.bodySmall.copyWith(
          color: Semantic.error,
        ),
        floatingLabelStyle: TypeScale.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: Brand.primaryAmber,
        ),
        prefixIconColor: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
        suffixIconColor: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
      ),
    );
  }
}