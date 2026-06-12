import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

/// Branded text field used across the signup flow.
///
/// Wraps a [TextFormField] inside a [FrostedSurface] pill so every input
/// matches the login screen's resting style (frosted, rounded-999, brand
/// focus border from the global [InputDecorationTheme]). Inline error and
/// helper text are surfaced *below* the pill so they don't break the
/// rounded silhouette.
class SignupTextField extends StatelessWidget {
  const SignupTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.autofocus = false,
    this.controller,
  });

  final String? label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final IconData? leadingIcon;
  // Custom prefix widget (e.g. a country-code selector). Takes precedence over
  // [leadingIcon] and sizes to its own content.
  final Widget? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;
    // Pill for single-line, softer rectangle for multi-line so the text
    // doesn't get cropped by the curve.
    final radius = BorderRadius.circular(maxLines > 1 ? 24 : 999);
    // The global [InputDecorationTheme]'s focused outline is a 999-radius
    // pill — fine for single-line fields, but on multi-line fields it
    // pokes past the rectangular [FrostedSurface]. Override the focused
    // border to match the surface's radius so the two shapes align.
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(width: 1.5, color: BrandColors.primary),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const Gap(AppSizes.xs + 2),
        ],
        FrostedSurface(
          borderRadius: radius,
          child: TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            onChanged: onChanged,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLength: maxLength,
            maxLines: obscureText ? 1 : maxLines,
            minLines: minLines,
            inputFormatters: inputFormatters,
            autofocus: autofocus,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon:
                  leading ??
                  (leadingIcon == null ? null : Icon(leadingIcon, size: 20)),
              prefixIconConstraints: leading != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              suffixIcon: trailing,
              counterText: '',
              focusedBorder: focusedBorder,
              focusedErrorBorder: focusedBorder,
            ),
          ),
        ),
        if (hasError) ...[
          const Gap(AppSizes.xs + 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: scheme.error),
                const Gap(AppSizes.xs),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (helperText != null) ...[
          const Gap(AppSizes.xs + 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Text(
              helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
