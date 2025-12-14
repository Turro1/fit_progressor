import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/car_photo.dart';
import '../repositories/repair_repository.dart'; // Using RepairRepository for CarPhoto

class AddCarPhoto implements UseCase<CarPhoto, AddCarPhotoParams> {
  final CarPhotoRepository repository;

  AddCarPhoto(this.repository);

  @override
  Future<Either<Failure, CarPhoto>> call(AddCarPhotoParams params) async {
    final now = DateTime.now();
    final carPhoto = CarPhoto(
      id: 'photo_${now.millisecondsSinceEpoch}',
      carId: params.carId,
      photoPath: params.photoPath,
      description: params.description,
      createdAt: now,
    );
    return await repository.addCarPhoto(carPhoto);
  }
}

class AddCarPhotoParams extends Equatable {
  final String carId;
  final String photoPath;
  final String? description;

  const AddCarPhotoParams({
    required this.carId,
    required this.photoPath,
    this.description,
  });

  @override
  List<Object?> get props => [carId, photoPath, description];
}
