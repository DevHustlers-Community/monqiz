import '../../../core/config/app_config.dart';
import '../../models/address_model.dart';
import '../../models/hospital_model.dart';
import '../hospital_datasource.dart';

class MockHospitalDataSource implements HospitalDataSource {
  static final List<HospitalModel> _mockHospitals = [
    const HospitalModel(
      id: 'hosp-001',
      name: 'مستشفى سرطان الأطفال 57357',
      phoneNumber: '19057',
      locationUrl: 'https://maps.google.com/?q=30.0215,31.2366',
      email: 'bloodbank@57357.org',
      address: AddressModel(
        id: 'addr-001',
        governorate: 'القاهرة',
        city: 'السيدة زينب',
      ),
    ),
    const HospitalModel(
      id: 'hosp-002',
      name: 'مستشفيات جامعة القاهرة (قصر العيني)',
      phoneNumber: '0223654000',
      locationUrl: 'https://maps.google.com/?q=30.0305,31.2289',
      email: 'bloodbank@kasralainy.edu.eg',
      address: AddressModel(
        id: 'addr-002',
        governorate: 'القاهرة',
        city: 'المنيل',
      ),
    ),
    const HospitalModel(
      id: 'hosp-003',
      name: 'مستشفى عين شمس التخصصي',
      phoneNumber: '0224024222',
      locationUrl: 'https://maps.google.com/?q=30.0768,31.2854',
      email: 'info@asuh.edu.eg',
      address: AddressModel(
        id: 'addr-003',
        governorate: 'القاهرة',
        city: 'مدينة نصر',
      ),
    ),
    const HospitalModel(
      id: 'hosp-004',
      name: 'مستشفى الجلاء العسكري',
      phoneNumber: '0222687111',
      locationUrl: 'https://maps.google.com/?q=30.0984,31.3325',
      email: 'galaa@mod.gov.eg',
      address: AddressModel(
        id: 'addr-004',
        governorate: 'القاهرة',
        city: 'مصر الجديدة',
      ),
    ),
    const HospitalModel(
      id: 'hosp-005',
      name: 'المستشفى الميري الجامعي بالإسكندرية',
      phoneNumber: '034862244',
      locationUrl: 'https://maps.google.com/?q=31.1985,29.9056',
      email: 'bloodbank@alexmed.edu.eg',
      address: AddressModel(
        id: 'addr-005',
        governorate: 'الإسكندرية',
        city: 'الشاطبي',
      ),
    ),
    const HospitalModel(
      id: 'hosp-006',
      name: 'مستشفى الطوارئ الجامعي بالمنصورة',
      phoneNumber: '0502202600',
      locationUrl: 'https://maps.google.com/?q=31.0409,31.3785',
      email: 'emergency@mans.edu.eg',
      address: AddressModel(
        id: 'addr-006',
        governorate: 'الدقهلية',
        city: 'المنصورة',
      ),
    ),
  ];

  @override
  Future<List<HospitalModel>> getHospitals({String? query, String? governorate}) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));

    var results = List<HospitalModel>.from(_mockHospitals);

    if (governorate != null && governorate.isNotEmpty && governorate != 'الكل') {
      results = results.where((h) => h.address.governorate == governorate).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((h) => h.name.toLowerCase().contains(q) || h.address.city.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  @override
  Future<HospitalModel> getHospitalById(String id) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    return _mockHospitals.firstWhere(
      (h) => h.id == id,
      orElse: () => _mockHospitals.first,
    );
  }
}
