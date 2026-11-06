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

  Future<void> loadFeed() async {
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

    // 2. Fetch active requests
    final result = await requestRepository.getUrgentRequests();
    result.when(
      onSuccess: (requests) {
        emit(CaseFeedLoaded(
          requests: requests,
          activeBloodFilter: null,
          activeGovernorate: 'الكل',
          eligibility: eligibility,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }

  Future<void> filterByBloodType(BloodType? bloodType) async {
    if (state is! CaseFeedLoaded) return;
    final current = state as CaseFeedLoaded;

    final result = await requestRepository.getUrgentRequests(
      bloodType: bloodType,
      governorate: current.activeGovernorate,
    );

    result.when(
      onSuccess: (requests) {
        emit(current.copyWith(
          requests: requests,
          activeBloodFilter: bloodType,
          clearBloodFilter: bloodType == null,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }

  Future<void> filterByGovernorate(String? governorate) async {
    if (state is! CaseFeedLoaded) return;
    final current = state as CaseFeedLoaded;

    final result = await requestRepository.getUrgentRequests(
      bloodType: current.activeBloodFilter,
      governorate: governorate,
    );

    result.when(
      onSuccess: (requests) {
        emit(current.copyWith(
          requests: requests,
          activeGovernorate: governorate,
        ));
      },
      onFailure: (failure) {
        emit(CaseFeedError(failure.message));
      },
    );
  }
}
