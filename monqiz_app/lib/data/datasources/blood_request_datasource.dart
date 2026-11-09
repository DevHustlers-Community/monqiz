import '../../domain/entities/enums.dart';
import '../models/blood_request_model.dart';
import '../models/request_acceptance_model.dart';

abstract class BloodRequestDataSource {
  Future<List<BloodRequestModel>> getUrgentRequests({
    BloodType? bloodType,
    String? governorate,
  });
  Future<BloodRequestModel> getRequestById(String id);
  Future<BloodRequestModel> createEmergencyRequest({
    required String hospitalId,
    required BloodType bloodType,
    required int unitsNeeded,
    DateTime? requiredDate,
    String? details,
    required String roomInfo,
    required String category,
  });
  Future<RequestAcceptanceModel> pledgeDonation({required String requestId});
  Future<List<RequestAcceptanceModel>> getMyDonationHistory();
}
