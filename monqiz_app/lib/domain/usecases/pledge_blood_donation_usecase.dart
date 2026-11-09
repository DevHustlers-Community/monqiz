import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../entities/request_acceptance_entity.dart';
import '../entities/user_entity.dart';
import '../rules/eligibility_rules.dart';
import '../repositories/blood_request_repository.dart';

class PledgeBloodDonationUseCase {
  final BloodRequestRepository _repository;

  const PledgeBloodDonationUseCase(this._repository);

  Future<Result<RequestAcceptanceEntity>> call({
    required UserEntity donor,
    required String requestId,
  }) async {
    // Enforce clinical safety rules
    final eligibility = EligibilityRules.checkEligibility(donor);
    if (!eligibility.isEligible) {
      return Result.failure(EligibilityFailure(eligibility.statusMessage));
    }

    return await _repository.pledgeDonation(requestId: requestId);
  }
}
