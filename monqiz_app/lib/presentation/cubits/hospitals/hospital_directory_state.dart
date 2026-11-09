import 'package:equatable/equatable.dart';
import '../../../domain/entities/hospital_entity.dart';

sealed class HospitalDirectoryState extends Equatable {
  const HospitalDirectoryState();

  @override
  List<Object?> get props => [];
}

final class HospitalDirectoryInitial extends HospitalDirectoryState {
  const HospitalDirectoryInitial();
}

final class HospitalDirectoryLoading extends HospitalDirectoryState {
  const HospitalDirectoryLoading();
}

final class HospitalDirectoryLoaded extends HospitalDirectoryState {
  final List<HospitalEntity> hospitals;
  final String searchQuery;
  final String selectedGovernorate;

  const HospitalDirectoryLoaded({
    required this.hospitals,
    this.searchQuery = '',
    this.selectedGovernorate = 'الكل',
  });

  HospitalDirectoryLoaded copyWith({
    List<HospitalEntity>? hospitals,
    String? searchQuery,
    String? selectedGovernorate,
  }) {
    return HospitalDirectoryLoaded(
      hospitals: hospitals ?? this.hospitals,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
    );
  }

  @override
  List<Object?> get props => [hospitals, searchQuery, selectedGovernorate];
}

final class HospitalDirectoryError extends HospitalDirectoryState {
  final String message;
  const HospitalDirectoryError(this.message);

  @override
  List<Object?> get props => [message];
}
