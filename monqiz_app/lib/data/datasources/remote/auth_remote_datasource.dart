import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../domain/entities/enums.dart';
import '../../models/user_model.dart';
import '../auth_datasource.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSource({
    required this.dioClient,
    required this.tokenStorage,
  });

  @override
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.login,
      data: {
        'emailOrPhone': identifier,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await tokenStorage.saveToken(token);
    }

    // Try fetching the full profile with preferred addresses
    try {
      final profile = await getCurrentUser();
      return profile;
    } catch (_) {
      // Fallback to basic user payload returned by login
      final rawUser = data['user'] as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(rawUser);
    }
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
    final birthDateStr = birthDate.toIso8601String().substring(0, 10);
    final response = await dioClient.dio.post(
      ApiEndpoints.register,
      data: {
        'firstName': firstName,
        'lastName': lastName ?? '',
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'birthDate': birthDateStr,
        'gender': gender.toBackendInt(),
        'bloodType': bloodType.toBackendInt(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userId = data['userId']?.toString() ?? '';
    await tokenStorage.saveSession(userId: userId, phone: phoneNumber);

    return UserModel(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      gender: gender,
      bloodType: bloodType,
      status: UserStatus.inactive,
    );
  }

  @override
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    await dioClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'recipient': phoneNumber,
        'otp': otpCode,
      },
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get(ApiEndpoints.userProfile);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final profileData = data['data'] != null && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      return UserModel.fromJson(profileData);
    }
    throw Exception('استجابة غير صالحة من خادم الملف الشخصي');
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required BloodType bloodType,
    required DateTime birthDate,
    DateTime? lastDonationDate,
    required UserStatus status,
    required Gender gender,
  }) async {
    final birthDateStr = birthDate.toIso8601String().substring(0, 10);
    final lastDonationStr = lastDonationDate?.toIso8601String().substring(0, 10);

    await dioClient.dio.put(
      ApiEndpoints.userProfile,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'birthDate': birthDateStr,
        'lastDonationDate': lastDonationStr,
        'gender': gender.toBackendInt(),
        'bloodType': bloodType.toBackendInt(),
        'status': status.toBackendInt(),
      },
    );

    return getCurrentUser();
  }

  Future<String> uploadProfilePicture(String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dioClient.dio.post(
      ApiEndpoints.userProfilePicture,
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return data['pictureUrl']?.toString() ?? '';
  }

  Future<void> updateDonationAddresses(List<String> addressIds) async {
    await dioClient.dio.put(
      ApiEndpoints.userDonationAddresses,
      data: {
        'addressIds': addressIds,
      },
    );
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearAll();
  }

  @override
  Future<void> requestPasswordReset({required String phoneNumber}) async {
    // Optional placeholder endpoint
  }

  @override
  Future<void> deleteAccount({required String reason, String? password}) async {
    await tokenStorage.clearAll();
  }

  @override
  Future<UserModel> updateAddress({
    required String governorate,
    required String city,
    String? street,
  }) async {
    return getCurrentUser();
  }

  @override
  Future<void> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  }) async {}
}
