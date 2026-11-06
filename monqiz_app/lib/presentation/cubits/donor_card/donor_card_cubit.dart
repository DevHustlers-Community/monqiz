import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/blood_request_repository.dart';
import '../../../domain/rules/eligibility_rules.dart';
import 'donor_card_state.dart';

class DonorCardCubit extends Cubit<DonorCardState> {
  final AuthRepository authRepository;
  final BloodRequestRepository requestRepository;

  DonorCardCubit({
    required this.authRepository,
    required this.requestRepository,
  }) : super(const DonorCardInitial());

  Future<void> loadDonorCard() async {
    emit(const DonorCardLoading());

    final userRes = await authRepository.getCurrentUser();
    if (userRes.isFailure) {
      emit(DonorCardError(userRes.failureOrNull?.message ?? 'فشل في تحميل بيانات المتبرع'));
      return;
    }

    final user = userRes.dataOrNull!;
    final eligibility = EligibilityRules.checkEligibility(user);

    final historyRes = await requestRepository.getMyDonationHistory();
    final history = historyRes.dataOrNull ?? [];

    emit(DonorCardLoaded(
      user: user,
      eligibility: eligibility,
      donationHistory: history,
    ));
  }
}
