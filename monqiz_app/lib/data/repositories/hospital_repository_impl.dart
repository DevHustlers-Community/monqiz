import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/hospital_datasource.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalDataSource _dataSource;

  const HospitalRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<HospitalEntity>>> getHospitals({
    String? query,
    String? governorate,
  }) async {
    try {
      final list = await _dataSource.getHospitals(query: query, governorate: governorate);
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<HospitalEntity>> getHospitalById(String id) async {
    try {
      final hospital = await _dataSource.getHospitalById(id);
      return Result.success(hospital);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
