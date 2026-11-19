import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text('نشاطاتي وتبرعاتي', style: AppTypography.heading3(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_edu, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'سجل التبرعات والتعهدات',
                style: AppTypography.heading3(color: AppColors.slate900),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'ستتمكن هنا قريباً (الأسبوع الثالث) من متابعة جميع الحالات التي تعهدت بالتبرع لها، وحالة تأكيد التبرع من بنك الدم.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_clock, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      'ميزة قيد التطوير — Week 3 Milestone',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
