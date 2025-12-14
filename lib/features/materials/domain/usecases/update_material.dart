import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class UpdateMaterial implements UseCase<Material, Material> {
  final MaterialRepository repository;

  UpdateMaterial(this.repository);

  @override
  Future<Either<Failure, Material>> call(Material params) async {
    return await repository.updateMaterial(params);
  }
}
