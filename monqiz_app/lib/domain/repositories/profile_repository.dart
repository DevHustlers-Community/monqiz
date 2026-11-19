import '../../core/error/result.dart';
import '../entities/address_entity.dart';
import '../entities/enums.dart';
import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Result<UserEntity>> getProfile();

  Future<Result<UserEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required BloodType bloodType,
    required DateTime birthDate,
    DateTime? lastDonationDate,
    required UserStatus status,
    required Gender gender,
  });

  Future<Result<String>> uploadProfilePicture(String filePath);

  Future<Result<void>> updateDonationAddresses(List<String> addressIds);

  Future<Result<List<String>>> getGovernorates();

  Future<Result<List<String>>> getCities(String governorate);

  Future<Result<List<AddressEntity>>> getAllAddresses({String? governorate, String? city});
}
