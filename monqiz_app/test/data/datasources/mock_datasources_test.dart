import 'package:flutter_test/flutter_test.dart';
import 'package:monqiz_app/data/datasources/mock/mock_auth_datasource.dart';
import 'package:monqiz_app/data/datasources/mock/mock_blood_request_datasource.dart';
import 'package:monqiz_app/data/datasources/mock/mock_hospital_datasource.dart';
import 'package:monqiz_app/domain/entities/enums.dart';

void main() {
  group('Mock Data Sources Integration Tests', () {
    late MockAuthDataSource authDataSource;
    late MockBloodRequestDataSource requestDataSource;
    late MockHospitalDataSource hospitalDataSource;

    setUp(() {
      authDataSource = MockAuthDataSource();
      requestDataSource = MockBloodRequestDataSource();
      hospitalDataSource = MockHospitalDataSource();
    });

    test('MockHospitalDataSource returns populated hospital directory with coordinates and governorates', () async {
      final hospitals = await hospitalDataSource.getHospitals();
      expect(hospitals.isNotEmpty, isTrue);
      expect(hospitals.any((h) => h.name.contains('57357')), isTrue);
      expect(hospitals.any((h) => h.name.contains('قصر العيني')), isTrue);
    });

    test('MockHospitalDataSource filters by governorate correctly', () async {
      final alexHospitals = await hospitalDataSource.getHospitals(governorate: 'الإسكندرية');
      expect(alexHospitals.every((h) => h.address.governorate == 'الإسكندرية'), isTrue);
    });

    test('MockBloodRequestDataSource returns active urgent requests', () async {
      final requests = await requestDataSource.getUrgentRequests();
      expect(requests.isNotEmpty, isTrue);
      expect(requests.first.hospital.name.isNotEmpty, isTrue);
      expect(requests.first.unitsNeeded > 0, isTrue);
    });

    test('MockBloodRequestDataSource filters by blood type', () async {
      final oNegRequests = await requestDataSource.getUrgentRequests(bloodType: BloodType.oNegative);
      expect(oNegRequests.every((r) => r.bloodType == BloodType.oNegative), isTrue);
    });

    test('MockBloodRequestDataSource creates and persists new emergency request', () async {
      final created = await requestDataSource.createEmergencyRequest(
        hospitalId: 'hosp-001',
        bloodType: BloodType.abPositive,
        unitsNeeded: 2,
        requiredDate: DateTime.now().add(const Duration(hours: 6)),
        details: 'حالة جراحة قلب مفتوح طارئة',
        roomInfo: 'الدور الثالث - رعاية مركزة',
        category: 'جراحة حرجة',
      );

      expect(created.id.isNotEmpty, isTrue);
      expect(created.caseId, startsWith('#MQ-'));
      expect(created.bloodType, BloodType.abPositive);

      final fetched = await requestDataSource.getRequestById(created.id);
      expect(fetched.id, created.id);
    });

    test('MockBloodRequestDataSource pledges donation and increments count', () async {
      final before = await requestDataSource.getRequestById('req-001');
      final initialPledged = before.unitsPledged;

      final acceptance = await requestDataSource.pledgeDonation(requestId: 'req-001');
      expect(acceptance.requestId, 'req-001');

      final after = await requestDataSource.getRequestById('req-001');
      expect(after.unitsPledged, initialPledged + 1);
    });

    test('MockAuthDataSource login succeeds with valid user', () async {
      final user = await authDataSource.login(
        identifier: '01012345678',
        password: 'Password123*',
      );
      expect(user.phoneNumber, '01012345678');
      expect(user.firstName, 'أحمد');
      expect(user.bloodType, BloodType.oNegative);
    });
  });
}
