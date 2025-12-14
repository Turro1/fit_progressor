import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class GetMaterials implements UseCase<List<Material>, NoParams> {
  final MaterialRepository repository;

  GetMaterials(this.repository);

  @override
  Future<Either<Failure, List<Material>>> call(NoParams params) async {
    return await repository.getAllMaterials();
  }
}
