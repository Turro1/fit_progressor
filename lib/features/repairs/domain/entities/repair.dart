import 'package:fit_progressor/features/repairs/domain/entities/repair_history.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_photo.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';

class Repair {
  final String id;
  final String carId;
  final RepairStatus status;
  final String description;
  final double costWork; // Стоимость работ
  final double costParts; // Продажная стоимость запчастей
  final double costPartsCost; // Закупочная стоимость запчастей
  final double materialsCost; // Себестоимость материалов
  final List<RepairMaterial> materials;
  final List<RepairPhoto> photos;
  final List<RepairHistory> history;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Repair({
    required this.id,
    required this.carId,
    required this.status,
    required this.description,
    this.costWork = 0,
    this.costParts = 0,
    this.costPartsCost = 0,
    this.materialsCost = 0,
    required this.materials,
    required this.photos,
    required this.history,
    required this.createdAt,
    this.updatedAt,
  });

  // Итоговая стоимость для клиента
  double get totalCost => costWork + costParts;
  
  // Общая себестоимость
  double get totalCostPrice => costPartsCost + materialsCost;
  
  // Чистая прибыль
  double get netProfit => totalCost - totalCostPrice;

  Repair copyWith({
    String? id,
    String? carId,
    RepairStatus? status,
    String? description,
    double? costWork,
    double? costParts,
    double? costPartsCost,
    double? materialsCost,
    List<RepairMaterial>? materials,
    List<RepairPhoto>? photos,
    List<RepairHistory>? history,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Repair(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      status: status ?? this.status,
      description: description ?? this.description,
      costWork: costWork ?? this.costWork,
      costParts: costParts ?? this.costParts,
      costPartsCost: costPartsCost ?? this.costPartsCost,
      materialsCost: materialsCost ?? this.materialsCost,
      materials: materials ?? this.materials,
      photos: photos ?? this.photos,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}