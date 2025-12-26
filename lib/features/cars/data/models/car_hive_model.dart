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

  CarHiveModel({
    required this.id,
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
    required this.clientName,
    required this.createdAt,
  });

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
    );
  }

  @override
  void write(BinaryWriter writer, CarHiveModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.createdAt);
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
