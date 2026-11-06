import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/blood_request_entity.dart';
import '../../cubits/request_details/request_details_cubit.dart';
import '../../cubits/request_details/request_details_state.dart';
import '../../widgets/monqiz_share_modal.dart';
import 'widgets/pledge_bottom_sheet.dart';

class RequestDetailsScreen extends StatelessWidget {
  final String requestId;
  final BloodRequestEntity? preloaded;

  const RequestDetailsScreen({
    super.key,
    required this.requestId,
    this.preloaded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RequestDetailsCubit>()..loadRequest(requestId, preloaded: preloaded),
      child: const _RequestDetailsView(),
    );
  }
}

class _RequestDetailsView extends StatelessWidget {
  const _RequestDetailsView();

  Future<void> _callHospital(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPledgeModal(BuildContext context, BloodRequestEntity request) {
    final cubit = context.read<RequestDetailsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: BlocConsumer<RequestDetailsCubit, RequestDetailsState>(
            listener: (context, state) {
              if (state is RequestDetailsLoaded && state.confirmedPledge != null) {
                Navigator.of(context).pop(); // Close sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('شكراً لك! تم تسجيل تعهدك بنجاح للحالة ${request.caseId}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isSubmitting = state is RequestDetailsLoaded && state.isPledgeSubmitting;
              return PledgeBottomSheet(
                request: request,
                isSubmitting: isSubmitting,
                onConfirmPledge: () {
                  cubit.pledgeDonation();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        title: Text(
          'تفاصيل نداء الاستغاثة',
          style: AppTypography.heading4(color: Colors.white),
        ),
        actions: [
          BlocBuilder<RequestDetailsCubit, RequestDetailsState>(
            builder: (context, state) {
              if (state is RequestDetailsLoaded) {
                return IconButton(
                  icon: const AppIcon(AppIcons.share, color: Colors.white, size: 20),
                  tooltip: 'مشاركة بطاقة الاستغاثة',
                  onPressed: () => MonqizShareModal.show(context, state.request),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<RequestDetailsCubit, RequestDetailsState>(
        listener: (context, state) {
          if (state is RequestDetailsLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RequestDetailsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is RequestDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Text(state.message, style: AppTypography.bodyMedium(color: AppColors.slate900)),
              ),
            );
          }

          if (state is RequestDetailsLoaded) {
            final request = state.request;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MonqizBadge.bloodGroup(bloodType: request.bloodType.symbol),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.hospital.name,
                                    style: AppTypography.heading3(color: AppColors.slate900).copyWith(fontSize: 16),
                                  ),
                                  Text(
                                    request.category,
                                    style: AppTypography.caption(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.space4),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: AppSpacing.space4),

                        // Progress
                        Text(
                          'حالة الاحتياج: ${request.unitsPledged} من ${request.unitsNeeded} أكياس مكتملة',
                          style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        MonqizProgressBar(
                          currentUnits: request.unitsPledged,
                          totalUnits: request.unitsNeeded,
                        ),

                        const SizedBox(height: AppSpacing.space4),

                        // Info grid
                        _buildInfoRow(AppIcons.clock, 'المهلة المتبقية', request.remainingTimeFormatted),
                        const SizedBox(height: AppSpacing.space3),
                        _buildInfoRow(AppIcons.doorOpen, 'مكان الحالة بالمستشفى', request.roomInfo),
                        const SizedBox(height: AppSpacing.space3),
                        _buildInfoRow(
                          AppIcons.location,
                          'الموقع',
                          '${request.hospital.address.governorate} - ${request.hospital.address.city}',
                        ),

                        if (request.details != null && request.details!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space4),
                          const Divider(color: AppColors.borderLight, height: 1),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            'ملاحظات وتفاصيل إضافية:',
                            style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            request.details!,
                            style: AppTypography.caption(color: AppColors.textSecondary).copyWith(height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space4),

                  // Hospital direct contact card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التواصل المباشر مع المستشفى:',
                          style: AppTypography.bodyBase(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Row(
                          children: [
                            Expanded(
                              child: MonqizButton(
                                label: 'الاتصال ببنك الدم',
                                icon: AppIcons.phone,
                                variant: MonqizButtonVariant.secondary,
                                onPressed: () => _callHospital(request.hospital.phoneNumber),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: MonqizButton(
                                label: 'الموقع على الخريطة',
                                icon: AppIcons.location,
                                variant: MonqizButtonVariant.outline,
                                onPressed: () => _openMap(request.hospital.locationUrl),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space6),

                  // Primary Pledge CTA
                  MonqizButton(
                    label: request.isFulfilled ? 'تم اكتمال عدد المتبرعين' : 'تعهد بالتبرع لهذه الحالة الآن',
                    icon: AppIcons.heart,
                    onPressed: request.isFulfilled ? null : () => _showPledgeModal(context, request),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(dynamic icon, String label, String value) {
    return Row(
      children: [
        AppIcon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.space2),
        Text(
          '$label: ',
          style: AppTypography.bodySmall(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
