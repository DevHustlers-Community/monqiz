import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await profileRepository.getProfile();
    result.when(
      onSuccess: (user) => emit(ProfileLoaded(user: user)),
      onFailure: (f) => emit(ProfileError(f.message)),
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required BloodType bloodType,
    required DateTime birthDate,
    DateTime? lastDonationDate,
    required UserStatus status,
    required Gender gender,
  }) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(isUpdating: true));
    }

    final result = await profileRepository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      bloodType: bloodType,
      birthDate: birthDate,
      lastDonationDate: lastDonationDate,
      status: status,
      gender: gender,
    );

    result.when(
      onSuccess: (updatedUser) {
        emit(ProfileSuccessMessage('تم تحديث الملف الشخصي بنجاح', updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      },
      onFailure: (f) {
        if (current is ProfileLoaded) {
          emit(current.copyWith(isUpdating: false));
        }
        emit(ProfileError(f.message));
      },
    );
  }

  Future<void> toggleAvailabilityStatus(bool isAvailable) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    final newStatus = isAvailable ? UserStatus.active : UserStatus.inactive;
    final user = current.user;

    emit(current.copyWith(isUpdating: true));

    final result = await profileRepository.updateProfile(
      firstName: user.firstName,
      lastName: user.lastName ?? '',
      phoneNumber: user.phoneNumber,
      bloodType: user.bloodType,
      birthDate: user.birthDate,
      lastDonationDate: user.lastDonationDate,
      status: newStatus,
      gender: user.gender,
    );

    result.when(
      onSuccess: (updatedUser) {
        final msg = isAvailable
            ? 'أنت الآن متاح وجاهز لاستقبال تنبيهات التبرع'
            : 'تم إيقاف استقبال التنبيهات مؤقتاً';
        emit(ProfileSuccessMessage(msg, updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      },
      onFailure: (f) {
        emit(current.copyWith(isUpdating: false));
        emit(ProfileError(f.message));
      },
    );
  }

  Future<void> uploadProfilePicture(String filePath) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUploadingPicture: true));

    final result = await profileRepository.uploadProfilePicture(filePath);
    result.when(
      onSuccess: (newUrl) {
        final updatedUser = current.user.copyWith(pictureUrl: newUrl);
        emit(ProfileSuccessMessage('تم تحديث الصورة الشخصية بنجاح', updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      },
      onFailure: (f) {
        emit(current.copyWith(isUploadingPicture: false));
        emit(ProfileError(f.message));
      },
    );
  }

  Future<void> updateDonationAddresses(List<String> addressIds) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

    final result = await profileRepository.updateDonationAddresses(addressIds);
    result.when(
      onSuccess: (_) async {
        final freshProfile = await profileRepository.getProfile();
        freshProfile.when(
          onSuccess: (user) {
            emit(ProfileSuccessMessage('تم تحديث مناطق التبرع المفضلة بنجاح', user));
            emit(ProfileLoaded(user: user));
          },
          onFailure: (_) {
            emit(ProfileLoaded(user: current.user));
          },
        );
      },
      onFailure: (f) {
        emit(current.copyWith(isUpdating: false));
        emit(ProfileError(f.message));
      },
    );
  }

  Future<List<String>> getGovernorates() async {
    final res = await profileRepository.getGovernorates();
    return res.dataOrNull ?? [];
  }

  Future<List<String>> getCities(String governorate) async {
    final res = await profileRepository.getCities(governorate);
    return res.dataOrNull ?? [];
  }

  Future<List<AddressEntity>> getAllAddresses({String? governorate, String? city}) async {
    final res = await profileRepository.getAllAddresses(
      governorate: governorate,
      city: city,
    );
    return res.dataOrNull ?? [];
  }
}
