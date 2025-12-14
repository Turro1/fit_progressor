import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/car_photo.dart';
import '../repositories/repair_repository.dart'; // Using RepairRepository for CarPhoto

class GetCarPhotos implements UseCase<List<CarPhoto>, String> {
  final CarPhotoRepository repository;

  GetCarPhotos(this.repository);

  @override
  Future<Either<Failure, List<CarPhoto>>> call(String carId) async {
    return await repository.getCarPhotos(carId);
  }
}
