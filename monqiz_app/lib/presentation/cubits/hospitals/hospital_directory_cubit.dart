import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/hospital_repository.dart';
import 'hospital_directory_state.dart';

class HospitalDirectoryCubit extends Cubit<HospitalDirectoryState> {
  final HospitalRepository repository;

  HospitalDirectoryCubit({required this.repository})
      : super(const HospitalDirectoryInitial());

  Future<void> loadHospitals() async {
    emit(const HospitalDirectoryLoading());
    final result = await repository.getHospitals();
    result.when(
      onSuccess: (hospitals) => emit(HospitalDirectoryLoaded(hospitals: hospitals)),
      onFailure: (f) => emit(HospitalDirectoryError(f.message)),
    );
  }

  Future<void> search(String query) async {
    if (state is! HospitalDirectoryLoaded) return;
    final current = state as HospitalDirectoryLoaded;

    emit(const HospitalDirectoryLoading());
    final result = await repository.getHospitals(
      query: query,
      governorate: current.selectedGovernorate == 'الكل' ? null : current.selectedGovernorate,
    );

    result.when(
      onSuccess: (hospitals) => emit(HospitalDirectoryLoaded(
        hospitals: hospitals,
        searchQuery: query,
        selectedGovernorate: current.selectedGovernorate,
      )),
      onFailure: (f) => emit(HospitalDirectoryError(f.message)),
    );
  }

  Future<void> filterGovernorate(String governorate) async {
    if (state is! HospitalDirectoryLoaded) return;
    final current = state as HospitalDirectoryLoaded;

    emit(const HospitalDirectoryLoading());
    final result = await repository.getHospitals(
      query: current.searchQuery,
      governorate: governorate == 'الكل' ? null : governorate,
    );

    result.when(
      onSuccess: (hospitals) => emit(HospitalDirectoryLoaded(
        hospitals: hospitals,
        searchQuery: current.searchQuery,
        selectedGovernorate: governorate,
      )),
      onFailure: (f) => emit(HospitalDirectoryError(f.message)),
    );
  }
}
