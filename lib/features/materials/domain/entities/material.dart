// Материал/Запчасть
import 'package:fit_progressor/shared/domain/entities/entity.dart';

class Material extends Entity {
  final String name;
  final double quantity;
  final String unit;
  final double minQuantity;
  final double cost; // Закупочная цена
  final DateTime createdAt;

  const Material({
    required String id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    required this.cost,
    required this.createdAt,
  }) : super(id: id);

  // Вспомогательные геттеры для бизнес-логики
  bool get isLowStock => quantity < minQuantity;
  bool get isOutOfStock => quantity <= 0;

  Material copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
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