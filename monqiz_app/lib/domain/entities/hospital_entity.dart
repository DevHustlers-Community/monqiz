import 'package:equatable/equatable.dart';
import 'address_entity.dart';

class HospitalEntity extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String locationUrl;
  final String email;
  final AddressEntity address;

  const HospitalEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.locationUrl,
    required this.email,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, locationUrl, email, address];
}
