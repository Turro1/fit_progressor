import 'package:equatable/equatable.dart';
import '../../domain/entities/car_photo.dart';

abstract class CarPhotoState extends Equatable {
  const CarPhotoState();

  @override
  List<Object?> get props => [];
}

class CarPhotoInitial extends CarPhotoState {}

class CarPhotoLoading extends CarPhotoState {}

class CarPhotoLoaded extends CarPhotoState {
  final List<CarPhoto> photos;
  final String carId;

  const CarPhotoLoaded({required this.photos, required this.carId});

  @override
  List<Object?> get props => [photos, carId];
}

class CarPhotoError extends CarPhotoState {
  final String message;

  const CarPhotoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarPhotoOperationSuccess extends CarPhotoState {
  final String message;

  const CarPhotoOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
