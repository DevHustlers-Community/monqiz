import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.city,
    required super.governorate,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? json['address_Id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
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
