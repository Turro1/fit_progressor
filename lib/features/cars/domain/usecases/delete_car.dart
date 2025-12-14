import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

class DeleteCar implements UseCase<void, String> {
  final CarRepository repository;

  DeleteCar(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteCar(params);
  }
}
