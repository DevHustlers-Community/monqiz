import 'package:equatable/equatable.dart';
import '../../../domain/entities/blood_request_entity.dart';
import '../../../domain/entities/request_acceptance_entity.dart';

sealed class RequestDetailsState extends Equatable {
  const RequestDetailsState();

  @override
  List<Object?> get props => [];
}

final class RequestDetailsInitial extends RequestDetailsState {
  const RequestDetailsInitial();
}

final class RequestDetailsLoading extends RequestDetailsState {
  const RequestDetailsLoading();
}

final class RequestDetailsLoaded extends RequestDetailsState {
  final BloodRequestEntity request;
  final bool isPledgeSubmitting;
  final RequestAcceptanceEntity? confirmedPledge;
  final String? errorMessage;

  const RequestDetailsLoaded({
    required this.request,
    this.isPledgeSubmitting = false,
    this.confirmedPledge,
    this.errorMessage,
  });

  RequestDetailsLoaded copyWith({
    BloodRequestEntity? request,
    bool? isPledgeSubmitting,
    RequestAcceptanceEntity? confirmedPledge,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestDetailsLoaded(
      request: request ?? this.request,
      isPledgeSubmitting: isPledgeSubmitting ?? this.isPledgeSubmitting,
      confirmedPledge: confirmedPledge ?? this.confirmedPledge,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [request, isPledgeSubmitting, confirmedPledge, errorMessage];
}

final class RequestDetailsError extends RequestDetailsState {
  final String message;
  const RequestDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
