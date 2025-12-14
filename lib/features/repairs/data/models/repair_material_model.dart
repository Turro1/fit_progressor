import '../../domain/entities/repair_material.dart';

class RepairMaterialModel extends RepairMaterial {
  const RepairMaterialModel({
    required super.materialId,
    required super.name,
    required super.quantity,
    required super.price,
  });

  factory RepairMaterialModel.fromJson(Map<String, dynamic> json) {
    return RepairMaterialModel(
      materialId: json['materialId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: json['price'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory RepairMaterialModel.fromEntity(RepairMaterial entity) {
    return RepairMaterialModel(
      materialId: entity.materialId,
      name: entity.name,
      quantity: entity.quantity,
      price: entity.price,
    );
  }
}
