import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/address_entity.dart';
import 'package:monqiz_app/domain/entities/blood_request_entity.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/hospital_entity.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/repositories/auth_repository.dart';
import 'package:monqiz_app/domain/repositories/blood_request_repository.dart';
import 'package:monqiz_app/presentation/cubits/feed/case_feed_cubit.dart';
import 'package:monqiz_app/presentation/cubits/feed/case_feed_state.dart';

class MockBloodRequestRepository extends Mock implements BloodRequestRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockBloodRequestRepository mockRequestRepo;
  late MockAuthRepository mockAuthRepo;
  late CaseFeedCubit cubit;

  final testHospital = const HospitalEntity(
    id: 'hosp-1',
    name: 'مستشفى 57357',
    phoneNumber: '19057',
    locationUrl: 'https://maps.google.com',
    email: 'info@57357.org',
    address: AddressEntity(id: 'a1', governorate: 'القاهرة', city: 'السيدة زينب'),
  );

  final testRequests = [
    BloodRequestEntity(
      id: 'req-1',
      caseId: '#MQ-1001',
      creatorUserId: 'u1',
      hospital: testHospital,
      bloodType: BloodType.oNegative,
      unitsNeeded: 3,
      unitsPledged: 1,
      createdAt: DateTime.now(),
      status: RequestStatus.approved,
    ),
  ];

  final testUser = UserEntity(
    id: 'user-01',
    firstName: 'أحمد',
    email: 'ahmed@monqiz.eg',
    phoneNumber: '01012345678',
    birthDate: DateTime(1996, 5, 14),
    gender: Gender.male,
    bloodType: BloodType.oNegative,
    status: UserStatus.active,
  );

  setUp(() {
    mockRequestRepo = MockBloodRequestRepository();
    mockAuthRepo = MockAuthRepository();
    cubit = CaseFeedCubit(
      requestRepository: mockRequestRepo,
      authRepository: mockAuthRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is CaseFeedInitial', () {
    expect(cubit.state, const CaseFeedInitial());
  });

  blocTest<CaseFeedCubit, CaseFeedState>(
    'loadFeed emits [CaseFeedLoading, CaseFeedLoaded] with active emergency requests',
    build: () {
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => Result.success(testUser));
      when(() => mockRequestRepo.getUrgentRequests())
          .thenAnswer((_) async => Result.success(testRequests));
      return cubit;
    },
    act: (cubit) => cubit.loadFeed(),
    expect: () => [
      const CaseFeedLoading(),
      isA<CaseFeedLoaded>()
          .having((s) => s.requests.length, 'requests count', 1)
          .having((s) => s.eligibility.isEligible, 'eligibility', isTrue),
    ],
  );
}
