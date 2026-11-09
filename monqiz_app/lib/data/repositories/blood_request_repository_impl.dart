import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/blood_request_entity.dart';
import '../../domain/entities/request_acceptance_entity.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../datasources/blood_request_datasource.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  final BloodRequestDataSource _dataSource;

  const BloodRequestRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<BloodRequestEntity>>> getUrgentRequests({
    BloodType? bloodType,
    String? governorate,
  }) async {
    try {
      final models = await _dataSource.getUrgentRequests(
        bloodType: bloodType,
        governorate: governorate,
      );
      return Result.success(models);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BloodRequestEntity>> getRequestById(String id) async {
    try {
      final model = await _dataSource.getRequestById(id);
      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BloodRequestEntity>> createEmergencyRequest({
    required String hospitalId,
    required BloodType bloodType,
    required int unitsNeeded,
    DateTime? requiredDate,
    String? details,
    required String roomInfo,
    required String category,
  }) async {
    try {
      if (hospitalId.isEmpty) {
        return const Result.failure(ValidationFailure('يرجى تحديد المستشفى المشرف'));
      }
      if (unitsNeeded <= 0) {
        return const Result.failure(ValidationFailure('عدد الوحدات يجب أن يكون 1 على الأقل'));
      }

      final created = await _dataSource.createEmergencyRequest(
        hospitalId: hospitalId,
        bloodType: bloodType,
        unitsNeeded: unitsNeeded,
        requiredDate: requiredDate,
        details: details,
        roomInfo: roomInfo,
        category: category,
      );
      return Result.success(created);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<RequestAcceptanceEntity>> pledgeDonation({required String requestId}) async {
    try {
      final pledge = await _dataSource.pledgeDonation(requestId: requestId);
      return Result.success(pledge);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RequestAcceptanceEntity>>> getMyDonationHistory() async {
    try {
      final list = await _dataSource.getMyDonationHistory();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
