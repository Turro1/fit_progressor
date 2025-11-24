import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';
import 'repair_material_model.dart';
import 'repair_history_model.dart';

class RepairModel extends Repair {
  const RepairModel({
    required super.id,
    required super.carId,
    required super.status,
    required super.description,
    required super.costWork,
    required super.costParts,
    required super.costPartsCost,
    required super.materials,
    required super.materialsCost,
    required super.photos,
    required super.history,
    required super.createdAt,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      status: RepairStatus.fromString(json['status'] as String),
      description: json['description'] as String,
      costWork: (json['costWork'] as num).toDouble(),
      costParts: (json['costParts'] as num).toDouble(),
      costPartsCost: (json['costPartsCost'] as num).toDouble(),
      materials: (json['materials'] as List<dynamic>)
          .map((e) => RepairMaterialModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      materialsCost: (json['materialsCost'] as num).toDouble(),
      photos: (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
      history: (json['history'] as List<dynamic>)
          .map((e) => RepairHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'status': status.displayName,
      'description': description,
      'costWork': costWork,
      'costParts': costParts,
      'costPartsCost': costPartsCost,
      'materials': materials
          .map((m) => RepairMaterialModel.fromEntity(m).toJson())
          .toList(),
      'materialsCost': materialsCost,
      'photos': photos,
      'history':
          history.map((h) => RepairHistoryModel.fromEntity(h).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RepairModel.fromEntity(Repair repair) {
    return RepairModel(
      id: repair.id,
      carId: repair.carId,
      status: repair.status,
      description: repair.description,
      costWork: repair.costWork,
      costParts: repair.costParts,
      costPartsCost: repair.costPartsCost,
      materials: repair.materials,
      materialsCost: repair.materialsCost,
      photos: repair.photos,
      history: repair.history,
      createdAt: repair.createdAt,
    );
  }
}