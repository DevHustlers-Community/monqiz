import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/hospital_entity.dart';
import '../../../domain/repositories/blood_request_repository.dart';
import 'create_request_state.dart';

class CreateRequestCubit extends Cubit<CreateRequestState> {
  final BloodRequestRepository repository;

  CreateRequestCubit({required this.repository})
      : super(const CreateRequestState());

  void setStep(int step) => emit(state.copyWith(currentStep: step, clearError: true));

  void nextStep() {
    if (state.currentStep == 0) {
      if (state.unitsNeeded <= 0) {
        emit(state.copyWith(errorMessage: 'يرجى تحديد عدد أكياس الدم المطلوبة'));
        return;
      }
      emit(state.copyWith(currentStep: 1, clearError: true));
    } else if (state.currentStep == 1) {
      if (state.selectedHospital == null) {
        emit(state.copyWith(errorMessage: 'يرجى اختيار المستشفى المشرف على الحالة'));
        return;
      }
      emit(state.copyWith(currentStep: 2, clearError: true));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, clearError: true));
    }
  }

  void updateBloodType(BloodType type) => emit(state.copyWith(selectedBloodType: type));
  void updateUnitsNeeded(int units) => emit(state.copyWith(unitsNeeded: units));
  void updateRequiredDate(DateTime date) => emit(state.copyWith(requiredDate: date));
  void updateHospital(HospitalEntity hospital) => emit(state.copyWith(selectedHospital: hospital));
  void updateRoomInfo(String room) => emit(state.copyWith(roomInfo: room));
  void updateCategory(String category) => emit(state.copyWith(category: category));
  void updateDetails(String details) => emit(state.copyWith(details: details));

  Future<void> submitEmergencyRequest() async {
    if (state.selectedHospital == null) {
      emit(state.copyWith(errorMessage: 'يرجى اختيار المستشفى المشرف'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await repository.createEmergencyRequest(
      hospitalId: state.selectedHospital!.id,
      bloodType: state.selectedBloodType,
      unitsNeeded: state.unitsNeeded,
      requiredDate: state.requiredDate,
      details: state.details,
      roomInfo: state.roomInfo,
      category: state.category,
    );

    result.when(
      onSuccess: (req) => emit(state.copyWith(isSubmitting: false, createdRequest: req)),
      onFailure: (f) => emit(state.copyWith(isSubmitting: false, errorMessage: f.message)),
    );
  }

  void resetForm() => emit(const CreateRequestState());
}
