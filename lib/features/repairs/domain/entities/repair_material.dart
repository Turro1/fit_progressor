import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';

class RepairMaterial extends Equatable {
  final String materialId;
  final String materialName;
  final double quantity;
  final MaterialUnit unit;
  final double unitCost;

  const RepairMaterial({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  double get totalCost => quantity * unitCost;

  @override
  List<Object?> get props => [
        materialId,
        materialName,
        quantity,
        unit,
        unitCost,
      ];

  RepairMaterial copyWith({
    String? materialId,
    String? materialName,
    double? quantity,
    MaterialUnit? unit,
    double? unitCost,
  }) {
    return RepairMaterial(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}
