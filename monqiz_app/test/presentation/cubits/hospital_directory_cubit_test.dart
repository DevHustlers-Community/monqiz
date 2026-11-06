import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/failures.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/address_entity.dart';
import 'package:monqiz_app/domain/entities/hospital_entity.dart';
import 'package:monqiz_app/domain/repositories/hospital_repository.dart';
import 'package:monqiz_app/presentation/cubits/hospitals/hospital_directory_cubit.dart';
import 'package:monqiz_app/presentation/cubits/hospitals/hospital_directory_state.dart';

class MockHospitalRepository extends Mock implements HospitalRepository {}

void main() {
  late MockHospitalRepository mockRepository;
  late HospitalDirectoryCubit cubit;

  final testHospitals = [
    const HospitalEntity(
      id: 'hosp-1',
      name: 'مستشفى سرطان الأطفال 57357',
      phoneNumber: '19057',
      locationUrl: 'https://maps.google.com',
      email: 'info@57357.org',
      address: AddressEntity(id: 'a1', governorate: 'القاهرة', city: 'السيدة زينب'),
    ),
    const HospitalEntity(
      id: 'hosp-2',
      name: 'مستشفى قصر العيني الجامعي',
      phoneNumber: '0223654060',
      locationUrl: 'https://maps.google.com',
      email: 'info@kasralainy.eg',
      address: AddressEntity(id: 'a2', governorate: 'القاهرة', city: 'المنيل'),
    ),
  ];

  setUp(() {
    mockRepository = MockHospitalRepository();
    cubit = HospitalDirectoryCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is HospitalDirectoryInitial', () {
    expect(cubit.state, const HospitalDirectoryInitial());
  });

  blocTest<HospitalDirectoryCubit, HospitalDirectoryState>(
    'loadHospitals emits [HospitalDirectoryLoading, HospitalDirectoryLoaded] on success',
    build: () {
      when(() => mockRepository.getHospitals())
          .thenAnswer((_) async => Result.success(testHospitals));
      return cubit;
    },
    act: (cubit) => cubit.loadHospitals(),
    expect: () => [
      const HospitalDirectoryLoading(),
      HospitalDirectoryLoaded(hospitals: testHospitals),
    ],
  );

  blocTest<HospitalDirectoryCubit, HospitalDirectoryState>(
    'loadHospitals emits [HospitalDirectoryLoading, HospitalDirectoryError] on failure',
    build: () {
      when(() => mockRepository.getHospitals())
          .thenAnswer((_) async => const Result.failure(ServerFailure('حدث خطأ')));
      return cubit;
    },
    act: (cubit) => cubit.loadHospitals(),
    expect: () => [
      const HospitalDirectoryLoading(),
      const HospitalDirectoryError('حدث خطأ'),
    ],
  );
}
