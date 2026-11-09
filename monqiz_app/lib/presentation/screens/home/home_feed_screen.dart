import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../cubits/feed/case_feed_cubit.dart';
import '../../cubits/feed/case_feed_state.dart';
import '../../widgets/monqiz_share_modal.dart';
import '../request_details/request_details_screen.dart';
import 'widgets/case_filter_header.dart';
import 'widgets/eligibility_banner_widget.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CaseFeedCubit>()..loadFeed(),
      child: const _HomeFeedView(),
    );
  }
}

class _HomeFeedView extends StatelessWidget {
  const _HomeFeedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        titleSpacing: AppSpacing.space4,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Center(
                child: AppIcon(AppIcons.droplet, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'منقذ • MONQIZ',
                  style: AppTypography.heading4(color: Colors.white).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'شبكة طوارئ التبرع بالدم المعتمدة',
                  style: AppTypography.caption(color: AppColors.textSubtle),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
            tooltip: 'الإعدادات ومسح الحساب',
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: BlocBuilder<CaseFeedCubit, CaseFeedState>(
        builder: (context, state) {
          if (state is CaseFeedLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CaseFeedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(AppIcons.circleExclamation, size: 48, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(color: AppColors.slate900),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    MonqizButton(
                      label: 'إعادة المحاولة',
                      icon: AppIcons.rotateRight,
                      onPressed: () => context.read<CaseFeedCubit>().loadFeed(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CaseFeedLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<CaseFeedCubit>().loadFeed(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // Eligibility banner
                  SliverToBoxAdapter(
                    child: EligibilityBannerWidget(eligibility: state.eligibility),
                  ),

                  // Filter Header
                  SliverToBoxAdapter(
                    child: CaseFilterHeader(
                      activeBloodFilter: state.activeBloodFilter,
                      activeGovernorate: state.activeGovernorate ?? 'الكل',
                      onBloodTypeSelected: (b) => context.read<CaseFeedCubit>().filterByBloodType(b),
                      onGovernorateSelected: (g) => context.read<CaseFeedCubit>().filterByGovernorate(g),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.space2),
                  ),

                  // Feed list or Empty
                  if (state.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: AppIcon(AppIcons.droplet, size: 28, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                'لا توجد حالات استغاثة مطابقة حالياً',
                                style: AppTypography.heading4(color: AppColors.slate900),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                'الحمد لله، لا توجد طلبات دم عاجلة في النطاق المختار.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall(color: AppColors.textSubtle),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = state.requests[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                              child: MonqizBloodRequestCard(
                                hospitalName: request.hospital.name,
                                category: request.category,
                                caseId: request.caseId,
                                roomInfo: request.roomInfo,
                                bloodType: request.bloodType.symbol,
                                bloodTypeSubtitle: request.bloodType.isRare ? 'نادر جداً' : 'متطابق',
                                remainingTime: request.remainingTimeFormatted,
                                distanceLocation: '${request.hospital.address.governorate} • ${request.hospital.address.city}',
                                currentUnits: request.unitsPledged,
                                totalUnits: request.unitsNeeded,
                                onPledge: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => RequestDetailsScreen(requestId: request.id, preloaded: request),
                                    ),
                                  );
                                },
                                onShare: () {
                                  MonqizShareModal.show(context, request);
                                },
                              ),
                            );
                          },
                          childCount: state.requests.length,
                        ),
                      ),
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
}
