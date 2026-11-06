import 'package:equatable/equatable.dart';
import 'enums.dart';

class RequestAcceptanceEntity extends Equatable {
  final String userId;
  final String requestId;
  final DonationStatus acceptanceStatus;
  final DateTime createdAt;
  final String? hospitalName;
  final BloodType? bloodType;

  const RequestAcceptanceEntity({
    required this.userId,
    required this.requestId,
    required this.acceptanceStatus,
    required this.createdAt,
    this.hospitalName,
    this.bloodType,
  });

  @override
  List<Object?> get props => [
        userId,
        requestId,
        acceptanceStatus,
        createdAt,
        hospitalName,
        bloodType,
      ];
}
