import 'package:equatable/equatable.dart';
import '../../../domain/entities/blood_request_entity.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/hospital_entity.dart';

class CreateRequestState extends Equatable {
  final int currentStep; // 0: Patient info, 1: Hospital, 2: Review
  final BloodType selectedBloodType;
  final int unitsNeeded;
  final DateTime? requiredDate;
  final HospitalEntity? selectedHospital;
  final String roomInfo;
  final String category;
  final String details;
  final bool isSubmitting;
  final BloodRequestEntity? createdRequest;
  final String? errorMessage;

  const CreateRequestState({
    this.currentStep = 0,
    this.selectedBloodType = BloodType.oPositive,
    this.unitsNeeded = 1,
    this.requiredDate,
    this.selectedHospital,
    this.roomInfo = 'غرفة فرز المتبرعين',
    this.category = 'عناية مركزة • طوارئ',
    this.details = '',
    this.isSubmitting = false,
    this.createdRequest,
    this.errorMessage,
  });

  CreateRequestState copyWith({
    int? currentStep,
    BloodType? selectedBloodType,
    int? unitsNeeded,
    DateTime? requiredDate,
    HospitalEntity? selectedHospital,
    String? roomInfo,
    String? category,
    String? details,
    bool? isSubmitting,
    BloodRequestEntity? createdRequest,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateRequestState(
      currentStep: currentStep ?? this.currentStep,
      selectedBloodType: selectedBloodType ?? this.selectedBloodType,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      requiredDate: requiredDate ?? this.requiredDate,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      roomInfo: roomInfo ?? this.roomInfo,
      category: category ?? this.category,
      details: details ?? this.details,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdRequest: createdRequest ?? this.createdRequest,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        selectedBloodType,
        unitsNeeded,
        requiredDate,
        selectedHospital,
        roomInfo,
        category,
        details,
        isSubmitting,
        createdRequest,
        errorMessage,
      ];
}
