import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/domain/entities/address_entity.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/hospital_entity.dart';
import 'package:monqiz_app/domain/repositories/blood_request_repository.dart';
import 'package:monqiz_app/presentation/cubits/create_request/create_request_cubit.dart';
import 'package:monqiz_app/presentation/cubits/create_request/create_request_state.dart';

class MockBloodRequestRepository extends Mock implements BloodRequestRepository {}

void main() {
  late MockBloodRequestRepository mockRepository;
  late CreateRequestCubit cubit;

  final testHospital = const HospitalEntity(
    id: 'hosp-1',
    name: 'مستشفى 57357',
    phoneNumber: '19057',
    locationUrl: 'https://maps.google.com',
    email: 'info@57357.org',
    address: AddressEntity(id: 'a1', governorate: 'القاهرة', city: 'السيدة زينب'),
  );

  setUp(() {
    mockRepository = MockBloodRequestRepository();
    cubit = CreateRequestCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state has step 0, unitsNeeded 1, and BloodType.oPositive', () {
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.unitsNeeded, 1);
    expect(cubit.state.selectedBloodType, BloodType.oPositive);
  });

  blocTest<CreateRequestCubit, CreateRequestState>(
    'updateUnitsNeeded updates units count',
    build: () => cubit,
    act: (cubit) => cubit.updateUnitsNeeded(3),
    expect: () => [
      const CreateRequestState(unitsNeeded: 3),
    ],
  );

  blocTest<CreateRequestCubit, CreateRequestState>(
    'nextStep advances wizard step when valid',
    build: () => cubit,
    act: (cubit) {
      cubit.updateBloodType(BloodType.aNegative);
      cubit.nextStep();
    },
    expect: () => [
      const CreateRequestState(selectedBloodType: BloodType.aNegative),
      const CreateRequestState(selectedBloodType: BloodType.aNegative, currentStep: 1),
    ],
  );

  blocTest<CreateRequestCubit, CreateRequestState>(
    'nextStep fails at step 1 if no hospital selected',
    build: () => cubit,
    seed: () => const CreateRequestState(currentStep: 1),
    act: (cubit) => cubit.nextStep(),
    expect: () => [
      const CreateRequestState(
        currentStep: 1,
        errorMessage: 'يرجى اختيار المستشفى المشرف على الحالة',
      ),
    ],
  );

  blocTest<CreateRequestCubit, CreateRequestState>(
    'nextStep advances to step 2 when hospital is selected',
    build: () => cubit,
    seed: () => CreateRequestState(currentStep: 1, selectedHospital: testHospital),
    act: (cubit) => cubit.nextStep(),
    expect: () => [
      CreateRequestState(currentStep: 2, selectedHospital: testHospital),
    ],
  );
}
