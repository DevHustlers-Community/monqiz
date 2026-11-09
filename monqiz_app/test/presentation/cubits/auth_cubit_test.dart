import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monqiz_app/core/error/failures.dart';
import 'package:monqiz_app/core/error/result.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/repositories/auth_repository.dart';
import 'package:monqiz_app/presentation/cubits/auth/auth_cubit.dart';
import 'package:monqiz_app/presentation/cubits/auth/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthCubit cubit;

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
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    cubit = AuthCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is AuthInitial', () {
    expect(cubit.state, const AuthInitial());
  });

  blocTest<AuthCubit, AuthState>(
    'checkAuthStatus emits [AuthLoading, Authenticated] when user is logged in',
    build: () {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Result.success(testUser));
      return cubit;
    },
    act: (cubit) => cubit.checkAuthStatus(),
    expect: () => [
      const AuthLoading(),
      Authenticated(testUser),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'checkAuthStatus emits [AuthLoading, Unauthenticated] when no session exists',
    build: () {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(AuthFailure('No token')));
      return cubit;
    },
    act: (cubit) => cubit.checkAuthStatus(),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'login emits [AuthLoading, Authenticated] on valid credentials',
    build: () {
      when(() => mockRepository.login(
            identifier: '01012345678',
            password: 'Password123*',
          )).thenAnswer((_) async => Result.success(testUser));
      return cubit;
    },
    act: (cubit) => cubit.login(identifier: '01012345678', password: 'Password123*'),
    expect: () => [
      const AuthLoading(),
      Authenticated(testUser),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'login emits [AuthLoading, AuthError] on failed credentials',
    build: () {
      when(() => mockRepository.login(
            identifier: '01012345678',
            password: 'wrong',
          )).thenAnswer((_) async => const Result.failure(AuthFailure('بيانات غير صحيحة')));
      return cubit;
    },
    act: (cubit) => cubit.login(identifier: '01012345678', password: 'wrong'),
    expect: () => [
      const AuthLoading(),
      const AuthError('بيانات غير صحيحة'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'logout emits [AuthLoading, Unauthenticated]',
    build: () {
      when(() => mockRepository.logout()).thenAnswer((_) async => const Result.success(null));
      return cubit;
    },
    act: (cubit) => cubit.logout(),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'requestPasswordReset emits [AuthLoading, AuthPasswordResetSent]',
    build: () {
      when(() => mockRepository.requestPasswordReset(phoneNumber: '01012345678'))
          .thenAnswer((_) async => const Result.success(null));
      return cubit;
    },
    act: (cubit) => cubit.requestPasswordReset('01012345678'),
    expect: () => [
      const AuthLoading(),
      const AuthPasswordResetSent('تم إرسال رمز استعادة الحساب بنجاح'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'deleteAccount emits [AuthLoading, AccountDeleted, Unauthenticated] on success',
    build: () {
      when(() => mockRepository.deleteAccount(reason: 'ظروف صحية'))
          .thenAnswer((_) async => const Result.success(null));
      return cubit;
    },
    act: (cubit) => cubit.deleteAccount(reason: 'ظروف صحية'),
    expect: () => [
      const AuthLoading(),
      const AccountDeleted('تم مسح الحساب وسجل التبرعات نهائياً بنجاح'),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'updateAddress emits [AuthLoading, ProfileUpdated] on success',
    build: () {
      when(() => mockRepository.updateProfileAddress(
            governorate: 'الجيزة',
            city: 'الدقي',
            street: null,
          )).thenAnswer((_) async => Result.success(testUser));
      return cubit;
    },
    act: (cubit) => cubit.updateAddress(governorate: 'الجيزة', city: 'الدقي'),
    expect: () => [
      const AuthLoading(),
      ProfileUpdated(testUser, 'تم تحديث العنوان الجغرافي بنجاح'),
    ],
  );
}
