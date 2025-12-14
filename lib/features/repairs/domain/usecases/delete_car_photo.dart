import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/repair_repository.dart'; // Using RepairRepository for CarPhoto

class DeleteCarPhoto implements UseCase<void, String> {
  final CarPhotoRepository repository;

  DeleteCarPhoto(this.repository);

  @override
  Future<Either<Failure, void>> call(String photoId) async {
    return await repository.deleteCarPhoto(photoId);
  }
}
