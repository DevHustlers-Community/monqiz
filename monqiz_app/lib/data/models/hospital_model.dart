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
      id: json['id']?.toString() ?? json['hospital_Id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      locationUrl: json['locationUrl']?.toString() ?? json['location(URL)']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: AddressModel.fromJson(addressJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'locationUrl': locationUrl,
        'email': email,
        'address': address is AddressModel
            ? (address as AddressModel).toJson()
            : {
                'id': address.id,
                'city': address.city,
                'governorate': address.governorate,
              },
      };
}
