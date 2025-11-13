import 'package:fit_progressor/shared/domain/entities/entity.dart';

class RepairMaterial extends Entity{
  final String materialId;
  final double quantity;
  final double cost; // Закупочная цена на момент списания

  RepairMaterial({
    required String id,
    required this.materialId,
    required this.quantity,
    required this.cost,
  }) : super(id: id);

  // Стоимость этого материала в ремонте
  double get totalCost => cost * quantity;

  RepairMaterial copyWith({
    String? id,
    String? materialId,
    double? quantity,
    double? cost,
  }) {
    return RepairMaterial(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
    );
  }
}