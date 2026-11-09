import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design_system/design_system.dart';
import '../../domain/entities/blood_request_entity.dart';

class MonqizShareModal extends StatelessWidget {
  final BloodRequestEntity request;

  const MonqizShareModal({super.key, required this.request});

  static void show(BuildContext context, BloodRequestEntity request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonqizShareModal(request: request),
    );
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🚨 نداء استغاثة عاجل للتبرع بالدم | منقذ (MONQIZ)');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🩸 فصيلة الدم المطلوبة: ${request.bloodType.symbol} (${request.bloodType.label})');
    buffer.writeln('🏥 المستشفى: ${request.hospital.name}');
    buffer.writeln('📍 الموقع: ${request.hospital.address.city} - ${request.hospital.address.governorate}');
    buffer.writeln('🚪 القسم/الغرفة: ${request.roomInfo}');
    buffer.writeln('🔢 عدد الأكياس المطلوبة: ${request.unitsNeeded} (تم التعهد بـ ${request.unitsPledged})');
    buffer.writeln('⏱️ المهلة الزمنية: ${request.remainingTimeFormatted}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📞 هاتف المستشفى: ${request.hospital.phoneNumber}');
    buffer.writeln('📲 للمساهمة والتعهد الفوري، افتح تطبيق منقذ.');
    buffer.writeln('#منقذ #تبرع_بالدم #انقذ_حياة');
    return buffer.toString();
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    final text = _generateShareText();
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final webFallback = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(webFallback)) {
      await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _copyToClipboard(context);
      }
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _generateShareText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ نص الاستغاثة بنجاح إلى الحافظة'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius2Xl),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.share, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مشاركة بطاقة الاستغاثة',
                      style: AppTypography.heading3(color: AppColors.slate900).copyWith(fontSize: 18),
                    ),
                    Text(
                      'شارك الحالة لإنقاذ حياة مريض في أسرع وقت',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space6),

          // Visual Card Preview
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: AppColors.slate900,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Center(
                            child: AppIcon(AppIcons.droplet, size: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Text(
                          'منقذ • استغاثة عاجلة',
                          style: AppTypography.codeTag(color: Colors.white).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    MonqizBadge.timeRemaining(text: request.remainingTimeFormatted),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.hospital.name,
                            style: AppTypography.heading3(color: Colors.white).copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${request.roomInfo} • ${request.hospital.address.city}',
                            style: AppTypography.bodySmall(color: AppColors.textSubtle),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المطلوب: ${request.unitsNeeded} أكياس دم',
                            style: AppTypography.bodySmall(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),

                    // Blood type display
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          request.bloodType.symbol,
                          style: AppTypography.codeTag(color: Colors.white).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space6),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: MonqizButton(
                  label: 'مشاركة عبر واتساب',
                  icon: AppIcons.share,
                  onPressed: () => _shareToWhatsApp(context),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: MonqizButton.outline(
                  label: 'نسخ نص الاستغاثة',
                  onPressed: () => _copyToClipboard(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
      ),
    );
  }
}
