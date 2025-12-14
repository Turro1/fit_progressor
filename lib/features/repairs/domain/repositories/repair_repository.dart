import 'package:dartz/dartz.dart';
import '../../../../core/error/failures/failure.dart';
import '../entities/car_photo.dart';
import '../entities/repair.dart';
import '../entities/repair_status.dart';

abstract class RepairRepository {
  Future<Either<Failure, List<Repair>>> getRepairs();
  Future<Either<Failure, Repair>> getRepairById(String id);
  Future<Either<Failure, Repair>> addRepair(Repair repair);
  Future<Either<Failure, Repair>> updateRepair(Repair repair);
  Future<Either<Failure, void>> deleteRepair(String repairId);
  Future<Either<Failure, List<Repair>>> searchRepairs(String query);
  Future<Either<Failure, List<Repair>>> getRepairsByStatus(
      RepairStatus status);
  Future<Either<Failure, List<Repair>>> getRepairsByCar(String carId);
}

abstract class CarPhotoRepository {
  Future<Either<Failure, List<CarPhoto>>> getCarPhotos(String carId);
  Future<Either<Failure, CarPhoto>> addCarPhoto(CarPhoto photo);
  Future<Either<Failure, void>> deleteCarPhoto(String photoId);
}
