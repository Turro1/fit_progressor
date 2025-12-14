import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/material_repository.dart';

class DeleteMaterial implements UseCase<void, String> {
  final MaterialRepository repository;

  DeleteMaterial(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteMaterial(params);
  }
}
