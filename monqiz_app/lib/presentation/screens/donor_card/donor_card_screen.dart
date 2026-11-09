import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/donor_card/donor_card_cubit.dart';
import '../../cubits/donor_card/donor_card_state.dart';

class DonorCardScreen extends StatelessWidget {
  const DonorCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DonorCardCubit>()..loadDonorCard(),
      child: const _DonorCardView(),
    );
  }
}

class _DonorCardView extends StatelessWidget {
  const _DonorCardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        title: Text(
          'البطاقة الرقمية للمتبرع',
          style: AppTypography.heading4(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
            tooltip: 'الإعدادات والحساب ومسح الحساب',
            onPressed: () {
              context.push('/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<DonorCardCubit, DonorCardState>(
        builder: (context, state) {
          if (state is DonorCardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is DonorCardError) {
            return Center(
              child: Text(state.message, style: AppTypography.bodyMedium(color: AppColors.slate900)),
            );
          }

          if (state is DonorCardLoaded) {
            final user = state.user;
            final eligibility = state.eligibility;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Digital Donor Card (Front)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.slate900, Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.slate900.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: AppIcon(AppIcons.droplet, size: 14, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Text(
                                  'منقذ • MONQIZ',
                                  style: AppTypography.heading4(color: Colors.white).copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const AppIcon(AppIcons.circleCheck, size: 12, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    'متبرع موثق',
                                    style: AppTypography.caption(color: Colors.white).copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.space6),

                        // Center blood badge & donor name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  user.bloodType.symbol,
                                  style: AppTypography.heading1(color: Colors.white).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: AppTypography.heading3(color: Colors.white).copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'كود المتبرع: #MQ-${user.id.substring(0, user.id.length > 6 ? 6 : user.id.length)}',
                                    style: AppTypography.caption(color: AppColors.textSubtle),
                                  ),
                                  Text(
                                    '${user.preferredAddresses.isNotEmpty ? user.preferredAddresses.first.governorate : "مصر"} • ${user.gender.label}',
                                    style: AppTypography.caption(color: AppColors.textSubtle),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.space6),

                        // Card Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'وزارة الصحة والسكان • بنوك الدم',
                              style: AppTypography.caption(color: AppColors.textSubtle).copyWith(fontSize: 10),
                            ),
                            Text(
                              'تاريخ آخر تبرع: ${user.lastDonationDate != null ? DateFormat('yyyy/MM/dd').format(user.lastDonationDate!) : "جديد"}',
                              style: AppTypography.caption(color: AppColors.textSubtle).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space5),

                  // Eligibility countdown widget
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
                            AppIcon(
                              eligibility.isEligible ? AppIcons.circleCheck : AppIcons.restInterval,
                              color: eligibility.isEligible ? AppColors.success : AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Text(
                              'الحالة الصحية للتبرع:',
                              style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          eligibility.statusMessage,
                          style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          child: LinearProgressIndicator(
                            value: eligibility.recoveryProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              eligibility.isEligible ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space5),

                  // Donation statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('إجمالي التبرعات', '${state.totalDonationsCount} مرات', AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: _buildStatCard('أرواح ساهمت بإنقاذها', '${state.totalDonationsCount * 3} أفراد', AppColors.success),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.space5),

                  // Donation history list
                  Text(
                    'سجل التبرعات المكتملة:',
                    style: AppTypography.heading4(color: AppColors.slate900),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  if (state.donationHistory.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'لا يوجد سجل تبرعات سابق مسجل حتى الآن',
                          style: AppTypography.bodySmall(color: AppColors.textSubtle),
                        ),
                      ),
                    )
                  else
                    ...state.donationHistory.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.successSoft,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: const Center(
                                child: AppIcon(AppIcons.check, color: AppColors.success, size: 16),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.hospitalName ?? 'مستشفى معتمد',
                                    style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('yyyy/MM/dd • hh:mm a').format(item.createdAt),
                                    style: AppTypography.caption(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const MonqizBadge.emergency(label: 'مكتمل'),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.space6),

                  // Settings & Account Management Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
                          ),
                        ),
                        title: Text(
                          'إعدادات الحساب وتفضيلات التنبيهات',
                          style: AppTypography.bodyMedium(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'تعديل العنوان الجغرافي، الإشعارات، وإدارة مسح الحساب',
                          style: AppTypography.caption(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.slate700),
                        onTap: () => context.push('/settings'),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space8),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
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
          Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.space1),
          Text(
            value,
            style: AppTypography.heading3(color: color).copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
