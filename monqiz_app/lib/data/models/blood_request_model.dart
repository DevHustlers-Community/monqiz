import '../../domain/entities/enums.dart';
import '../../domain/entities/blood_request_entity.dart';
import 'hospital_model.dart';

class BloodRequestModel extends BloodRequestEntity {
  const BloodRequestModel({
    required super.id,
    required super.caseId,
    required super.creatorUserId,
    required super.hospital,
    required super.bloodType,
    required super.unitsNeeded,
    super.unitsPledged = 0,
    required super.createdAt,
    super.requiredDate,
    super.status = RequestStatus.approved,
    super.details,
    super.roomInfo = 'بنك الدم الرئيسي',
    super.category = 'عناية مركزة • طوارئ',
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    final hospitalJson = json['hospital'] as Map<String, dynamic>? ?? {};
    return BloodRequestModel(
      id: json['id'] as String? ?? json['request_Id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '#MQ-${json['id']?.toString().substring(0, 4) ?? '0000'}',
      creatorUserId: json['creatorUserId'] as String? ?? '',
      hospital: HospitalModel.fromJson(hospitalJson),
      bloodType: BloodType.fromString(json['bloodType']?.toString() ?? 'O-'),
      unitsNeeded: json['unitsNeeded'] as int? ?? 1,
      unitsPledged: json['unitsPledged'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      requiredDate: json['requiredDate'] != null
          ? DateTime.parse(json['requiredDate'] as String)
          : null,
      status: RequestStatus.approved,
      details: json['details'] as String?,
      roomInfo: json['roomInfo'] as String? ?? 'غرفة فرز المتبرعين',
      category: json['category'] as String? ?? 'عناية مركزة • طوارئ',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'caseId': caseId,
        'creatorUserId': creatorUserId,
        'hospital': (hospital as HospitalModel).toJson(),
        'bloodType': bloodType.symbol,
        'unitsNeeded': unitsNeeded,
        'unitsPledged': unitsPledged,
        'createdAt': createdAt.toIso8601String(),
        'requiredDate': requiredDate?.toIso8601String(),
        'details': details,
        'roomInfo': roomInfo,
        'category': category,
      };
}
