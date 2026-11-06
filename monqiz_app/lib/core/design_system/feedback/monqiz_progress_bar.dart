import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Standard MONQIZ Blood Units Progress Bar
class MonqizProgressBar extends StatelessWidget {
  const MonqizProgressBar({
    super.key,
    required this.currentUnits,
    required this.totalUnits,
    this.label = 'المحقق من وحدات الدم',
    this.height = 10.0,
    this.fillColor = AppColors.primary,
    this.backgroundColor = AppColors.surfaceSubtle,
  });

  final int currentUnits;
  final int totalUnits;
  final String label;
  final double height;
  final Color fillColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double ratio = totalUnits > 0 ? (currentUnits / totalUnits).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$currentUnits من $totalUnits وحدات مطلوبة',
              style: AppTypography.codeTag(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
