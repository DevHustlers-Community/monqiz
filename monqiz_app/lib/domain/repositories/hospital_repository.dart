import '../../core/error/result.dart';
import '../entities/hospital_entity.dart';

abstract class HospitalRepository {
  Future<Result<List<HospitalEntity>>> getHospitals({
    String? query,
    String? governorate,
  });
  Future<Result<HospitalEntity>> getHospitalById(String id);
}
