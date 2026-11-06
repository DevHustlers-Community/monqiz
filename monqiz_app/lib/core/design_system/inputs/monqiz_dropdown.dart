import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../icons/app_icons.dart';

/// Standard MONQIZ Styled Select Dropdown
/// Matches Governorate Select in code.html
class MonqizDropdown<T> extends StatelessWidget {
  const MonqizDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = Container(
      height: AppSpacing.controlHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const AppIcon(
            AppIcons.chevronDown,
            size: 14,
            color: AppColors.textSubtle,
          ),
          hint: hintText != null
              ? Text(hintText!, style: AppTypography.bodyBase(color: AppColors.textSubtle))
              : null,
          style: AppTypography.bodyBase(color: AppColors.textPrimary),
          dropdownColor: AppColors.surfaceCard,
          borderRadius: AppSpacing.borderRadiusXl,
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
          dropdownWidget,
        ],
      );
    }

    return dropdownWidget;
  }
}
