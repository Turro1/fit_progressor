import 'package:hive/hive.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';

/// Hive model for Car
class CarHiveModel extends HiveObject {
  String id;
  String clientId;
  String make;
  String model;
  String plate;
  String clientName;
  DateTime createdAt;

  // Sync fields
  int version;
  DateTime updatedAt;
  String? lastSyncDeviceId;

  CarHiveModel({
    required this.id,
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
    required this.clientName,
    required this.createdAt,
    this.version = 1,
    DateTime? updatedAt,
    this.lastSyncDeviceId,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert from domain entity
  factory CarHiveModel.fromEntity(Car entity) {
    return CarHiveModel(
      id: entity.id,
      clientId: entity.clientId,
      make: entity.make,
      model: entity.model,
      plate: entity.plate,
      clientName: entity.clientName,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
  }

  /// Convert to domain entity
  Car toEntity() {
    return Car(
      id: id,
      clientId: clientId,
      make: make,
      model: model,
      plate: plate,
      clientName: clientName,
      createdAt: createdAt,
    );
  }

  /// Serialize to JSON for sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'make': make,
      'model': model,
      'plate': plate,
      'clientName': clientName,
      'createdAt': createdAt.toIso8601String(),
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncDeviceId': lastSyncDeviceId,
    };
  }

  /// Deserialize from JSON for sync
  factory CarHiveModel.fromJson(Map<String, dynamic> json) {
    return CarHiveModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      plate: json['plate'] as String,
      clientName: json['clientName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncDeviceId: json['lastSyncDeviceId'] as String?,
    );
  }
}

/// Manual adapter for CarHiveModel
class CarHiveModelAdapter extends TypeAdapter<CarHiveModel> {
  @override
  final int typeId = HiveTypeIds.car;

  @override
  CarHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarHiveModel(
      id: fields[0] as String,
      clientId: fields[1] as String,
      make: fields[2] as String,
      model: fields[3] as String,
      plate: fields[4] as String,
      clientName: fields[5] as String,
      createdAt: fields[6] as DateTime,
      version: fields[7] as int? ?? 1,
      updatedAt: fields[8] as DateTime?,
      lastSyncDeviceId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CarHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.make)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.plate)
      ..writeByte(5)
      ..write(obj.clientName)
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
      other is CarHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
