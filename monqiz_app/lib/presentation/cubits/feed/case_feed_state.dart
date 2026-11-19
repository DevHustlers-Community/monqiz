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
  final String? activeCity;
  final EligibilityResult eligibility;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const CaseFeedLoaded({
    required this.requests,
    this.activeBloodFilter,
    this.activeGovernorate,
    this.activeCity,
    required this.eligibility,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  bool get isEmpty => requests.isEmpty;

  CaseFeedLoaded copyWith({
    List<BloodRequestEntity>? requests,
    BloodType? activeBloodFilter,
    String? activeGovernorate,
    String? activeCity,
    EligibilityResult? eligibility,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearBloodFilter = false,
    bool clearCity = false,
  }) {
    return CaseFeedLoaded(
      requests: requests ?? this.requests,
      activeBloodFilter: clearBloodFilter ? null : (activeBloodFilter ?? this.activeBloodFilter),
      activeGovernorate: activeGovernorate ?? this.activeGovernorate,
      activeCity: clearCity ? null : (activeCity ?? this.activeCity),
      eligibility: eligibility ?? this.eligibility,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        activeBloodFilter,
        activeGovernorate,
        activeCity,
        eligibility,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}

final class CaseFeedError extends CaseFeedState {
  final String message;
  const CaseFeedError(this.message);

  @override
  List<Object?> get props => [message];
}
