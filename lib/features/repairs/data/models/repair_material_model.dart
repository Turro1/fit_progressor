import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';

class RepairMaterialModel extends RepairMaterial {
  const RepairMaterialModel({
    required super.materialId,
    required super.materialName,
    required super.quantity,
    required super.unit,
    required super.unitCost,
  });

  factory RepairMaterialModel.fromJson(Map<String, dynamic> json) {
    return RepairMaterialModel(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: MaterialUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => MaterialUnit.pcs,
      ),
      unitCost: (json['unitCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit.name,
      'unitCost': unitCost,
    };
  }

  factory RepairMaterialModel.fromEntity(RepairMaterial material) {
    return RepairMaterialModel(
      materialId: material.materialId,
      materialName: material.materialName,
      quantity: material.quantity,
      unit: material.unit,
      unitCost: material.unitCost,
    );
  }
}
