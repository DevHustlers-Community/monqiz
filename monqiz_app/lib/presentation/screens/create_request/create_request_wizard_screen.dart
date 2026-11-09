import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/hospital_entity.dart';
import '../../cubits/create_request/create_request_cubit.dart';
import '../../cubits/create_request/create_request_state.dart';
import '../../cubits/hospitals/hospital_directory_cubit.dart';
import '../../cubits/hospitals/hospital_directory_state.dart';

class CreateRequestWizardScreen extends StatelessWidget {
  const CreateRequestWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CreateRequestCubit>()),
        BlocProvider(create: (_) => sl<HospitalDirectoryCubit>()..loadHospitals()),
      ],
      child: const _CreateRequestWizardView(),
    );
  }
}

class _CreateRequestWizardView extends StatefulWidget {
  const _CreateRequestWizardView();

  @override
  State<_CreateRequestWizardView> createState() => _CreateRequestWizardViewState();
}

class _CreateRequestWizardViewState extends State<_CreateRequestWizardView> {
  final TextEditingController _roomController = TextEditingController(text: 'غرفة فرز المتبرعين 304');
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        title: Text(
          'طلب دم عاجل جديد',
          style: AppTypography.heading4(color: Colors.white),
        ),
      ),
      body: BlocConsumer<CreateRequestCubit, CreateRequestState>(
        listener: (context, state) {
          if (state.createdRequest != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إرسال نداء الاستغاثة ${state.createdRequest!.caseId} للمستشفى بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<CreateRequestCubit>().resetForm();
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Step progress header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6, vertical: AppSpacing.space3),
                color: AppColors.surfaceCard,
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'البيانات الطبية', state.currentStep),
                    Expanded(child: Container(height: 2, color: state.currentStep >= 1 ? AppColors.primary : AppColors.borderLight)),
                    _buildStepIndicator(1, 'المستشفى', state.currentStep),
                    Expanded(child: Container(height: 2, color: state.currentStep >= 2 ? AppColors.primary : AppColors.borderLight)),
                    _buildStepIndicator(2, 'المراجعة والنشر', state.currentStep),
                  ],
                ),
              ),

              // Content body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: switch (state.currentStep) {
                    0 => _buildStep1MedicalInfo(context, state),
                    1 => _buildStep2HospitalSelection(context, state),
                    _ => _buildStep3ReviewAndSubmit(context, state),
                  },
                ),
              ),

              // Bottom action bar
              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                      Expanded(
                        child: MonqizButton(
                          label: 'السابق',
                          variant: MonqizButtonVariant.outline,
                          onPressed: () => context.read<CreateRequestCubit>().previousStep(),
                        ),
                      ),
                    if (state.currentStep > 0) const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      flex: 2,
                      child: MonqizButton(
                        label: state.currentStep == 2
                            ? (state.isSubmitting ? 'جاري النشر...' : 'نشر نداء الاستغاثة')
                            : 'التالي',
                        isLoading: state.isSubmitting,
                        onPressed: () {
                          if (state.currentStep == 2) {
                            context.read<CreateRequestCubit>().submitEmergencyRequest();
                          } else {
                            context.read<CreateRequestCubit>().nextStep();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, int currentStep) {
    final isActive = currentStep >= stepIndex;
    final isCurrent = currentStep == stepIndex;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceBase,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.borderLight,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${stepIndex + 1}',
              style: AppTypography.caption(
                color: isActive ? Colors.white : AppColors.textSubtle,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTypography.caption(
            color: isCurrent ? AppColors.slate900 : AppColors.textSubtle,
          ).copyWith(fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildStep1MedicalInfo(BuildContext context, CreateRequestState state) {
    final cubit = context.read<CreateRequestCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'فصيلة الدم المطلوبة:',
          style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: BloodType.values.where((b) => b != BloodType.unknown).map((b) {
            final isSelected = state.selectedBloodType == b;
            return ChoiceChip(
              label: Text(
                b.symbol,
                style: AppTypography.bodyMedium(color: isSelected ? Colors.white : AppColors.slate900).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderLight),
              ),
              onSelected: (selected) {
                if (selected) cubit.updateBloodType(b);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.space6),

        Text(
          'عدد الأكياس المطلوبة:',
          style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.space2),
        Row(
          children: [
            MonqizIconButton(
              icon: AppIcons.minus,
              onPressed: state.unitsNeeded > 1
                  ? () => cubit.updateUnitsNeeded(state.unitsNeeded - 1)
                  : null,
            ),
            const SizedBox(width: AppSpacing.space4),
            Text(
              '${state.unitsNeeded} أكياس',
              style: AppTypography.heading2(color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.space4),
            MonqizIconButton(
              icon: AppIcons.plus,
              onPressed: state.unitsNeeded < 10
                  ? () => cubit.updateUnitsNeeded(state.unitsNeeded + 1)
                  : null,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.space6),

        Text(
          'تفاصيل الحالة الطبية:',
          style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.space2),
        MonqizTextField(
          controller: _detailsController,
          hintText: 'مثال: مريض بالعناية المركزة يخضع لجراحة طارئة...',
          maxLines: 3,
          onChanged: cubit.updateDetails,
        ),
      ],
    );
  }

  Widget _buildStep2HospitalSelection(BuildContext context, CreateRequestState state) {
    final cubit = context.read<CreateRequestCubit>();
    return BlocBuilder<HospitalDirectoryCubit, HospitalDirectoryState>(
      builder: (context, hospState) {
        if (hospState is HospitalDirectoryLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final hospitals = hospState is HospitalDirectoryLoaded ? hospState.hospitals : <HospitalEntity>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر المستشفى المعتمد المشرف على الحالة:',
              style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.space3),

            ...hospitals.map((hosp) {
              final isSelected = state.selectedHospital?.id == hosp.id;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySoft : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: const AppIcon(AppIcons.hospital, color: AppColors.primary),
                  title: Text(
                    hosp.name,
                    style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${hosp.address.governorate} • ${hosp.address.city}',
                    style: AppTypography.caption(color: AppColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const AppIcon(AppIcons.circleCheck, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () => cubit.updateHospital(hosp),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.space4),
            Text(
              'مكان الحالة داخل المستشفى:',
              style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.space2),
            MonqizTextField(
              controller: _roomController,
              hintText: 'مثال: الدور الثالث - غرفة 304',
              prefixIcon: AppIcons.doorOpen,
              onChanged: cubit.updateRoomInfo,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep3ReviewAndSubmit(BuildContext context, CreateRequestState state) {
    return Container(
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
              MonqizBadge.bloodGroup(bloodType: state.selectedBloodType.symbol),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  'مراجعة وتأكيد نداء الاستغاثة',
                  style: AppTypography.heading3(color: AppColors.slate900).copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.space3),

          _buildReviewItem('المستشفى المشرف', state.selectedHospital?.name ?? '--'),
          const SizedBox(height: AppSpacing.space2),
          _buildReviewItem('المحافظة والمدينة', state.selectedHospital?.address.fullAddress ?? '--'),
          const SizedBox(height: AppSpacing.space2),
          _buildReviewItem('فصيلة الدم المطلوبة', state.selectedBloodType.symbol),
          const SizedBox(height: AppSpacing.space2),
          _buildReviewItem('الكمية المطلوبة', '${state.unitsNeeded} أكياس'),
          const SizedBox(height: AppSpacing.space2),
          _buildReviewItem('الغرفة / القسم', state.roomInfo),

          const SizedBox(height: AppSpacing.space4),
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Row(
              children: [
                const AppIcon(AppIcons.shieldVerified, color: AppColors.info, size: 20),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    'سيتم إرسال الطلب لبنك دم المستشفى للمراجعة والاعتماد السريع قبل نشره للمتبرعين.',
                    style: AppTypography.caption(color: AppColors.info).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
