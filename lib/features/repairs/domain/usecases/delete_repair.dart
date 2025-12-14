import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart'; // Using package import
import '../repositories/repair_repository.dart';

class DeleteRepair implements UseCase<void, String> {
  final RepairRepository repairRepository;
  final MaterialRepository materialRepository; // For managing material stock

  DeleteRepair({required this.repairRepository, required this.materialRepository});

  @override
  Future<Either<Failure, void>> call(String repairId) async {
    // Get the repair to return materials to stock
    final repairEither = await repairRepository.getRepairById(repairId);

    return repairEither.fold((failure) => Left(failure), (repair) async {
      // Return materials to stock
      for (var repairMaterial in repair.materials) {
        final materialEither = await materialRepository.getMaterialById(repairMaterial.materialId);
        await materialEither.fold(
          (failure) => throw Exception('Material not found for return'), // Or handle failure more gracefully
          (material) async {
            final updatedMaterial = material.copyWith(quantity: material.quantity + repairMaterial.quantity);
            await materialRepository.updateMaterial(updatedMaterial);
          },
        );
      }
      return await repairRepository.deleteRepair(repairId);
    });
  }
}
