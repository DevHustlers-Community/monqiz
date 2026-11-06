import '../../../core/config/app_config.dart';
import '../../../domain/entities/enums.dart';
import '../../models/address_model.dart';
import '../../models/blood_request_model.dart';
import '../../models/hospital_model.dart';
import '../../models/request_acceptance_model.dart';
import '../blood_request_datasource.dart';
import 'mock_hospital_datasource.dart';

class MockBloodRequestDataSource implements BloodRequestDataSource {
  final MockHospitalDataSource _hospitalDataSource = MockHospitalDataSource();

  static final List<BloodRequestModel> _mockRequests = [
    BloodRequestModel(
      id: 'req-001',
      caseId: '#MQ-8921',
      creatorUserId: 'user-001',
      hospital: const HospitalModel(
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
      bloodType: BloodType.oNegative,
      unitsNeeded: 3,
      unitsPledged: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      requiredDate: DateTime.now().add(const Duration(hours: 3)),
      category: 'عناية الأطفال المركزة • صفائح دموية',
      roomInfo: 'غرفة فرز المتبرعين 304',
      details: 'طفل في العناية المركزة يخضع لجراحة عاجلة وبحاجة إلى متبرعين فصيلة O- سالبة.',
    ),
    BloodRequestModel(
      id: 'req-002',
      caseId: '#MQ-8922',
      creatorUserId: 'user-002',
      hospital: const HospitalModel(
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
      bloodType: BloodType.aPositive,
      unitsNeeded: 4,
      unitsPledged: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      requiredDate: DateTime.now().add(const Duration(hours: 5)),
      category: 'طوارئ جراحة القلب المفتوح',
      roomInfo: 'مبنى الطوارئ الجديد - الدور الثاني',
      details: 'مريض يخضع لعملية قلب مفتوح طارئة.',
    ),
    BloodRequestModel(
      id: 'req-003',
      caseId: '#MQ-8923',
      creatorUserId: 'user-003',
      hospital: const HospitalModel(
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
      bloodType: BloodType.bPositive,
      unitsNeeded: 2,
      unitsPledged: 0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      requiredDate: DateTime.now().add(const Duration(hours: 8)),
      category: 'طوارئ الحوادث والكسور',
      roomInfo: 'بنك الدم - عيادة المتبرعين',
      details: 'حالة حادث مروري تحتاج لنقل دم سريع.',
    ),
    BloodRequestModel(
      id: 'req-004',
      caseId: '#MQ-8924',
      creatorUserId: 'user-004',
      hospital: const HospitalModel(
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
      bloodType: BloodType.abNegative,
      unitsNeeded: 2,
      unitsPledged: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      requiredDate: DateTime.now().add(const Duration(hours: 12)),
      category: 'أمراض الدم والغسيل الكلوي',
      roomInfo: 'وحدة أمراض الدم - بنك الدم',
      details: 'فصيلة نادرة جداً لمريضة تعاني من فقر دم حاد.',
    ),
  ];

  static final List<RequestAcceptanceModel> _mockDonationHistory = [
    RequestAcceptanceModel(
      userId: 'user-current',
      requestId: 'req-past-01',
      acceptanceStatus: DonationStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 105)),
      hospitalName: 'مستشفى سرطان الأطفال 57357',
      bloodType: BloodType.oNegative,
    ),
    RequestAcceptanceModel(
      userId: 'user-current',
      requestId: 'req-past-02',
      acceptanceStatus: DonationStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 220)),
      hospitalName: 'مستشفيات جامعة القاهرة (قصر العيني)',
      bloodType: BloodType.oNegative,
    ),
  ];

  @override
  Future<List<BloodRequestModel>> getUrgentRequests({BloodType? bloodType, String? governorate}) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));

    var results = List<BloodRequestModel>.from(_mockRequests);

    if (bloodType != null && bloodType != BloodType.unknown) {
      results = results.where((r) => r.bloodType == bloodType).toList();
    }

    if (governorate != null && governorate.isNotEmpty && governorate != 'الكل' && !governorate.contains('الكل')) {
      results = results.where((r) => r.hospital.address.governorate.contains(governorate) || governorate.contains(r.hospital.address.governorate)).toList();
    }

    return results;
  }

  @override
  Future<BloodRequestModel> getRequestById(String id) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    return _mockRequests.firstWhere(
      (r) => r.id == id,
      orElse: () => _mockRequests.first,
    );
  }

  @override
  Future<BloodRequestModel> createEmergencyRequest({
    required String hospitalId,
    required BloodType bloodType,
    required int unitsNeeded,
    DateTime? requiredDate,
    String? details,
    required String roomInfo,
    required String category,
  }) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));

    final hospital = await _hospitalDataSource.getHospitalById(hospitalId);
    final newId = 'req-${DateTime.now().millisecondsSinceEpoch}';
    final caseNum = (8925 + _mockRequests.length).toString();

    final newRequest = BloodRequestModel(
      id: newId,
      caseId: '#MQ-$caseNum',
      creatorUserId: 'user-current',
      hospital: hospital,
      bloodType: bloodType,
      unitsNeeded: unitsNeeded,
      unitsPledged: 0,
      createdAt: DateTime.now(),
      requiredDate: requiredDate ?? DateTime.now().add(const Duration(hours: 6)),
      status: RequestStatus.approved,
      details: details,
      roomInfo: roomInfo,
      category: category,
    );

    _mockRequests.insert(0, newRequest);
    return newRequest;
  }

  @override
  Future<RequestAcceptanceModel> pledgeDonation({required String requestId}) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));

    final index = _mockRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _mockRequests[index];
      _mockRequests[index] = BloodRequestModel(
        id: req.id,
        caseId: req.caseId,
        creatorUserId: req.creatorUserId,
        hospital: req.hospital is HospitalModel
            ? req.hospital as HospitalModel
            : HospitalModel(
                id: req.hospital.id,
                name: req.hospital.name,
                phoneNumber: req.hospital.phoneNumber,
                locationUrl: req.hospital.locationUrl,
                email: req.hospital.email,
                address: AddressModel(
                  id: req.hospital.address.id,
                  governorate: req.hospital.address.governorate,
                  city: req.hospital.address.city,
                ),
              ),
        bloodType: req.bloodType,
        unitsNeeded: req.unitsNeeded,
        unitsPledged: req.unitsPledged + 1,
        createdAt: req.createdAt,
        requiredDate: req.requiredDate,
        status: req.status,
        details: req.details,
        roomInfo: req.roomInfo,
        category: req.category,
      );
    }

    final pledge = RequestAcceptanceModel(
      userId: 'user-current',
      requestId: requestId,
      acceptanceStatus: DonationStatus.accepted,
      createdAt: DateTime.now(),
      hospitalName: index != -1 ? _mockRequests[index].hospital.name : 'مستشفى معتمد',
      bloodType: index != -1 ? _mockRequests[index].bloodType : BloodType.oNegative,
    );

    _mockDonationHistory.insert(0, pledge);
    return pledge;
  }

  @override
  Future<List<RequestAcceptanceModel>> getMyDonationHistory() async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    return List<RequestAcceptanceModel>.from(_mockDonationHistory);
  }
}
