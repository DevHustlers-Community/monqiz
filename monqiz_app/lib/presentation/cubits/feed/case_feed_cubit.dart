import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/blood_request_repository.dart';
import '../../../domain/rules/eligibility_rules.dart';
import 'case_feed_state.dart';

class CaseFeedCubit extends Cubit<CaseFeedState> {
  final BloodRequestRepository requestRepository;
  final AuthRepository authRepository;

  CaseFeedCubit({
    required this.requestRepository,
    required this.authRepository,
  }) : super(const CaseFeedInitial());

  Future<void> loadFeed({
    BloodType? bloodType,
    String? governorate,
    String? city,
  }) async {
    emit(const CaseFeedLoading());

    // 1. Get current donor eligibility
    final userResult = await authRepository.getCurrentUser();
    final user = userResult.dataOrNull;
    final eligibility = user != null
        ? EligibilityRules.checkEligibility(user)
        : const EligibilityResult(
            isEligible: true,
            daysRemaining: 0,
            statusMessage: 'سجل دخولك لتتبع أهليتك الطبية للتبرع',
            recoveryProgress: 1.0,
          );

    // 2. Fetch active requests (page 1)
    final result = await requestRepository.getUrgentRequests(
      bloodType: bloodType,
      governorate: governorate != 'الكل' ? governorate : null,
      city: city != 'الكل' ? city : null,
      page: 1,
    );

    result.when(
      onSuccess: (requests) {
        emit(CaseFeedLoaded(
          requests: requests,
          activeBloodFilter: bloodType,
          activeGovernorate: governorate ?? 'الكل',
          activeCity: city,
          eligibility: eligibility,
          currentPage: 1,
          hasMore: requests.length >= 10,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! CaseFeedLoaded || current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;

    final result = await requestRepository.getUrgentRequests(
      bloodType: current.activeBloodFilter,
      governorate: current.activeGovernorate != 'الكل' ? current.activeGovernorate : null,
      city: current.activeCity != 'الكل' ? current.activeCity : null,
      page: nextPage,
    );

    result.when(
      onSuccess: (newRequests) {
        if (newRequests.isEmpty) {
          emit(current.copyWith(hasMore: false, isLoadingMore: false));
        } else {
          final updatedList = List.of(current.requests)..addAll(newRequests);
          emit(current.copyWith(
            requests: updatedList,
            currentPage: nextPage,
            hasMore: newRequests.length >= 10,
            isLoadingMore: false,
          ));
        }
      },
      onFailure: (_) {
        emit(current.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<void> filterByBloodType(BloodType? bloodType) async {
    final current = state;
    if (current is! CaseFeedLoaded) return;

    final effectiveBlood = current.activeBloodFilter == bloodType ? null : bloodType;

    final result = await requestRepository.getUrgentRequests(
      bloodType: effectiveBlood,
      governorate: current.activeGovernorate != 'الكل' ? current.activeGovernorate : null,
      city: current.activeCity != 'الكل' ? current.activeCity : null,
      page: 1,
    );

    result.when(
      onSuccess: (requests) {
        emit(current.copyWith(
          requests: requests,
          activeBloodFilter: effectiveBlood,
          clearBloodFilter: effectiveBlood == null,
          currentPage: 1,
          hasMore: requests.length >= 10,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }

  Future<void> filterByLocation({String? governorate, String? city}) async {
    final current = state;
    if (current is! CaseFeedLoaded) return;

    final result = await requestRepository.getUrgentRequests(
      bloodType: current.activeBloodFilter,
      governorate: governorate != 'الكل' ? governorate : null,
      city: city != 'الكل' ? city : null,
      page: 1,
    );

    result.when(
      onSuccess: (requests) {
        emit(current.copyWith(
          requests: requests,
          activeGovernorate: governorate,
          activeCity: city,
          clearCity: city == null || city == 'الكل',
          currentPage: 1,
          hasMore: requests.length >= 10,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }
}
