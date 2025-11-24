import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class GetCars implements UseCase<List<Car>, NoParams> {
  final CarRepository repository;

  GetCars(this.repository);

  @override
  Future<Either<Failure, List<Car>>> call(NoParams params) async {
    return await repository.getCars();
  }
}