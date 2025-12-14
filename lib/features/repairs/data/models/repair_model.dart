import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';
import 'repair_history_model.dart';
import 'repair_material_model.dart';
import 'repair_part_model.dart';

class RepairModel extends Repair {
  const RepairModel({
    required super.id,
    required super.carId,
    required super.clientId,
    required super.status,
    required super.description,
    required super.costWork,
    super.costParts,
    super.materials,
    super.parts,
    super.photos,
    super.history,
    required super.createdAt,
    super.plannedAt,
    super.completedAt,
    super.carMake,
    super.carModel,
    super.carPlate,
    super.clientName,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      clientId: json['clientId'] as String,
      status: RepairStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => RepairStatus.inProgress,
      ),
      description: json['description'] as String,
      costWork: json['costWork'] as double,
      costParts: json['costParts'] as double,
      materials: (json['materials'] as List<dynamic>)
          .map((e) => RepairMaterialModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      parts: (json['parts'] as List<dynamic>)
          .map((e) => RepairPartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
      history: (json['history'] as List<dynamic>)
          .map((e) => RepairHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      plannedAt: json['plannedAt'] != null
          ? DateTime.parse(json['plannedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      carMake: json['carMake'] as String?,
      carModel: json['carModel'] as String?,
      carPlate: json['carPlate'] as String?,
      clientName: json['clientName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'clientId': clientId,
      'status': status.toString(),
      'description': description,
      'costWork': costWork,
      'costParts': costParts,
      'materials': materials.map((e) => RepairMaterialModel.fromEntity(e).toJson()).toList(),
      'parts': parts.map((e) => RepairPartModel.fromEntity(e).toJson()).toList(),
      'photos': photos,
      'history': history.map((e) => RepairHistoryModel.fromEntity(e).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'plannedAt': plannedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'carMake': carMake,
      'carModel': carModel,
      'carPlate': carPlate,
      'clientName': clientName,
    };
  }

  factory RepairModel.fromEntity(Repair repair) {
    return RepairModel(
      id: repair.id,
      carId: repair.carId,
      clientId: repair.clientId,
      status: repair.status,
      description: repair.description,
      costWork: repair.costWork,
      costParts: repair.costParts,
      materials: repair.materials,
      parts: repair.parts,
      photos: repair.photos,
      history: repair.history,
      createdAt: repair.createdAt,
      plannedAt: repair.plannedAt,
      completedAt: repair.completedAt,
      carMake: repair.carMake,
      carModel: repair.carModel,
      carPlate: repair.carPlate,
      clientName: repair.clientName,
    );
  }
}
