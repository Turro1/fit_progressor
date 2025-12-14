import '../../domain/entities/material.dart';

class MaterialModel extends Material {
  const MaterialModel({
    required String id,
    required String name,
    required double quantity,
    required MaterialUnit unit,
    required double minQuantity,
    required double cost,
    required DateTime? createdAt,
  }) : super(
          id: id,
          name: name,
          quantity: quantity,
          unit: unit,
          minQuantity: minQuantity,
          cost: cost,
          createdAt: createdAt,
        );

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: MaterialUnit.values.firstWhere((e) => e.toString() == json['unit']),
      minQuantity: (json['minQuantity'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit.toString(),
      'minQuantity': minQuantity,
      'cost': cost,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MaterialModel.fromEntity(Material material) {
    return MaterialModel(
      id: material.id,
      name: material.name,
      quantity: material.quantity,
      unit: material.unit,
      minQuantity: material.minQuantity,
      cost: material.cost,
      createdAt: material.createdAt,
    );
  }
}
