import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/rules/eligibility_rules.dart';

class EligibilityBannerWidget extends StatelessWidget {
  final EligibilityResult eligibility;
  final VoidCallback? onCardTap;

  const EligibilityBannerWidget({
    super.key,
    required this.eligibility,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eligibility.isEligible) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(AppIcons.circleCheck, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهليتك الطبية: جاهز للتبرع اليوم',
                    style: AppTypography.heading4(color: AppColors.slate900).copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eligibility.statusMessage,
                    style: AppTypography.caption(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon(AppIcons.restInterval, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'في فترة تعافي فسيولوجية',
                        style: AppTypography.heading4(color: AppColors.slate900).copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eligibility.statusMessage,
                        style: AppTypography.caption(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: eligibility.recoveryProgress,
                minHeight: 6,
                backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }
  }
}
