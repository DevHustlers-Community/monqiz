import '../../domain/entities/enums.dart';
import '../../domain/entities/user_entity.dart';
import 'address_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    super.lastName,
    required super.email,
    required super.phoneNumber,
    super.pictureUrl,
    required super.birthDate,
    super.lastDonationDate,
    required super.gender,
    required super.bloodType,
    super.status,
    super.preferredAddresses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final addressesRaw = json['addresses'] ?? json['preferredAddresses'] ?? [];
    final addressesList = addressesRaw is List ? addressesRaw : [];

    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return fallback;
      }
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      pictureUrl: json['pictureUrl']?.toString() ?? json['pictruUrl']?.toString(),
      birthDate: parseDate(json['birthDate'], DateTime(1998, 1, 1)),
      lastDonationDate: parseNullableDate(json['lastDonationDate']),
      gender: Gender.fromValue(json['gender']),
      bloodType: BloodType.fromValue(json['bloodType']),
      status: UserStatus.fromValue(json['status']),
      preferredAddresses: addressesList
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'pictureUrl': pictureUrl,
        'birthDate': birthDate.toIso8601String(),
        'lastDonationDate': lastDonationDate?.toIso8601String(),
        'gender': gender.name,
        'bloodType': bloodType.symbol,
        'status': status.name,
        'addresses': preferredAddresses
            .map((a) => (a as AddressModel).toJson())
            .toList(),
      };
}
