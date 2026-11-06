import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthOtpSent extends AuthState {
  final String phoneNumber;
  const AuthOtpSent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthPasswordResetSent extends AuthState {
  final String message;
  const AuthPasswordResetSent(this.message);

  @override
  List<Object?> get props => [message];
}

final class AccountDeleted extends AuthState {
  final String message;
  const AccountDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

final class ProfileUpdated extends AuthState {
  final UserEntity user;
  final String message;
  const ProfileUpdated(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}
