import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/entities/blood_request_entity.dart';

class PledgeBottomSheet extends StatefulWidget {
  final BloodRequestEntity request;
  final VoidCallback onConfirmPledge;
  final bool isSubmitting;

  const PledgeBottomSheet({
    super.key,
    required this.request,
    required this.onConfirmPledge,
    this.isSubmitting = false,
  });

  @override
  State<PledgeBottomSheet> createState() => _PledgeBottomSheetState();
}

class _PledgeBottomSheetState extends State<PledgeBottomSheet> {
  bool _confirmedReadiness = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.heart, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تأكيد التعهد بالتبرع',
                      style: AppTypography.heading3(color: AppColors.slate900).copyWith(fontSize: 18),
                    ),
                    Text(
                      'الحالة: ${widget.request.caseId} • ${widget.request.hospital.name}',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space4),

          // Clinical pledge terms
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إقرار الجاهزية الطبية:',
                  style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  '• أؤكد أنني لست مصاباً بأي أمراض مزمنة أو أعراض برد وحمى حالياً.\n'
                  '• لم أقم بالتبرع بالدم خلال الـ 90 يوماً الماضية.\n'
                  '• سأتوجه إلى بنك دم المستشفى فور تأكيد هذا التعهد.',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // Checkbox acknowledgment
          InkWell(
            onTap: () {
              setState(() {
                _confirmedReadiness = !_confirmedReadiness;
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Row(
              children: [
                Checkbox(
                  value: _confirmedReadiness,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _confirmedReadiness = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'أقر بجاهزيتي التامة للتحرك الآن إلى المستشفى',
                    style: AppTypography.bodySmall(color: AppColors.slate900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // CTA
          MonqizButton(
            label: widget.isSubmitting ? 'جاري تسجيل التعهد...' : 'تأكيد التعهد والانطلاق',
            icon: AppIcons.heart,
            isLoading: widget.isSubmitting,
            onPressed: _confirmedReadiness && !widget.isSubmitting
                ? widget.onConfirmPledge
                : null,
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
      ),
    );
  }
}
