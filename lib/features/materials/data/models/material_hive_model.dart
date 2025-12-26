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

  MaterialHiveModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitIndex,
    required this.minQuantity,
    required this.cost,
    required this.createdAt,
  });

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
    );
  }

  @override
  void write(BinaryWriter writer, MaterialHiveModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.createdAt);
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
