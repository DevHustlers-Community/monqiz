import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/blood_request_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/blood_request_repository.dart';
import '../../../domain/usecases/pledge_blood_donation_usecase.dart';
import 'request_details_state.dart';

class RequestDetailsCubit extends Cubit<RequestDetailsState> {
  final BloodRequestRepository requestRepository;
  final AuthRepository authRepository;
  final PledgeBloodDonationUseCase pledgeUseCase;

  RequestDetailsCubit({
    required this.requestRepository,
    required this.authRepository,
    required this.pledgeUseCase,
  }) : super(const RequestDetailsInitial());

  Future<void> loadRequest(String id, {BloodRequestEntity? preloaded}) async {
    if (preloaded != null) {
      emit(RequestDetailsLoaded(request: preloaded));
      return;
    }

    emit(const RequestDetailsLoading());
    final result = await requestRepository.getRequestById(id);
    result.when(
      onSuccess: (req) => emit(RequestDetailsLoaded(request: req)),
      onFailure: (f) => emit(RequestDetailsError(f.message)),
    );
  }

  Future<void> pledgeDonation() async {
    if (state is! RequestDetailsLoaded) return;
    final current = state as RequestDetailsLoaded;

    emit(current.copyWith(isPledgeSubmitting: true, clearError: true));

    final userRes = await authRepository.getCurrentUser();
    final user = userRes.dataOrNull;
    if (user == null) {
      emit(current.copyWith(
        isPledgeSubmitting: false,
        errorMessage: 'يرجى تسجيل الدخول أولاً للتعهد بالتبرع',
      ));
      return;
    }

    final pledgeRes = await pledgeUseCase(
      donor: user,
      requestId: current.request.id,
    );

    pledgeRes.when(
      onSuccess: (pledge) {
        // Update request units pledged in-place
        final updatedRequest = current.request.copyWith(
          unitsPledged: current.request.unitsPledged + 1,
        );
        emit(current.copyWith(
          request: updatedRequest,
          isPledgeSubmitting: false,
          confirmedPledge: pledge,
        ));
      },
      onFailure: (f) {
        emit(current.copyWith(
          isPledgeSubmitting: false,
          errorMessage: f.message,
        ));
      },
    );
  }
}
