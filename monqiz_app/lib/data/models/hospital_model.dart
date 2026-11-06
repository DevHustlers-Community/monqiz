import '../../domain/entities/hospital_entity.dart';
import 'address_model.dart';

class HospitalModel extends HospitalEntity {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.locationUrl,
    required super.email,
    required super.address,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] as Map<String, dynamic>? ?? {};
    return HospitalModel(
      id: json['id'] as String? ?? json['hospital_Id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      locationUrl: json['locationUrl'] as String? ?? json['location(URL)'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: AddressModel.fromJson(addressJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'locationUrl': locationUrl,
        'email': email,
        'address': (address as AddressModel).toJson(),
      };
}
