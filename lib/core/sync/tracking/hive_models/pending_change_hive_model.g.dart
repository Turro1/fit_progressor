// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_change_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingChangeHiveModelAdapter
    extends TypeAdapter<PendingChangeHiveModel> {
  @override
  final int typeId = 8;

  @override
  PendingChangeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingChangeHiveModel(
      changeId: fields[0] as String,
      entityId: fields[1] as String,
      entityType: fields[2] as String,
      operation: fields[3] as String,
      changedAt: fields[4] as DateTime,
      version: fields[5] as int,
      dataJson: fields[6] as String?,
      isSent: fields[7] as bool,
      sentToDevices: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingChangeHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.changeId)
      ..writeByte(1)
      ..write(obj.entityId)
      ..writeByte(2)
      ..write(obj.entityType)
      ..writeByte(3)
      ..write(obj.operation)
      ..writeByte(4)
      ..write(obj.changedAt)
      ..writeByte(5)
      ..write(obj.version)
      ..writeByte(6)
      ..write(obj.dataJson)
      ..writeByte(7)
      ..write(obj.isSent)
      ..writeByte(8)
      ..write(obj.sentToDevices)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingChangeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
