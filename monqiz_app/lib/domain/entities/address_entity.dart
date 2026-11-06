import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String city;
  final String governorate;

  const AddressEntity({
    required this.id,
    required this.city,
    required this.governorate,
  });

  String get fullAddress => '$governorate - $city';

  @override
  List<Object?> get props => [id, city, governorate];
}
