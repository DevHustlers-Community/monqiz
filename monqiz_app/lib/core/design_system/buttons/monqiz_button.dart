import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../icons/app_icons.dart';

enum MonqizButtonVariant {
  /// Primary Red Button (#C62828)
  primary,

  /// Secondary Soft Red Button (#FEE2E2 bg with #8E1717 text)
  secondarySoft,

  /// Secondary alias
  secondary,

  /// Outline Neutral Button (#FFFFFF bg with #E2E8F0 border)
  outline,

  /// Hotline 19888 Dark Button (#0F172A bg with #FBBF24 text)
  hotline,
}

enum MonqizButtonSize {
  small,
  medium,
  large,
}

/// Standard MONQIZ Interactive Button
/// Conforms to Design System:
/// Height: 48px (or 52px for mobile primary CTA)
/// Border Radius: 12px
class MonqizButton extends StatelessWidget {
  const MonqizButton({
    super.key,
    String? label,
    String? text,
    required this.onPressed,
    this.variant = MonqizButtonVariant.primary,
    this.size = MonqizButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.isCta = false,
  }) : label = label ?? text ?? '';

  /// Factory constructor for Primary Emergency Button
  factory MonqizButton.primary({
    Key? key,
    String? label,
    String? text,
    required VoidCallback? onPressed,
    dynamic icon,
    bool isLoading = false,
    bool fullWidth = true,
    bool isCta = false,
    MonqizButtonSize size = MonqizButtonSize.medium,
  }) =>
      MonqizButton(
        key: key,
        label: label,
        text: text,
        onPressed: onPressed,
        variant: MonqizButtonVariant.primary,
        size: size,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
        isCta: isCta,
      );

  /// Factory constructor for Secondary Soft Button
  factory MonqizButton.secondarySoft({
    Key? key,
    String? label,
    String? text,
    required VoidCallback? onPressed,
    dynamic icon,
    bool isLoading = false,
    bool fullWidth = true,
    MonqizButtonSize size = MonqizButtonSize.medium,
  }) =>
      MonqizButton(
        key: key,
        label: label,
        text: text,
        onPressed: onPressed,
        variant: MonqizButtonVariant.secondarySoft,
        size: size,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
      );

  /// Factory constructor for Outline Neutral Button
  factory MonqizButton.outline({
    Key? key,
    String? label,
    String? text,
    required VoidCallback? onPressed,
    dynamic icon,
    bool isLoading = false,
    bool fullWidth = true,
    MonqizButtonSize size = MonqizButtonSize.medium,
  }) =>
      MonqizButton(
        key: key,
        label: label,
        text: text,
        onPressed: onPressed,
        variant: MonqizButtonVariant.outline,
        size: size,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
      );

  /// Factory constructor for Hotline 24/7 Button
  factory MonqizButton.hotline({
    Key? key,
    String label = 'الخط الساخن 19888',
    required VoidCallback? onPressed,
    dynamic icon,
    bool isLoading = false,
    bool fullWidth = true,
  }) =>
      MonqizButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: MonqizButtonVariant.hotline,
        icon: icon ?? AppIcons.hotline,
        isLoading: isLoading,
        fullWidth: fullWidth,
      );

  final String label;
  final VoidCallback? onPressed;
  final MonqizButtonVariant variant;
  final MonqizButtonSize size;
  final dynamic icon;
  final bool isLoading;
  final bool fullWidth;
  final bool isCta;

  @override
  Widget build(BuildContext context) {
    double height = isCta ? AppSpacing.buttonHeightCta : AppSpacing.controlHeight;
    if (size == MonqizButtonSize.small) {
      height = 36.0;
    } else if (size == MonqizButtonSize.large) {
      height = 52.0;
    }

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    List<BoxShadow> shadows = AppSpacing.shadowSm;

    switch (variant) {
      case MonqizButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        if (isCta) {
          shadows = AppSpacing.shadowRedGlow;
        }
        break;
      case MonqizButtonVariant.secondary:
      case MonqizButtonVariant.secondarySoft:
        backgroundColor = AppColors.primaryTint;
        foregroundColor = AppColors.primaryDark;
        borderSide = const BorderSide(color: Color(0xFFFECACA), width: 1);
        break;
      case MonqizButtonVariant.outline:
        backgroundColor = AppColors.surfaceCard;
        foregroundColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
      case MonqizButtonVariant.hotline:
        backgroundColor = AppColors.slate900;
        foregroundColor = const Color(0xFFFBBF24); // amber-400
        break;
    }

    final bool enabled = onPressed != null && !isLoading;

    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            if (icon is FaIconData)
              FaIcon(icon as FaIconData, size: 16, color: foregroundColor)
            else if (icon is IconData)
              Icon(icon as IconData, size: 16, color: foregroundColor),
            const SizedBox(width: AppSpacing.space2),
          ],
          Text(
            label,
            style: AppTypography.buttonLabel(color: foregroundColor),
          ),
        ],
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : 0.6,
      child: Container(
        height: height,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppSpacing.borderRadiusXl,
          border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
          boxShadow: enabled ? shadows : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppSpacing.borderRadiusXl,
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
