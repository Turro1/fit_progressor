import 'package:equatable/equatable.dart';

abstract class CarPhotoEvent extends Equatable {
  const CarPhotoEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarPhotos extends CarPhotoEvent {
  final String carId;

  const LoadCarPhotos({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class AddCarPhotoEvent extends CarPhotoEvent {
  final String carId;
  final String photoPath;
  final String? description;

  const AddCarPhotoEvent({
    required this.carId,
    required this.photoPath,
    this.description,
  });

  @override
  List<Object?> get props => [carId, photoPath, description];
}

class DeleteCarPhotoEvent extends CarPhotoEvent {
  final String photoId;
  final String carId; // Needed to reload photos for the specific car

  const DeleteCarPhotoEvent({required this.photoId, required this.carId});

  @override
  List<Object?> get props => [photoId, carId];
}
