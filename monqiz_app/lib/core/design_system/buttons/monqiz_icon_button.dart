import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Reusable Monqiz Square/Action Icon Button
/// As used in the card actions (e.g., share action 44x44 or 48x48)
class MonqizIconButton extends StatelessWidget {
  const MonqizIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44.0,
    this.backgroundColor = AppColors.surfaceSubtle,
    this.iconColor = AppColors.textSecondary,
    this.borderColor,
    this.tooltip,
  });

  final FaIconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusXl,
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.borderRadiusXl,
          child: Center(
            child: FaIcon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
