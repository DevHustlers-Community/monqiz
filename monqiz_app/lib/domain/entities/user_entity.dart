import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'address_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String phoneNumber;
  final String? pictureUrl;
  final DateTime birthDate;
  final DateTime? lastDonationDate;
  final Gender gender;
  final BloodType bloodType;
  final UserStatus status;
  final List<AddressEntity> preferredAddresses;

  const UserEntity({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    this.pictureUrl,
    required this.birthDate,
    this.lastDonationDate,
    required this.gender,
    required this.bloodType,
    this.status = UserStatus.active,
    this.preferredAddresses = const [],
  });

  String get fullName => lastName == null || lastName!.isEmpty ? firstName : '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? pictureUrl,
    DateTime? birthDate,
    DateTime? lastDonationDate,
    Gender? gender,
    BloodType? bloodType,
    UserStatus? status,
    List<AddressEntity>? preferredAddresses,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      birthDate: birthDate ?? this.birthDate,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      status: status ?? this.status,
      preferredAddresses: preferredAddresses ?? this.preferredAddresses,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phoneNumber,
        pictureUrl,
        birthDate,
        lastDonationDate,
        gender,
        bloodType,
        status,
        preferredAddresses,
      ];
}
