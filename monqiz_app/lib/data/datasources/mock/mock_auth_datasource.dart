import '../../../core/config/app_config.dart';
import '../../../domain/entities/enums.dart';
import '../../models/address_model.dart';
import '../../models/user_model.dart';
import '../auth_datasource.dart';

class MockAuthDataSource implements AuthDataSource {
  static UserModel _currentUser = UserModel(
    id: 'user-current',
    firstName: 'أحمد',
    lastName: 'عمر',
    email: 'ahmed.omar@monqiz.eg',
    phoneNumber: '01012345678',
    birthDate: DateTime(1996, 5, 14),
    lastDonationDate: DateTime.now().subtract(const Duration(days: 105)), // Eligible (>90 days)
    gender: Gender.male,
    bloodType: BloodType.oNegative,
    status: UserStatus.active,
    preferredAddresses: const [
      AddressModel(id: 'addr-001', governorate: 'القاهرة', city: 'السيدة زينب'),
      AddressModel(id: 'addr-002', governorate: 'الجيزة', city: 'الدقي'),
    ],
  );

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<UserModel> login({required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    return _currentUser;
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    _currentUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      gender: gender,
      bloodType: bloodType,
      lastDonationDate: lastDonationDate,
      status: UserStatus.active,
      preferredAddresses: [
        AddressModel(id: 'addr-reg', governorate: governorate, city: city),
      ],
    );
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> verifyOtp({required String phoneNumber, required String otpCode}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> requestPasswordReset({required String phoneNumber}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> deleteAccount({required String reason, String? password}) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    // Soft/Hard delete user from mock store
    _currentUser = UserModel(
      id: 'deleted-user',
      firstName: 'مستخدم',
      lastName: 'محذوف',
      email: 'deleted@monqiz.eg',
      phoneNumber: '01000000000',
      birthDate: DateTime(2000, 1, 1),
      gender: Gender.male,
      bloodType: BloodType.oPositive,
      status: UserStatus.inactive,
      preferredAddresses: const [],
    );
  }

  @override
  Future<UserModel> updateAddress({
    required String governorate,
    required String city,
    String? street,
  }) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.mockLatencyMs));
    final newAddress = AddressModel(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      governorate: governorate,
      city: city,
    );
    _currentUser = UserModel(
      id: _currentUser.id,
      firstName: _currentUser.firstName,
      lastName: _currentUser.lastName,
      email: _currentUser.email,
      phoneNumber: _currentUser.phoneNumber,
      pictureUrl: _currentUser.pictureUrl,
      birthDate: _currentUser.birthDate,
      gender: _currentUser.gender,
      bloodType: _currentUser.bloodType,
      lastDonationDate: _currentUser.lastDonationDate,
      status: _currentUser.status,
      preferredAddresses: [newAddress, ..._currentUser.preferredAddresses],
    );
    return _currentUser;
  }

  @override
  Future<void> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
