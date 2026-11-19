import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/address_remote_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/auth_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthDataSource authDataSource;
  final AddressRemoteDataSource addressDataSource;

  const ProfileRepositoryImpl({
    required this.authDataSource,
    required this.addressDataSource,
  });

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final user = await authDataSource.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required BloodType bloodType,
    required DateTime birthDate,
    DateTime? lastDonationDate,
    required UserStatus status,
    required Gender gender,
  }) async {
    try {
      final source = authDataSource;
      if (source is AuthRemoteDataSource) {
        final updated = await source.updateProfile(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          bloodType: bloodType,
          birthDate: birthDate,
          lastDonationDate: lastDonationDate,
          status: status,
          gender: gender,
        );
        return Result.success(updated);
      } else {
        // Mock fallback
        final current = await authDataSource.getCurrentUser();
        final updated = current.copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          bloodType: bloodType,
          birthDate: birthDate,
          lastDonationDate: lastDonationDate,
          status: status,
          gender: gender,
        );
        return Result.success(updated);
      }
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadProfilePicture(String filePath) async {
    try {
      final source = authDataSource;
      if (source is AuthRemoteDataSource) {
        final url = await source.uploadProfilePicture(filePath);
        return Result.success(url);
      }
      return const Result.success('/uploads/profile-pictures/mock_avatar.jpg');
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateDonationAddresses(List<String> addressIds) async {
    try {
      final source = authDataSource;
      if (source is AuthRemoteDataSource) {
        await source.updateDonationAddresses(addressIds);
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getGovernorates() async {
    try {
      final list = await addressDataSource.getGovernorates();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getCities(String governorate) async {
    try {
      final list = await addressDataSource.getCities(governorate);
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AddressEntity>>> getAllAddresses({String? governorate, String? city}) async {
    try {
      final list = await addressDataSource.getAllAddresses(
        governorate: governorate,
        city: city,
      );
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
