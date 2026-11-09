import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../icons/app_icons.dart';

/// Standard MONQIZ Form Input & Search Field
/// Height: 48px, Radius: 12px, Background: #F8FAFC, Border: #E2E8F0
class MonqizTextField extends StatelessWidget {
  const MonqizTextField({
    super.key,
    this.controller,
    String? hintText,
    String? hint,
    String? labelText,
    String? label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
  })  : hintText = hintText ?? hint,
        labelText = labelText ?? label;

  /// Specialized Constructor for the Search Bar
  factory MonqizTextField.search({
    Key? key,
    TextEditingController? controller,
    String hintText = 'ابحث باسم المستشفى أو الفصيلة أو المدينة...',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return MonqizTextField(
      key: key,
      controller: controller,
      hintText: hintText,
      prefixIcon: const AppIcon(
        AppIcons.search,
        size: 16,
        color: AppColors.textSubtle,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;

  Widget? _resolveIcon(dynamic icon, {VoidCallback? onTap}) {
    if (icon == null) return null;
    Widget child;
    if (icon is Widget) {
      child = icon;
    } else if (icon is FaIconData || icon is IconData) {
      child = AppIcon(icon, size: 16, color: AppColors.textSubtle);
    } else {
      return null;
    }

    if (onTap != null) {
      return IconButton(
        icon: child,
        onPressed: onTap,
        splashRadius: 20,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPrefix = _resolveIcon(prefixIcon);
    final resolvedSuffix = _resolveIcon(suffixIcon, onTap: onSuffixTap);

    final inputWidget = TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      onTap: onTap,
      style: AppTypography.bodyBase(color: AppColors.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: enabled ? AppColors.surfaceBase : AppColors.surfaceSubtle,
        hintText: hintText,
        hintStyle: AppTypography.bodyBase(color: AppColors.textSubtle),
        prefixIcon: resolvedPrefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: resolvedSuffix,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );

    if (labelText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText!,
            style: AppTypography.heading4(color: AppColors.textPrimary).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          inputWidget,
        ],
      );
    }

    return inputWidget;
  }
}
