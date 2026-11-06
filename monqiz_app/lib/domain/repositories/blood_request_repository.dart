import '../../core/error/result.dart';
import '../entities/enums.dart';
import '../entities/blood_request_entity.dart';
import '../entities/request_acceptance_entity.dart';

abstract class BloodRequestRepository {
  Future<Result<List<BloodRequestEntity>>> getUrgentRequests({
    BloodType? bloodType,
    String? governorate,
  });
  Future<Result<BloodRequestEntity>> getRequestById(String id);
  Future<Result<BloodRequestEntity>> createEmergencyRequest({
    required String hospitalId,
    required BloodType bloodType,
    required int unitsNeeded,
    DateTime? requiredDate,
    String? details,
    required String roomInfo,
    required String category,
  });
  Future<Result<RequestAcceptanceEntity>> pledgeDonation({
    required String requestId,
  });
  Future<Result<List<RequestAcceptanceEntity>>> getMyDonationHistory();
}
