import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../icons/app_icons.dart';

/// Standard MONQIZ Status Badge / Indicator Pill
/// Matches Section 4 (Status Badges) in code.html
class MonqizBadge extends StatelessWidget {
  const MonqizBadge({
    super.key,
    required this.text,
    this.icon,
    this.iconWidget,
    this.backgroundColor = AppColors.surfaceSubtle,
    this.textColor = AppColors.textPrimary,
    this.borderColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// 1. Critical Urgent Badge (حرج وعاجل)
  const MonqizBadge.emergency({
    super.key,
    String? text,
    String? label,
    this.icon,
    this.iconWidget,
    this.backgroundColor = const Color(0xFFFEE2E2),
    this.textColor = const Color(0xFF991B1B),
    this.borderColor = const Color(0xFFFECACA),
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : text = text ?? label ?? 'حالة طوارئ عاجلة';

  /// Blood Group Pill Badge
  const MonqizBadge.bloodGroup({
    super.key,
    required String bloodType,
    this.icon,
    this.iconWidget,
    this.backgroundColor = const Color(0xFFFEE2E2),
    this.textColor = const Color(0xFF8E1717),
    this.borderColor = const Color(0xFFFECACA),
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : text = bloodType;

  factory MonqizBadge.critical({
    Key? key,
    String text = 'حرج وعاجل (Critical)',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      iconWidget: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(left: 6),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      backgroundColor: const Color(0xFFFEE2E2),
      textColor: const Color(0xFF991B1B),
      borderColor: const Color(0xFFFECACA),
    );
  }

  /// 2. Eligible to Donate Badge (مؤهل للتبرع فوراً)
  factory MonqizBadge.eligible({
    Key? key,
    String text = 'مؤهل للتبرع فوراً (Eligible)',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.eligible,
      backgroundColor: const Color(0xFFDCFCE7),
      textColor: const Color(0xFF166534),
      borderColor: const Color(0xFFBBF7D0),
    );
  }

  /// 3. Rest Interval Badge (فترة راحة)
  factory MonqizBadge.restInterval({
    Key? key,
    String text = 'فترة راحة (84 يوماً)',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.restInterval,
      backgroundColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFF92400E),
      borderColor: const Color(0xFFFDE68A),
    );
  }

  /// 4. Biometric Verified Identity (بصمة وهوية موثقة)
  factory MonqizBadge.verified({
    Key? key,
    String text = 'بصمة وهوية موثقة',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.fingerprint,
      backgroundColor: const Color(0xFFE0F2FE),
      textColor: const Color(0xFF075985),
      borderColor: const Color(0xFFBAE6FD),
    );
  }

  /// 5. 24/7 Reception Desk (استقبال طوارئ 24/7)
  factory MonqizBadge.desk247({
    Key? key,
    String text = 'استقبال طوارئ 24/7',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.doorOpen,
      backgroundColor: const Color(0xFFF1F5F9),
      textColor: const Color(0xFF1F2937),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  /// 6. MOH Accreditation (اعتماد وزارة الصحة والسكان)
  factory MonqizBadge.moh({
    Key? key,
    String text = 'اعتماد وزارة الصحة والسكان',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.certificate,
      backgroundColor: const Color(0xFFF0FDFA),
      textColor: const Color(0xFF115E59),
      borderColor: const Color(0xFF99F6E4),
    );
  }

  /// Card Meta: Time remaining countdown badge
  factory MonqizBadge.timeRemaining({
    Key? key,
    required String text,
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.clock,
      backgroundColor: const Color(0xFFFEF2F2),
      textColor: const Color(0xFFB91C1C),
      borderColor: const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// Card Meta: Clinically verified badge
  factory MonqizBadge.clinicalVerified({
    Key? key,
    String text = 'معتمد سريرياً',
  }) {
    return MonqizBadge(
      key: key,
      text: text,
      icon: AppIcons.shieldVerified,
      backgroundColor: const Color(0xFFECFDF5),
      textColor: const Color(0xFF047857),
      borderColor: const Color(0xFFD1FAE5),
      borderRadius: BorderRadius.circular(6),
    );
  }

  final String text;
  final FaIconData? icon;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? AppSpacing.borderRadiusFull,
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ?iconWidget,
          if (icon != null) ...[
            AppIcon(icon, size: 12, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: AppTypography.bodySmall(color: textColor).copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
