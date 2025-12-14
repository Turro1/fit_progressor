import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart'; // Using package import
import '../entities/repair.dart';
import '../entities/repair_history.dart';
import '../entities/repair_status.dart';
import '../repositories/repair_repository.dart';

class UpdateRepair implements UseCase<Repair, Repair> {
  final RepairRepository repairRepository;
  final MaterialRepository materialRepository; // For managing material stock

  UpdateRepair({required this.repairRepository, required this.materialRepository});

  @override
  Future<Either<Failure, Repair>> call(Repair newRepair) async {
    // Get the old repair state to compare materials and add history
    final oldRepairEither = await repairRepository.getRepairById(newRepair.id);

    return oldRepairEither.fold((failure) => Left(failure), (oldRepair) async {
      final now = DateTime.now();
      List<RepairHistory> updatedHistory = List.from(newRepair.history);

      // Handle status change
      if (oldRepair.status != newRepair.status) {
        updatedHistory.add(RepairHistory(
          id: 'history_${now.millisecondsSinceEpoch}',
          timestamp: now,
          type: HistoryType.statusChange,
          description:
              'Статус изменен с "$oldRepair.status.displayName" на "$newRepair.status.displayName"',
        ));
      }

      // Handle material changes (deduct new, return old)
      // This is a simplified approach. A more robust solution would track quantity changes.
      final oldMaterialQuantities = {for (var m in oldRepair.materials) m.materialId: m.quantity};
      final newMaterialQuantities = {for (var m in newRepair.materials) m.materialId: m.quantity};

      for (var newMat in newRepair.materials) {
        if (!oldMaterialQuantities.containsKey(newMat.materialId) ||
            oldMaterialQuantities[newMat.materialId]! < newMat.quantity) {
          // Material added or quantity increased
          final quantityChange = newMat.quantity - (oldMaterialQuantities[newMat.materialId] ?? 0);
          final materialEither = await materialRepository.getMaterialById(newMat.materialId);
          await materialEither.fold(
            (failure) => throw Exception('Material not found for deduction'),
            (material) async {
              final updatedMaterial = material.copyWith(quantity: material.quantity - quantityChange);
              await materialRepository.updateMaterial(updatedMaterial);
              updatedHistory.add(RepairHistory(
                id: 'history_${now.millisecondsSinceEpoch}',
                timestamp: now,
                type: HistoryType.materialAdded,
                description: 'Добавлен материал "$newMat.name" ($quantityChange шт.)',
              ));
            },
          );
        }
      }

      for (var oldMat in oldRepair.materials) {
        if (!newMaterialQuantities.containsKey(oldMat.materialId) ||
            newMaterialQuantities[oldMat.materialId]! < oldMat.quantity) {
          // Material removed or quantity decreased
          final quantityChange = oldMat.quantity - (newMaterialQuantities[oldMat.materialId] ?? 0);
          final materialEither = await materialRepository.getMaterialById(oldMat.materialId);
          await materialEither.fold(
            (failure) => throw Exception('Material not found for return'),
            (material) async {
              final updatedMaterial = material.copyWith(quantity: material.quantity + quantityChange);
              await materialRepository.updateMaterial(updatedMaterial);
              updatedHistory.add(RepairHistory(
                id: 'history_${now.millisecondsSinceEpoch}',
                timestamp: now,
                type: HistoryType.materialRemoved,
                description: 'Удален материал "$oldMat.name" ($quantityChange шт.)',
              ));
            },
          );
        }
      }

      // Update completedAt if status changes to completed
      final finalRepair = newRepair.copyWith(
        history: updatedHistory,
        completedAt: newRepair.status == RepairStatus.completed && oldRepair.status != RepairStatus.completed
            ? now
            : newRepair.completedAt,
      );

      return await repairRepository.updateRepair(finalRepair);
    });
  }
}
