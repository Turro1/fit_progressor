import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class GetCarsByClient implements UseCase<List<Car>, String> {
  final CarRepository repository;

  GetCarsByClient(this.repository);

  @override
  Future<Either<Failure, List<Car>>> call(String params) async {
    return await repository.getCarsByClient(params);
  }
}
