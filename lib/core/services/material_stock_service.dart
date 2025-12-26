import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';

class MaterialStockService {
  final MaterialRepository materialRepository;

  MaterialStockService({required this.materialRepository});

  Future<Either<Failure, void>> deductMaterials(
    List<RepairMaterial> materials,
  ) async {
    for (final repairMaterial in materials) {
      final result =
          await materialRepository.getMaterialById(repairMaterial.materialId);

      final Either<Failure, void> updateResult = await result.fold(
        (failure) async => Left(failure),
        (material) async {
          final newQuantity = material.quantity - repairMaterial.quantity;
          final updatedMaterial = material.copyWith(quantity: newQuantity);
          final updateResult =
              await materialRepository.updateMaterial(updatedMaterial);
          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );

      if (updateResult.isLeft()) {
        return updateResult;
      }
    }
    return const Right(null);
  }

  Future<Either<Failure, void>> returnMaterials(
    List<RepairMaterial> materials,
  ) async {
    for (final repairMaterial in materials) {
      final result =
          await materialRepository.getMaterialById(repairMaterial.materialId);

      final Either<Failure, void> updateResult = await result.fold(
        (failure) async => Left(failure),
        (material) async {
          final newQuantity = material.quantity + repairMaterial.quantity;
          final updatedMaterial = material.copyWith(quantity: newQuantity);
          final updateResult =
              await materialRepository.updateMaterial(updatedMaterial);
          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );

      if (updateResult.isLeft()) {
        return updateResult;
      }
    }
    return const Right(null);
  }

  Future<Either<Failure, void>> adjustMaterials(
    List<RepairMaterial> oldMaterials,
    List<RepairMaterial> newMaterials,
  ) async {
    final returnResult = await returnMaterials(oldMaterials);
    if (returnResult.isLeft()) return returnResult;

    return await deductMaterials(newMaterials);
  }
}
