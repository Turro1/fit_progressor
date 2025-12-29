import 'package:hive/hive.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_material_hive_model.dart';

/// Hive model for Repair
class RepairHiveModel extends HiveObject {
  String id;
  String partType;
  String partPosition;
  List<String> photoPaths;
  String description;
  DateTime date;
  double cost;
  String clientId;
  String carId;
  String carMake;
  String carModel;
  int statusIndex; // RepairStatus as int
  DateTime createdAt;
  List<RepairMaterialHiveModel> materials;

  // Sync fields
  int version;
  DateTime updatedAt;
  String? lastSyncDeviceId;

  RepairHiveModel({
    required this.id,
    required this.partType,
    required this.partPosition,
    required this.photoPaths,
    required this.description,
    required this.date,
    required this.cost,
    required this.clientId,
    required this.carId,
    required this.carMake,
    required this.carModel,
    required this.statusIndex,
    required this.createdAt,
    required this.materials,
    this.version = 1,
    DateTime? updatedAt,
    this.lastSyncDeviceId,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert from domain entity
  factory RepairHiveModel.fromEntity(Repair entity) {
    return RepairHiveModel(
      id: entity.id,
      partType: entity.partType,
      partPosition: entity.partPosition,
      photoPaths: List<String>.from(entity.photoPaths),
      description: entity.description,
      date: entity.date,
      cost: entity.cost,
      clientId: entity.clientId,
      carId: entity.carId,
      carMake: entity.carMake,
      carModel: entity.carModel,
      statusIndex: entity.status.index,
      createdAt: entity.createdAt,
      materials: entity.materials
          .map((m) => RepairMaterialHiveModel.fromEntity(m))
          .toList(),
    );
  }

  /// Convert to domain entity
  Repair toEntity() {
    return Repair(
      id: id,
      partType: partType,
      partPosition: partPosition,
      photoPaths: List<String>.from(photoPaths),
      description: description,
      date: date,
      cost: cost,
      clientId: clientId,
      carId: carId,
      carMake: carMake,
      carModel: carModel,
      status: RepairStatus.values[statusIndex],
      createdAt: createdAt,
      materials: materials.map((m) => m.toEntity()).toList(),
    );
  }

  /// Serialize to JSON for sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partType': partType,
      'partPosition': partPosition,
      'photoPaths': photoPaths,
      'description': description,
      'date': date.toIso8601String(),
      'cost': cost,
      'clientId': clientId,
      'carId': carId,
      'carMake': carMake,
      'carModel': carModel,
      'statusIndex': statusIndex,
      'createdAt': createdAt.toIso8601String(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncDeviceId': lastSyncDeviceId,
    };
  }

  /// Deserialize from JSON for sync
  factory RepairHiveModel.fromJson(Map<String, dynamic> json) {
    return RepairHiveModel(
      id: json['id'] as String,
      partType: json['partType'] as String,
      partPosition: json['partPosition'] as String,
      photoPaths: (json['photoPaths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      cost: (json['cost'] as num).toDouble(),
      clientId: json['clientId'] as String,
      carId: json['carId'] as String,
      carMake: json['carMake'] as String,
      carModel: json['carModel'] as String,
      statusIndex: json['statusIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      materials: (json['materials'] as List<dynamic>)
          .map((m) =>
              RepairMaterialHiveModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncDeviceId: json['lastSyncDeviceId'] as String?,
    );
  }
}

/// Manual adapter for RepairStatus enum
class RepairStatusHiveAdapter extends TypeAdapter<RepairStatus> {
  @override
  final int typeId = HiveTypeIds.repairStatus;

  @override
  RepairStatus read(BinaryReader reader) {
    return RepairStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, RepairStatus obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Manual adapter for RepairHiveModel
class RepairHiveModelAdapter extends TypeAdapter<RepairHiveModel> {
  @override
  final int typeId = HiveTypeIds.repair;

  @override
  RepairHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepairHiveModel(
      id: fields[0] as String,
      partType: fields[1] as String,
      partPosition: fields[2] as String,
      photoPaths: (fields[3] as List).cast<String>(),
      description: fields[4] as String,
      date: fields[5] as DateTime,
      cost: fields[6] as double,
      clientId: fields[7] as String,
      carId: fields[8] as String,
      carMake: fields[9] as String,
      carModel: fields[10] as String,
      statusIndex: fields[11] as int,
      createdAt: fields[12] as DateTime,
      materials: (fields[13] as List).cast<RepairMaterialHiveModel>(),
      version: fields[14] as int? ?? 1,
      updatedAt: fields[15] as DateTime?,
      lastSyncDeviceId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RepairHiveModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.partType)
      ..writeByte(2)
      ..write(obj.partPosition)
      ..writeByte(3)
      ..write(obj.photoPaths)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.cost)
      ..writeByte(7)
      ..write(obj.clientId)
      ..writeByte(8)
      ..write(obj.carId)
      ..writeByte(9)
      ..write(obj.carMake)
      ..writeByte(10)
      ..write(obj.carModel)
      ..writeByte(11)
      ..write(obj.statusIndex)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.materials)
      ..writeByte(14)
      ..write(obj.version)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.lastSyncDeviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
