import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';
import '../../../../core/usecases/usecase.dart';

class GetCarMakes implements UseCase<List<String>, NoParams> {
  final CarLibraryRepository libraryRepository;

  GetCarMakes(this.libraryRepository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await libraryRepository.getCarMakes();
  }
}