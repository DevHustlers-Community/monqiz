import '../../domain/entities/enums.dart';
import '../../domain/entities/blood_request_entity.dart';
import 'hospital_model.dart';
import 'address_model.dart';

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
    final rawHospital = json['hospital'];
    final HospitalModel hospitalModel;
    if (rawHospital is Map<String, dynamic>) {
      hospitalModel = HospitalModel.fromJson(rawHospital);
    } else {
      hospitalModel = const HospitalModel(
        id: '',
        name: 'مستشفى غير محدد',
        phoneNumber: '',
        locationUrl: '',
        email: '',
        address: AddressModel(id: '', city: 'القاهرة', governorate: 'القاهرة'),
      );
    }

    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return fallback;
      }
    }

    final id = json['id']?.toString() ?? json['request_Id']?.toString() ?? '';
    final shortId = id.length >= 4 ? id.substring(0, 4) : '0001';

    return BloodRequestModel(
      id: id,
      caseId: json['caseId'] as String? ?? '#MQ-$shortId',
      creatorUserId: json['creatorUserId']?.toString() ?? '',
      hospital: hospitalModel,
      bloodType: BloodType.fromValue(json['bloodType']),
      unitsNeeded: json['unitsNeeded'] as int? ?? 1,
      unitsPledged: json['unitsPledged'] as int? ?? 0,
      createdAt: parseDate(json['createdAt'], DateTime.now()),
      requiredDate: json['requiredDate'] != null ? parseDate(json['requiredDate'], DateTime.now()) : null,
      status: RequestStatus.fromValue(json['status']),
      details: json['details'] as String?,
      roomInfo: json['roomInfo'] as String? ?? 'غرفة فرز المتبرعين',
      category: json['category'] as String? ?? 'عناية مركزة • طوارئ',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'caseId': caseId,
        'creatorUserId': creatorUserId,
        'hospital': hospital is HospitalModel
            ? (hospital as HospitalModel).toJson()
            : {
                'id': hospital.id,
                'name': hospital.name,
                'phoneNumber': hospital.phoneNumber,
                'locationUrl': hospital.locationUrl,
                'email': hospital.email,
                'address': {
                  'id': hospital.address.id,
                  'city': hospital.address.city,
                  'governorate': hospital.address.governorate,
                },
              },
        'bloodType': bloodType.toBackendString(),
        'unitsNeeded': unitsNeeded,
        'unitsPledged': unitsPledged,
        'createdAt': createdAt.toIso8601String(),
        'requiredDate': requiredDate?.toIso8601String(),
        'details': details,
        'roomInfo': roomInfo,
        'category': category,
        'status': status.name,
      };
}
