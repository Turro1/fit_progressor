import '../../domain/entities/repair_material.dart';

class RepairMaterialModel extends RepairMaterial {
  const RepairMaterialModel({
    required super.materialId,
    required super.quantity,
    required super.cost,
  });

  factory RepairMaterialModel.fromJson(Map<String, dynamic> json) {
    return RepairMaterialModel(
      materialId: json['materialId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'quantity': quantity,
      'cost': cost,
    };
  }

  factory RepairMaterialModel.fromEntity(RepairMaterial material) {
    return RepairMaterialModel(
      materialId: material.materialId,
      quantity: material.quantity,
      cost: material.cost,
    );
  }
}