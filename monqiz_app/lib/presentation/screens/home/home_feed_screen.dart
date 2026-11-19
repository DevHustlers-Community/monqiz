import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/enums.dart';
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

class _HomeFeedView extends StatefulWidget {
  const _HomeFeedView();

  @override
  State<_HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<_HomeFeedView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CaseFeedCubit>().loadMore();
    }
  }

  void _showFilterModal(BuildContext context, CaseFeedLoaded state) {
    final cubit = context.read<CaseFeedCubit>();
    String tempGov = state.activeGovernorate ?? 'الكل';
    BloodType? tempBlood = state.activeBloodFilter;
    final cityController = TextEditingController(text: state.activeCity ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.space5,
            left: AppSpacing.space5,
            right: AppSpacing.space5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.space6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تصفية طلبات التبرع', style: AppTypography.heading3(color: AppColors.slate900)),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        tempGov = 'الكل';
                        tempBlood = null;
                        cityController.clear();
                      });
                    },
                    child: const Text('إعادة ضبط'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),

              // Blood Type
              Text('فصيلة الدم المطلوبة', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.space2),
              Wrap(
                spacing: AppSpacing.space2,
                runSpacing: AppSpacing.space2,
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: tempBlood == null,
                    onSelected: (_) => setModalState(() => tempBlood = null),
                  ),
                  ...BloodType.values.where((b) => b != BloodType.unknown).map((b) {
                    return ChoiceChip(
                      label: Text(b.symbol),
                      selected: tempBlood == b,
                      onSelected: (_) => setModalState(() => tempBlood = b),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Governorate
              Text('المحافظة', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.space1),
              DropdownButtonFormField<String>(
                initialValue: CaseFilterHeader.governorates.contains(tempGov) ? tempGov : 'الكل',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
                ),
                items: CaseFilterHeader.governorates.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => tempGov = val);
                },
              ),
              const SizedBox(height: AppSpacing.space3),

              // City
              Text('المدينة أو الحي (اختياري)', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.space1),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'مثال: الدقي، مدينة نصر، المعادي',
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              MonqizButton(
                label: 'تطبيق التصفية',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final city = cityController.text.trim();
                  cubit.loadFeed(
                    bloodType: tempBlood,
                    governorate: tempGov,
                    city: city.isNotEmpty ? city : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  'شبكة استغاثات التبرع بالدم',
                  style: AppTypography.caption(color: AppColors.textSubtle),
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<CaseFeedCubit, CaseFeedState>(
            builder: (context, state) {
              if (state is CaseFeedLoaded) {
                return IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white, size: 22),
                  tooltip: 'تصفية الحالات',
                  onPressed: () => _showFilterModal(context, state),
                );
              }
              return const SizedBox.shrink();
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
              onRefresh: () => context.read<CaseFeedCubit>().loadFeed(
                    bloodType: state.activeBloodFilter,
                    governorate: state.activeGovernorate,
                    city: state.activeCity,
                  ),
              child: CustomScrollView(
                controller: _scrollController,
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
                      onGovernorateSelected: (g) => context.read<CaseFeedCubit>().filterByLocation(
                            governorate: g,
                            city: state.activeCity,
                          ),
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
                                bloodTypeSubtitle: request.bloodType.isRare ? 'فصيلة نادرة' : 'متطابق',
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

                  // Pagination loading indicator
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
