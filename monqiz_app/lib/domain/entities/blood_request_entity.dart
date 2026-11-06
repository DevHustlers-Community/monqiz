import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'hospital_entity.dart';

class BloodRequestEntity extends Equatable {
  final String id;
  final String caseId;
  final String creatorUserId;
  final HospitalEntity hospital;
  final BloodType bloodType;
  final int unitsNeeded;
  final int unitsPledged;
  final DateTime createdAt;
  final DateTime? requiredDate;
  final RequestStatus status;
  final String? details;
  final String roomInfo;
  final String category;

  const BloodRequestEntity({
    required this.id,
    required this.caseId,
    required this.creatorUserId,
    required this.hospital,
    required this.bloodType,
    required this.unitsNeeded,
    this.unitsPledged = 0,
    required this.createdAt,
    this.requiredDate,
    this.status = RequestStatus.approved,
    this.details,
    this.roomInfo = 'بنك الدم الرئيسي',
    this.category = 'عناية مركزة • طوارئ',
  });

  bool get isFulfilled => unitsPledged >= unitsNeeded;

  String get remainingTimeFormatted {
    if (requiredDate == null) return 'حالة عاجلة';
    final diff = requiredDate!.difference(DateTime.now());
    if (diff.isNegative) return 'انتهت المهلة';
    if (diff.inHours < 1) return 'مطلوب خلال ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'مطلوب خلال ${diff.inHours} ساعات';
    return 'مطلوب خلال ${diff.inDays} أيام';
  }

  BloodRequestEntity copyWith({
    int? unitsPledged,
    RequestStatus? status,
  }) {
    return BloodRequestEntity(
      id: id,
      caseId: caseId,
      creatorUserId: creatorUserId,
      hospital: hospital,
      bloodType: bloodType,
      unitsNeeded: unitsNeeded,
      unitsPledged: unitsPledged ?? this.unitsPledged,
      createdAt: createdAt,
      requiredDate: requiredDate,
      status: status ?? this.status,
      details: details,
      roomInfo: roomInfo,
      category: category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        caseId,
        creatorUserId,
        hospital,
        bloodType,
        unitsNeeded,
        unitsPledged,
        createdAt,
        requiredDate,
        status,
        details,
        roomInfo,
        category,
      ];
}
