import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class SearchMaterials implements UseCase<List<Material>, String> {
  final MaterialRepository repository;

  SearchMaterials(this.repository);

  @override
  Future<Either<Failure, List<Material>>> call(String params) async {
    final result = await repository.getAllMaterials();
    return result.fold((failure) => Left(failure), (materials) {
      if (params.isEmpty) {
        return Right(materials);
      }
      final filtered = materials
          .where(
            (material) =>
                material.name.toLowerCase().contains(params.toLowerCase()),
          )
          .toList();
      return Right(filtered);
    });
  }
}
