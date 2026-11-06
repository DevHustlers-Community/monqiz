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
    final addressesJson = json['preferredAddresses'] as List<dynamic>? ?? [];
    return UserModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      pictureUrl: json['pictureUrl'] as String? ?? json['pictruUrl'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : DateTime(1998, 1, 1),
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.parse(json['lastDonationDate'] as String)
          : null,
      gender: Gender.fromString(json['gender']?.toString() ?? 'male'),
      bloodType: BloodType.fromString(json['bloodType']?.toString() ?? 'O+'),
      status: UserStatus.active,
      preferredAddresses: addressesJson.map((a) => AddressModel.fromJson(a as Map<String, dynamic>)).toList(),
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
      };
}
