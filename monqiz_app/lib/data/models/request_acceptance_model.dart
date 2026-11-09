import '../../domain/entities/enums.dart';
import '../../domain/entities/request_acceptance_entity.dart';

class RequestAcceptanceModel extends RequestAcceptanceEntity {
  const RequestAcceptanceModel({
    required super.userId,
    required super.requestId,
    required super.acceptanceStatus,
    required super.createdAt,
    super.hospitalName,
    super.bloodType,
  });

  factory RequestAcceptanceModel.fromJson(Map<String, dynamic> json) {
    return RequestAcceptanceModel(
      userId: json['userId'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      acceptanceStatus: DonationStatus.values.firstWhere(
        (s) => s.name == (json['acceptanceStatus']?.toString().toLowerCase() ?? 'completed'),
        orElse: () => DonationStatus.completed,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      hospitalName: json['hospitalName'] as String?,
      bloodType: json['bloodType'] != null
          ? BloodType.fromString(json['bloodType'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'requestId': requestId,
        'acceptanceStatus': acceptanceStatus.name,
        'createdAt': createdAt.toIso8601String(),
        'hospitalName': hospitalName,
        'bloodType': bloodType?.symbol,
      };
}
