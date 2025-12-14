import 'package:fit_progressor/shared/domain/entities/entity.dart';

enum MaterialUnit {
  pcs, // штуки
  l, // литры
  kg, // килограммы
  m, // метры
  kit, // комплект
}

extension MaterialUnitExtension on MaterialUnit {
  String get displayName {
    switch (this) {
      case MaterialUnit.pcs:
        return 'шт';
      case MaterialUnit.l:
        return 'л';
      case MaterialUnit.kg:
        return 'кг';
      case MaterialUnit.m:
        return 'м';
      case MaterialUnit.kit:
        return 'к-т';
    }
  }
}

class Material extends Entity {
  final String name;
  final double quantity;
  final MaterialUnit unit;
  final double minQuantity;
  final double cost;

  const Material({
    required String id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    required this.cost,
    DateTime? createdAt,
  }) : super(id: id, createdAt: createdAt);

  bool get isLowStock => quantity > 0 && quantity <= minQuantity;
  bool get isOutOfStock => quantity <= 0;

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    unit,
    minQuantity,
    cost,
    createdAt,
  ];

  Material copyWith({
    String? id,
    String? name,
    double? quantity,
    MaterialUnit? unit,
    double? minQuantity,
    double? cost,
    DateTime? createdAt,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minQuantity: minQuantity ?? this.minQuantity,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
