import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart'; // Using package import
import '../entities/repair.dart';
import '../entities/repair_history.dart';
import '../entities/repair_material.dart';
import '../entities/repair_part.dart';
import '../entities/repair_status.dart';
import '../repositories/repair_repository.dart';

class AddRepair implements UseCase<Repair, AddRepairParams> {
  final RepairRepository repairRepository;
  final MaterialRepository materialRepository; // For managing material stock

  AddRepair({required this.repairRepository, required this.materialRepository});

  @override
  Future<Either<Failure, Repair>> call(AddRepairParams params) async {
    final now = DateTime.now();

    // Deduct materials from stock
    for (var repairMaterial in params.materials) {
      final materialEither = await materialRepository.getMaterialById(repairMaterial.materialId);
      await materialEither.fold(
        (failure) => throw Exception('Material not found for deduction'), // Or handle failure more gracefully
        (material) async {
          final updatedMaterial = material.copyWith(quantity: material.quantity - repairMaterial.quantity);
          await materialRepository.updateMaterial(updatedMaterial);
        },
      );
    }

    final repair = Repair(
      id: 'repair_${now.millisecondsSinceEpoch}',
      carId: params.carId,
      clientId: params.clientId,
      status: params.status,
      description: params.description,
      costWork: params.costWork,
      materials: params.materials,
      parts: params.parts,
      photos: params.photos,
      history: [
        RepairHistory(
          id: 'history_${now.millisecondsSinceEpoch}',
          timestamp: now,
          type: HistoryType.statusChange,
          description: 'Ремонт создан со статусом "${params.status.displayName}"',
        )
      ],
      createdAt: now,
      plannedAt: params.plannedAt,
    );

    return await repairRepository.addRepair(repair);
  }
}

class AddRepairParams extends Equatable {
  final String carId;
  final String clientId;
  final RepairStatus status;
  final String description;
  final double costWork;
  final List<RepairMaterial> materials;
  final List<RepairPart> parts;
  final List<String> photos;
  final DateTime? plannedAt;

  const AddRepairParams({
    required this.carId,
    required this.clientId,
    required this.status,
    required this.description,
    required this.costWork,
    this.materials = const [],
    this.parts = const [],
    this.photos = const [],
    this.plannedAt,
  });

  @override
  List<Object?> get props => [
    carId,
    clientId,
    status,
    description,
    costWork,
    materials,
    parts,
    photos,
    plannedAt,
  ];
}
