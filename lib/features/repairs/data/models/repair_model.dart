import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

class RepairModel extends Repair {
  const RepairModel({
    required super.id,
    required super.name,
    required super.description,
    required super.date,
    required super.cost,
    required super.clientId,
    required super.carId,
    required super.createdAt,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      cost: json['cost'] as double,
      clientId: json['clientId'] as String,
      carId: json['carId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'cost': cost,
      'clientId': clientId,
      'carId': carId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RepairModel.fromEntity(Repair repair) {
    return RepairModel(
      id: repair.id,
      name: repair.name,
      description: repair.description,
      date: repair.date,
      cost: repair.cost,
      clientId: repair.clientId,
      carId: repair.carId,
      createdAt: repair.createdAt,
    );
  }
}