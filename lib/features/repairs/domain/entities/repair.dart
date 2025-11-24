import 'package:equatable/equatable.dart';
import 'repair_material.dart';
import 'repair_history.dart';
import 'repair_status.dart';

class Repair extends Equatable {
  final String id;
  final String carId;
  final RepairStatus status;
  final String description;
  final double costWork;
  final double costParts;
  final double costPartsCost;
  final List<RepairMaterial> materials;
  final double materialsCost;
  final List<String> photos; // Base64 strings
  final List<RepairHistory> history;
  final DateTime createdAt;

  const Repair({
    required this.id,
    required this.carId,
    required this.status,
    required this.description,
    required this.costWork,
    required this.costParts,
    required this.costPartsCost,
    required this.materials,
    required this.materialsCost,
    required this.photos,
    required this.history,
    required this.createdAt,
  });

  double get totalCost => costWork + costParts;
  double get totalExpenses => costPartsCost + materialsCost;
  double get profit => totalCost - totalExpenses;

  @override
  List<Object?> get props => [
        id,
        carId,
        status,
        description,
        costWork,
        costParts,
        costPartsCost,
        materials,
        materialsCost,
        photos,
        history,
        createdAt,
      ];

  Repair copyWith({
    String? id,
    String? carId,
    RepairStatus? status,
    String? description,
    double? costWork,
    double? costParts,
    double? costPartsCost,
    List<RepairMaterial>? materials,
    double? materialsCost,
    List<String>? photos,
    List<RepairHistory>? history,
    DateTime? createdAt,
  }) {
    return Repair(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      status: status ?? this.status,
      description: description ?? this.description,
      costWork: costWork ?? this.costWork,
      costParts: costParts ?? this.costParts,
      costPartsCost: costPartsCost ?? this.costPartsCost,
      materials: materials ?? this.materials,
      materialsCost: materialsCost ?? this.materialsCost,
      photos: photos ?? this.photos,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}