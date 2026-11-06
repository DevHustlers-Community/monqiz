import 'package:equatable/equatable.dart';
import '../../../domain/entities/request_acceptance_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/rules/eligibility_rules.dart';

sealed class DonorCardState extends Equatable {
  const DonorCardState();

  @override
  List<Object?> get props => [];
}

final class DonorCardInitial extends DonorCardState {
  const DonorCardInitial();
}

final class DonorCardLoading extends DonorCardState {
  const DonorCardLoading();
}

final class DonorCardLoaded extends DonorCardState {
  final UserEntity user;
  final EligibilityResult eligibility;
  final List<RequestAcceptanceEntity> donationHistory;

  const DonorCardLoaded({
    required this.user,
    required this.eligibility,
    required this.donationHistory,
  });

  int get totalDonationsCount => donationHistory.length;

  @override
  List<Object?> get props => [user, eligibility, donationHistory];
}

final class DonorCardError extends DonorCardState {
  final String message;
  const DonorCardError(this.message);

  @override
  List<Object?> get props => [message];
}
