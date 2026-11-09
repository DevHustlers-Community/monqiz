import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> login({required String identifier, required String password}) async {
    try {
      if (identifier.isEmpty || password.isEmpty) {
        return const Result.failure(ValidationFailure('يرجى إدخال البريد/الهاتف وكلمة المرور'));
      }
      final user = await _dataSource.login(identifier: identifier, password: password);
      return Result.success(user);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String firstName,
    String? lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required DateTime birthDate,
    required Gender gender,
    required BloodType bloodType,
    DateTime? lastDonationDate,
    required String governorate,
    required String city,
  }) async {
    try {
      if (firstName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
        return const Result.failure(ValidationFailure('يرجى استكمال جميع البيانات الإلزامية'));
      }
      final user = await _dataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        birthDate: birthDate,
        gender: gender,
        bloodType: bloodType,
        lastDonationDate: lastDonationDate,
        governorate: governorate,
        city: city,
      );
      return Result.success(user);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.logout();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyOtp({required String phoneNumber, required String otpCode}) async {
    try {
      await _dataSource.verifyOtp(phoneNumber: phoneNumber, otpCode: otpCode);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset({required String phoneNumber}) async {
    try {
      await _dataSource.requestPasswordReset(phoneNumber: phoneNumber);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount({required String reason, String? password}) async {
    try {
      await _dataSource.deleteAccount(reason: reason, password: password);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfileAddress({
    required String governorate,
    required String city,
    String? street,
  }) async {
    try {
      if (governorate.isEmpty || city.isEmpty) {
        return const Result.failure(ValidationFailure('يرجى تحديد المحافظة والمدينة'));
      }
      final updatedUser = await _dataSource.updateAddress(
        governorate: governorate,
        city: city,
        street: street,
      );
      return Result.success(updatedUser);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  }) async {
    try {
      await _dataSource.updateNotificationPreferences(
        emergencyAlerts: emergencyAlerts,
        rareBloodAlerts: rareBloodAlerts,
        restReminderAlerts: restReminderAlerts,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
