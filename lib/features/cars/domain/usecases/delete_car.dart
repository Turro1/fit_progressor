import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

class DeleteCar implements UseCase<void, String> {
  final CarRepository repository;
  final RepairRepository repairRepository;

  DeleteCar(this.repository, this.repairRepository);

  @override
  Future<Either<Failure, void>> call(String carId) async {
    // Cascade delete: first delete all repairs for this car
    final repairsResult = await repairRepository.getRepairs(carId: carId);

    await repairsResult.fold(
      (failure) async {
        // If we can't get repairs, just continue - maybe there are none
      },
      (repairs) async {
        // Delete each repair
        for (final repair in repairs) {
          await repairRepository.deleteRepair(repair.id);
        }
      },
    );

    // Finally, delete the car
    return await repository.deleteCar(carId);
  }
}
