import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';
import '../../../../core/usecases/usecase.dart';

class GetCarModels implements UseCase<List<String>, String> {
  final CarLibraryRepository repository;

  GetCarModels(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String params) async {
    return await repository.getCarModels(params);
  }
}