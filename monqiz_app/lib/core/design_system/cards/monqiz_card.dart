import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Standard MONQIZ Card Surface
/// Conforms to:
/// Radius: 16px (radius2Xl)
/// Background: #FFFFFF
/// Border: #E2E8F0 (1px)
/// Shadow: Shadow SM
class MonqizCard extends StatelessWidget {
  const MonqizCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.space4),
    this.backgroundColor = AppColors.surfaceCard,
    this.borderColor = AppColors.border,
    this.borderRadius,
    this.shadows = AppSpacing.shadowSm,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppSpacing.borderRadius2Xl;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
