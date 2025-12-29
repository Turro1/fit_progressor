import 'package:hive/hive.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';

/// Hive model for RepairMaterial
class RepairMaterialHiveModel extends HiveObject {
  String materialId;
  String materialName;
  double quantity;
  int unitIndex; // MaterialUnit as int
  double unitCost;

  RepairMaterialHiveModel({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unitIndex,
    required this.unitCost,
  });

  /// Convert from domain entity
  factory RepairMaterialHiveModel.fromEntity(RepairMaterial entity) {
    return RepairMaterialHiveModel(
      materialId: entity.materialId,
      materialName: entity.materialName,
      quantity: entity.quantity,
      unitIndex: entity.unit.index,
      unitCost: entity.unitCost,
    );
  }

  /// Convert to domain entity
  RepairMaterial toEntity() {
    return RepairMaterial(
      materialId: materialId,
      materialName: materialName,
      quantity: quantity,
      unit: MaterialUnit.values[unitIndex],
      unitCost: unitCost,
    );
  }

  /// Serialize to JSON for sync
  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unitIndex': unitIndex,
      'unitCost': unitCost,
    };
  }

  /// Deserialize from JSON for sync
  factory RepairMaterialHiveModel.fromJson(Map<String, dynamic> json) {
    return RepairMaterialHiveModel(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitIndex: json['unitIndex'] as int,
      unitCost: (json['unitCost'] as num).toDouble(),
    );
  }
}

/// Manual adapter for RepairMaterialHiveModel
class RepairMaterialHiveModelAdapter extends TypeAdapter<RepairMaterialHiveModel> {
  @override
  final int typeId = HiveTypeIds.repairMaterial;

  @override
  RepairMaterialHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepairMaterialHiveModel(
      materialId: fields[0] as String,
      materialName: fields[1] as String,
      quantity: fields[2] as double,
      unitIndex: fields[3] as int,
      unitCost: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RepairMaterialHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.materialId)
      ..writeByte(1)
      ..write(obj.materialName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitIndex)
      ..writeByte(4)
      ..write(obj.unitCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairMaterialHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
