import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    final result = await repository.getCurrentUser();
    result.when(
      onSuccess: (user) => emit(Authenticated(user)),
      onFailure: (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> login({required String identifier, required String password}) async {
    emit(const AuthLoading());
    final result = await repository.login(identifier: identifier, password: password);
    result.when(
      onSuccess: (user) => emit(Authenticated(user)),
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> register({
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
    emit(const AuthLoading());
    final result = await repository.register(
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
    result.when(
      onSuccess: (user) => emit(Authenticated(user)),
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await repository.logout();
    emit(const Unauthenticated());
  }

  Future<void> requestPasswordReset(String phoneNumber) async {
    emit(const AuthLoading());
    final res = await repository.requestPasswordReset(phoneNumber: phoneNumber);
    res.when(
      onSuccess: (_) => emit(const AuthPasswordResetSent('تم إرسال رمز استعادة الحساب بنجاح')),
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    emit(const AuthLoading());
    final res = await repository.verifyOtp(phoneNumber: phoneNumber, otpCode: otp);
    res.when(
      onSuccess: (_) => checkAuthStatus(),
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> deleteAccount({required String reason, String? password}) async {
    emit(const AuthLoading());
    final result = await repository.deleteAccount(reason: reason, password: password);
    result.when(
      onSuccess: (_) {
        emit(const AccountDeleted('تم مسح الحساب وسجل التبرعات نهائياً بنجاح'));
        emit(const Unauthenticated());
      },
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> updateAddress({
    required String governorate,
    required String city,
    String? street,
  }) async {
    emit(const AuthLoading());
    final result = await repository.updateProfileAddress(
      governorate: governorate,
      city: city,
      street: street,
    );
    result.when(
      onSuccess: (updatedUser) => emit(ProfileUpdated(updatedUser, 'تم تحديث العنوان الجغرافي بنجاح')),
      onFailure: (f) => emit(AuthError(f.message)),
    );
  }

  Future<void> updateNotificationPreferences({
    required bool emergencyAlerts,
    required bool rareBloodAlerts,
    required bool restReminderAlerts,
  }) async {
    await repository.updateNotificationPreferences(
      emergencyAlerts: emergencyAlerts,
      rareBloodAlerts: rareBloodAlerts,
      restReminderAlerts: restReminderAlerts,
    );
  }
}
