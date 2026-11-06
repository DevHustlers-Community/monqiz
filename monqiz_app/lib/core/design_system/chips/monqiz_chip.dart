import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// MONQIZ Filter Chip & Blood Group Pill
/// Border Radius: 9999px (Pill)
class MonqizChip extends StatefulWidget {
  const MonqizChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isUrgent = false,
    this.onTap,
    this.onSelected,
  });

  final String label;
  final bool isSelected;
  final bool isUrgent;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelected;

  @override
  State<MonqizChip> createState() => _MonqizChipState();
}

class _MonqizChipState extends State<MonqizChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isUrgent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MonqizChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUrgent != oldWidget.isUrgent) {
      if (widget.isUrgent) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadows;

    if (widget.isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      shadows = AppSpacing.shadowSm;
    } else if (widget.isUrgent) {
      backgroundColor = AppColors.primarySoft;
      textColor = AppColors.primaryDark;
      border = Border.all(color: const Color(0xFFFECACA), width: 1);
    } else {
      backgroundColor = AppColors.surfaceSubtle;
      textColor = AppColors.textPrimary;
      border = Border.all(color: AppColors.border, width: 1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onTap?.call();
          widget.onSelected?.call(!widget.isSelected);
        },
        borderRadius: AppSpacing.borderRadiusFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppSpacing.borderRadiusFull,
            border: border,
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTypography.codeTag(color: textColor).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (widget.isUrgent) ...[
                const SizedBox(width: 6),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Preconfigured Blood Groups Filter Bar
class MonqizBloodFilterBar extends StatelessWidget {
  const MonqizBloodFilterBar({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
    this.bloodGroups = const ['الكل', 'O-', 'A+', 'B-', 'AB+', 'O+', 'A-', 'B+'],
    this.urgentGroups = const ['O-', 'B-'],
  });

  final String selectedGroup;
  final ValueChanged<String> onSelected;
  final List<String> bloodGroups;
  final List<String> urgentGroups;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: bloodGroups.map((group) {
          final isSelected = selectedGroup == group;
          final isUrgent = urgentGroups.contains(group) && !isSelected;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: MonqizChip(
              label: group,
              isSelected: isSelected,
              isUrgent: isUrgent,
              onTap: () => onSelected(group),
            ),
          );
        }).toList(),
      ),
    );
  }
}
