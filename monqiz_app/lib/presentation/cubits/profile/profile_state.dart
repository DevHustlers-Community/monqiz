import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final bool isUploadingPicture;
  final bool isUpdating;

  const ProfileLoaded({
    required this.user,
    this.isUploadingPicture = false,
    this.isUpdating = false,
  });

  ProfileLoaded copyWith({
    UserEntity? user,
    bool? isUploadingPicture,
    bool? isUpdating,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isUploadingPicture: isUploadingPicture ?? this.isUploadingPicture,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [user, isUploadingPicture, isUpdating];
}

final class ProfileSuccessMessage extends ProfileState {
  final String message;
  final UserEntity user;

  const ProfileSuccessMessage(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
