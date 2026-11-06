import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/hospital_entity.dart';
import '../../cubits/hospitals/hospital_directory_cubit.dart';
import '../../cubits/hospitals/hospital_directory_state.dart';

class HospitalsDirectoryScreen extends StatelessWidget {
  const HospitalsDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HospitalDirectoryCubit>()..loadHospitals(),
      child: const _HospitalsDirectoryView(),
    );
  }
}

class _HospitalsDirectoryView extends StatelessWidget {
  const _HospitalsDirectoryView();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        title: Text(
          'دليل بنوك الدم والمستشفيات',
          style: AppTypography.heading4(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: AppColors.surfaceCard,
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              children: [
                MonqizTextField(
                  hintText: 'ابحث عن مستشفى أو بنك دم معتمد...',
                  prefixIcon: AppIcons.search,
                  onChanged: (q) => context.read<HospitalDirectoryCubit>().search(q),
                ),
                const SizedBox(height: AppSpacing.space3),
                SizedBox(
                  height: 38,
                  child: BlocBuilder<HospitalDirectoryCubit, HospitalDirectoryState>(
                    builder: (context, state) {
                      final selectedGov = state is HospitalDirectoryLoaded ? state.selectedGovernorate : 'الكل';
                      const govs = ['الكل', 'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية'];
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: govs.map((gov) {
                          final isSelected = selectedGov == gov;
                          return Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.space2),
                            child: MonqizChip(
                              label: gov,
                              isSelected: isSelected,
                              onSelected: (_) => context.read<HospitalDirectoryCubit>().filterGovernorate(gov),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List of hospitals
          Expanded(
            child: BlocBuilder<HospitalDirectoryCubit, HospitalDirectoryState>(
              builder: (context, state) {
                if (state is HospitalDirectoryLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state is HospitalDirectoryError) {
                  return Center(
                    child: Text(state.message, style: AppTypography.bodyMedium(color: AppColors.slate900)),
                  );
                }

                if (state is HospitalDirectoryLoaded) {
                  if (state.hospitals.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد مستشفيات مطابقة للبحث',
                        style: AppTypography.bodyMedium(color: AppColors.textSubtle),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    itemCount: state.hospitals.length,
                    itemBuilder: (context, index) {
                      final hosp = state.hospitals[index];
                      return _buildHospitalCard(context, hosp);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, HospitalEntity hosp) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.hospital, color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hosp.name,
                      style: AppTypography.heading4(color: AppColors.slate900).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const AppIcon(AppIcons.location, size: 12, color: AppColors.textSubtle),
                        const SizedBox(width: 4),
                        Text(
                          '${hosp.address.governorate} • ${hosp.address.city}',
                          style: AppTypography.caption(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const MonqizBadge.emergency(label: 'معتمد'),
            ],
          ),

          const SizedBox(height: AppSpacing.space4),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: AppSpacing.space3),

          Row(
            children: [
              Expanded(
                child: MonqizButton(
                  label: 'اتصال هاتفياً',
                  icon: AppIcons.phone,
                  variant: MonqizButtonVariant.secondary,
                  onPressed: () => _callHospital(hosp.phoneNumber),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: MonqizButton(
                  label: 'الموقع بالخريطة',
                  icon: AppIcons.location,
                  variant: MonqizButtonVariant.outline,
                  onPressed: () => _openMap(hosp.locationUrl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
