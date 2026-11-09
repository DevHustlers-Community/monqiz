import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/failures.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/request_acceptance_entity.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/repositories/blood_request_repository.dart';
import 'package:monqiz_app/domain/usecases/pledge_blood_donation_usecase.dart';

class MockBloodRequestRepository extends Mock implements BloodRequestRepository {}

void main() {
  late MockBloodRequestRepository mockRepository;
  late PledgeBloodDonationUseCase useCase;

  setUp(() {
    mockRepository = MockBloodRequestRepository();
    useCase = PledgeBloodDonationUseCase(mockRepository);
  });

  final eligibleDonor = UserEntity(
    id: 'donor-1',
    firstName: 'أحمد',
    email: 'ahmed@test.com',
    phoneNumber: '01012345678',
    birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
    gender: Gender.male,
    bloodType: BloodType.oNegative,
    status: UserStatus.active,
    lastDonationDate: DateTime.now().subtract(const Duration(days: 100)),
  );

  final ineligibleDonor = UserEntity(
    id: 'donor-2',
    firstName: 'محمود',
    email: 'mahmoud@test.com',
    phoneNumber: '01012345679',
    birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
    gender: Gender.male,
    bloodType: BloodType.aPositive,
    status: UserStatus.active,
    lastDonationDate: DateTime.now().subtract(const Duration(days: 30)),
  );

  test('Fails pledge immediately if donor is medically ineligible without hitting repository', () async {
    final result = await useCase(donor: ineligibleDonor, requestId: 'req-1');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<EligibilityFailure>());
    verifyZeroInteractions(mockRepository);
  });

  test('Calls repository.pledgeDonation when donor is medically eligible', () async {
    final mockAcceptance = RequestAcceptanceEntity(
      userId: eligibleDonor.id,
      requestId: 'req-1',
      acceptanceStatus: DonationStatus.accepted,
      createdAt: DateTime.now(),
    );

    when(() => mockRepository.pledgeDonation(requestId: 'req-1'))
        .thenAnswer((_) async => Result.success(mockAcceptance));

    final result = await useCase(donor: eligibleDonor, requestId: 'req-1');

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.requestId, 'req-1');
    expect(result.dataOrNull?.acceptanceStatus, DonationStatus.accepted);
    verify(() => mockRepository.pledgeDonation(requestId: 'req-1')).called(1);
  });
}
