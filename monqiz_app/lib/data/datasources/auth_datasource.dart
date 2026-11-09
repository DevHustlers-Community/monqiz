import '../models/user_model.dart';
import '../../domain/entities/enums.dart';

abstract class AuthDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> login({required String identifier, required String password});
  Future<UserModel> register({
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
  Future<void> logout();
  Future<void> verifyOtp({required String phoneNumber, required String otpCode});
  Future<void> requestPasswordReset({required String phoneNumber});
  Future<void> deleteAccount({required String reason, String? password});
  Future<UserModel> updateAddress({
    required String governorate,
    required String city,
    String? street,
  });
  Future<void> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  });
}
