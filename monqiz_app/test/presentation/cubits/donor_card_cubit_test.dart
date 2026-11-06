import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/repositories/auth_repository.dart';
import 'package:monqiz_app/domain/repositories/blood_request_repository.dart';
import 'package:monqiz_app/presentation/cubits/donor_card/donor_card_cubit.dart';
import 'package:monqiz_app/presentation/cubits/donor_card/donor_card_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockBloodRequestRepository extends Mock implements BloodRequestRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockBloodRequestRepository mockRequestRepo;
  late DonorCardCubit cubit;

  final testUser = UserEntity(
    id: 'user-01',
    firstName: 'أحمد',
    lastName: 'عمر',
    email: 'ahmed@monqiz.eg',
    phoneNumber: '01012345678',
    birthDate: DateTime(1996, 5, 14),
    gender: Gender.male,
    bloodType: BloodType.oNegative,
    status: UserStatus.active,
    lastDonationDate: DateTime.now().subtract(const Duration(days: 100)),
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockRequestRepo = MockBloodRequestRepository();
    cubit = DonorCardCubit(
      authRepository: mockAuthRepo,
      requestRepository: mockRequestRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<DonorCardCubit, DonorCardState>(
    'loadDonorCard emits [DonorCardLoading, DonorCardLoaded] with computed eligibility',
    build: () {
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => Result.success(testUser));
      when(() => mockRequestRepo.getMyDonationHistory())
          .thenAnswer((_) async => const Result.success([]));
      return cubit;
    },
    act: (cubit) => cubit.loadDonorCard(),
    expect: () => [
      const DonorCardLoading(),
      isA<DonorCardLoaded>()
          .having((s) => s.user.id, 'user id', 'user-01')
          .having((s) => s.eligibility.isEligible, 'eligible', isTrue),
    ],
  );
}
