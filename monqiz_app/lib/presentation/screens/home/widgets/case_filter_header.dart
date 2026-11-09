import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/entities/enums.dart';

class CaseFilterHeader extends StatelessWidget {
  final BloodType? activeBloodFilter;
  final String activeGovernorate;
  final ValueChanged<BloodType?> onBloodTypeSelected;
  final ValueChanged<String?> onGovernorateSelected;

  const CaseFilterHeader({
    super.key,
    required this.activeBloodFilter,
    required this.activeGovernorate,
    required this.onBloodTypeSelected,
    required this.onGovernorateSelected,
  });

  static const List<String> governorates = [
    'الكل',
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'القليوبية',
    'الشرقية',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Location selector bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
          child: Row(
            children: [
              const AppIcon(AppIcons.location, color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'نطاق الاستغاثات:',
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: governorates.contains(activeGovernorate) ? activeGovernorate : 'الكل',
                      isDense: true,
                      icon: const AppIcon(AppIcons.chevronDown, size: 14, color: AppColors.textSubtle),
                      items: governorates.map((gov) {
                        return DropdownMenuItem<String>(
                          value: gov,
                          child: Text(
                            gov,
                            style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onGovernorateSelected,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Blood Type Chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.space2),
                child: MonqizChip(
                  label: 'الكل',
                  isSelected: activeBloodFilter == null,
                  onSelected: (selected) => onBloodTypeSelected(null),
                ),
              ),
              ...BloodType.values.where((b) => b != BloodType.unknown).map((b) {
                final isSelected = activeBloodFilter == b;
                return Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space2),
                  child: MonqizChip(
                    label: b.symbol,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      onBloodTypeSelected(isSelected ? null : b);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
