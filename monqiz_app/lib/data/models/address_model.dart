import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.city,
    required super.governorate,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? json['addressId']?.toString() ?? json['address_Id']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'governorate': governorate,
      };

  AddressEntity toEntity() => AddressEntity(
        id: id,
        city: city,
        governorate: governorate,
      );
}
