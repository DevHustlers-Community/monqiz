import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../badges/monqiz_badge.dart';
import '../buttons/monqiz_button.dart';
import '../buttons/monqiz_icon_button.dart';
import '../feedback/monqiz_progress_bar.dart';
import '../icons/app_icons.dart';

/// MONQIZ Urgent Case Card (Blood Request Card Spec)
/// Centerpiece UI component from code.html (Section 4, Component 3)
class MonqizBloodRequestCard extends StatelessWidget {
  const MonqizBloodRequestCard({
    super.key,
    required this.hospitalName,
    required this.category,
    required this.caseId,
    required this.roomInfo,
    required this.bloodType,
    required this.bloodTypeSubtitle,
    required this.remainingTime,
    required this.distanceLocation,
    required this.currentUnits,
    required this.totalUnits,
    required this.onPledge,
    this.onShare,
    this.isClinicallyVerified = true,
  });

  /// Factory constructor configured with sample mockup data from code.html
  factory MonqizBloodRequestCard.sample({
    VoidCallback? onPledge,
    VoidCallback? onShare,
  }) {
    return MonqizBloodRequestCard(
      hospitalName: 'مستشفى سرطان الأطفال 57357',
      category: 'عناية الأطفال المركزة • صفائح دموية',
      caseId: '#MQ-8921',
      roomInfo: 'غرفة فرز المتبرعين 304',
      bloodType: 'O-',
      bloodTypeSubtitle: 'نادر جداً',
      remainingTime: 'مطلوب خلال 3 ساعات',
      distanceLocation: '4.2 كم • السيدة زينب',
      currentUnits: 1,
      totalUnits: 3,
      onPledge: onPledge ?? () {},
      onShare: onShare ?? () {},
    );
  }

  final String hospitalName;
  final String category;
  final String caseId;
  final String roomInfo;
  final String bloodType;
  final String bloodTypeSubtitle;
  final String remainingTime;
  final String distanceLocation;
  final int currentUnits;
  final int totalUnits;
  final VoidCallback onPledge;
  final VoidCallback? onShare;
  final bool isClinicallyVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.borderRadius2Xl,
        border: Border.all(color: const Color(0xFFFECACA), width: 1), // red-200
        boxShadow: AppSpacing.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Accent Emergency Stripe
          Container(
            height: 4,
            color: AppColors.primary,
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Meta Bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          MonqizBadge.timeRemaining(text: remainingTime),
                          if (isClinicallyVerified)
                            MonqizBadge.clinicalVerified(),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppIcon(
                          AppIcons.location,
                          size: 11,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanceLocation,
                          style: AppTypography.codeTag(color: AppColors.textSubtle).copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.space3),

                // 2. Main Info + Blood Group Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: AppTypography.bodySmall(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hospitalName,
                            style: AppTypography.heading3(color: AppColors.textPrimary).copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رقم الحالة: $caseId • $roomInfo',
                            style: AppTypography.codeTag(color: AppColors.textSecondary).copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),

                    // Blood Badge (56x56)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppSpacing.borderRadius2Xl,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33C62828),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bloodType,
                            style: AppTypography.codeTag(color: Colors.white).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bloodTypeSubtitle,
                            style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.9)).copyWith(
                              fontSize: 9.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.space4),

                // 3. Progress Bar
                MonqizProgressBar(
                  currentUnits: currentUnits,
                  totalUnits: totalUnits,
                ),

                const SizedBox(height: AppSpacing.space4),

                // 4. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: MonqizButton.primary(
                          label: 'التعهد بالتبرع الآن',
                          icon: AppIcons.heart,
                          onPressed: onPledge,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    MonqizIconButton(
                      icon: AppIcons.share,
                      size: 44,
                      onPressed: onShare,
                      tooltip: 'مشاركة الحالة',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
