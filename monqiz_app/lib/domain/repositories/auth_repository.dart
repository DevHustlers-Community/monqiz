import '../../core/error/result.dart';
import '../entities/enums.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> getCurrentUser();
  Future<Result<UserEntity>> login({required String identifier, required String password});
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
  });
  Future<Result<void>> logout();
  Future<Result<void>> verifyOtp({required String phoneNumber, required String otpCode});
  Future<Result<void>> requestPasswordReset({required String phoneNumber});
  Future<Result<void>> deleteAccount({required String reason, String? password});
  Future<Result<UserEntity>> updateProfileAddress({
    required String governorate,
    required String city,
    String? street,
  });
  Future<Result<void>> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  });
}
