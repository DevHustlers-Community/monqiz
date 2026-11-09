import 'package:equatable/equatable.dart';
import '../../../domain/entities/blood_request_entity.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/rules/eligibility_rules.dart';

sealed class CaseFeedState extends Equatable {
  const CaseFeedState();

  @override
  List<Object?> get props => [];
}

final class CaseFeedInitial extends CaseFeedState {
  const CaseFeedInitial();
}

final class CaseFeedLoading extends CaseFeedState {
  const CaseFeedLoading();
}

final class CaseFeedLoaded extends CaseFeedState {
  final List<BloodRequestEntity> requests;
  final BloodType? activeBloodFilter;
  final String? activeGovernorate;
  final EligibilityResult eligibility;

  const CaseFeedLoaded({
    required this.requests,
    this.activeBloodFilter,
    this.activeGovernorate,
    required this.eligibility,
  });

  bool get isEmpty => requests.isEmpty;

  CaseFeedLoaded copyWith({
    List<BloodRequestEntity>? requests,
    BloodType? activeBloodFilter,
    String? activeGovernorate,
    EligibilityResult? eligibility,
    bool clearBloodFilter = false,
  }) {
    return CaseFeedLoaded(
      requests: requests ?? this.requests,
      activeBloodFilter: clearBloodFilter ? null : (activeBloodFilter ?? this.activeBloodFilter),
      activeGovernorate: activeGovernorate ?? this.activeGovernorate,
      eligibility: eligibility ?? this.eligibility,
    );
  }

  @override
  List<Object?> get props => [requests, activeBloodFilter, activeGovernorate, eligibility];
}

final class CaseFeedError extends CaseFeedState {
  final String message;
  const CaseFeedError(this.message);

  @override
  List<Object?> get props => [message];
}
