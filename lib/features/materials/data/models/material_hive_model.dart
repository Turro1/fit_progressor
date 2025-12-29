import 'package:hive/hive.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';

/// Hive model for Material (inventory)
class MaterialHiveModel extends HiveObject {
  String id;
  String name;
  double quantity;
  int unitIndex; // MaterialUnit as int
  double minQuantity;
  double cost;
  DateTime createdAt;

  // Sync fields
  int version;
  DateTime updatedAt;
  String? lastSyncDeviceId;

  MaterialHiveModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitIndex,
    required this.minQuantity,
    required this.cost,
    required this.createdAt,
    this.version = 1,
    DateTime? updatedAt,
    this.lastSyncDeviceId,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert from domain entity
  factory MaterialHiveModel.fromEntity(Material entity) {
    return MaterialHiveModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      unitIndex: entity.unit.index,
      minQuantity: entity.minQuantity,
      cost: entity.cost,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
  }

  /// Convert to domain entity
  Material toEntity() {
    return Material(
      id: id,
      name: name,
      quantity: quantity,
      unit: MaterialUnit.values[unitIndex],
      minQuantity: minQuantity,
      cost: cost,
      createdAt: createdAt,
    );
  }

  /// Serialize to JSON for sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unitIndex': unitIndex,
      'minQuantity': minQuantity,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncDeviceId': lastSyncDeviceId,
    };
  }

  /// Deserialize from JSON for sync
  factory MaterialHiveModel.fromJson(Map<String, dynamic> json) {
    return MaterialHiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitIndex: json['unitIndex'] as int,
      minQuantity: (json['minQuantity'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncDeviceId: json['lastSyncDeviceId'] as String?,
    );
  }
}

/// Manual adapter for MaterialUnit enum
class MaterialUnitHiveAdapter extends TypeAdapter<MaterialUnit> {
  @override
  final int typeId = HiveTypeIds.materialUnit;

  @override
  MaterialUnit read(BinaryReader reader) {
    return MaterialUnit.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MaterialUnit obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialUnitHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Manual adapter for MaterialHiveModel
class MaterialHiveModelAdapter extends TypeAdapter<MaterialHiveModel> {
  @override
  final int typeId = HiveTypeIds.material;

  @override
  MaterialHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as double,
      unitIndex: fields[3] as int,
      minQuantity: fields[4] as double,
      cost: fields[5] as double,
      createdAt: fields[6] as DateTime,
      version: fields[7] as int? ?? 1,
      updatedAt: fields[8] as DateTime?,
      lastSyncDeviceId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitIndex)
      ..writeByte(4)
      ..write(obj.minQuantity)
      ..writeByte(5)
      ..write(obj.cost)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.version)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.lastSyncDeviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
