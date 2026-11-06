import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/address_entity.dart';
import 'package:monqiz_app/domain/entities/blood_request_entity.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/hospital_entity.dart';
import 'package:monqiz_app/domain/entities/request_acceptance_entity.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/repositories/auth_repository.dart';
import 'package:monqiz_app/domain/repositories/blood_request_repository.dart';
import 'package:monqiz_app/domain/usecases/pledge_blood_donation_usecase.dart';
import 'package:monqiz_app/presentation/cubits/request_details/request_details_cubit.dart';
import 'package:monqiz_app/presentation/cubits/request_details/request_details_state.dart';

class MockBloodRequestRepository extends Mock implements BloodRequestRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockPledgeUseCase extends Mock implements PledgeBloodDonationUseCase {}

void main() {
  late MockBloodRequestRepository mockRequestRepo;
  late MockAuthRepository mockAuthRepo;
  late MockPledgeUseCase mockPledgeUseCase;
  late RequestDetailsCubit cubit;

  final testHospital = const HospitalEntity(
    id: 'hosp-1',
    name: 'مستشفى 57357',
    phoneNumber: '19057',
    locationUrl: 'https://maps.google.com',
    email: 'info@57357.org',
    address: AddressEntity(id: 'a1', governorate: 'القاهرة', city: 'السيدة زينب'),
  );

  final testRequest = BloodRequestEntity(
    id: 'req-1',
    caseId: '#MQ-1001',
    creatorUserId: 'u1',
    hospital: testHospital,
    bloodType: BloodType.oNegative,
    unitsNeeded: 3,
    unitsPledged: 1,
    createdAt: DateTime.now(),
    status: RequestStatus.approved,
  );

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
    mockPledgeUseCase = MockPledgeUseCase();
    cubit = RequestDetailsCubit(
      requestRepository: mockRequestRepo,
      authRepository: mockAuthRepo,
      pledgeUseCase: mockPledgeUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<RequestDetailsCubit, RequestDetailsState>(
    'loadRequest emits [RequestDetailsLoading, RequestDetailsLoaded]',
    build: () {
      when(() => mockRequestRepo.getRequestById('req-1'))
          .thenAnswer((_) async => Result.success(testRequest));
      return cubit;
    },
    act: (cubit) => cubit.loadRequest('req-1'),
    expect: () => [
      const RequestDetailsLoading(),
      RequestDetailsLoaded(request: testRequest),
    ],
  );

  blocTest<RequestDetailsCubit, RequestDetailsState>(
    'pledgeDonation increments unitsPledged and updates confirmedPledge on success',
    build: () {
      final mockAcceptance = RequestAcceptanceEntity(
        userId: testUser.id,
        requestId: testRequest.id,
        acceptanceStatus: DonationStatus.accepted,
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => Result.success(testUser));
      when(() => mockPledgeUseCase(donor: testUser, requestId: testRequest.id))
          .thenAnswer((_) async => Result.success(mockAcceptance));

      return cubit;
    },
    seed: () => RequestDetailsLoaded(request: testRequest),
    act: (cubit) => cubit.pledgeDonation(),
    expect: () => [
      RequestDetailsLoaded(request: testRequest, isPledgeSubmitting: true),
      isA<RequestDetailsLoaded>()
          .having((s) => s.isPledgeSubmitting, 'submitting', isFalse)
          .having((s) => s.request.unitsPledged, 'pledged units', 2)
          .having((s) => s.confirmedPledge?.requestId, 'pledge request id', testRequest.id),
    ],
  );
}
