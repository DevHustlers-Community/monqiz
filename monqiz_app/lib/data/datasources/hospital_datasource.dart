import '../models/hospital_model.dart';

abstract class HospitalDataSource {
  Future<List<HospitalModel>> getHospitals({
    String? query,
    String? governorate,
  });
  Future<HospitalModel> getHospitalById(String id);
}
