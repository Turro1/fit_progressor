import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

class RepairModel extends Repair {
  const RepairModel({
    required super.id,
    required super.partType,
    required super.partPosition,
    super.photoPaths = const [],
    super.description = '',
    required super.date,
    required super.cost,
    required super.clientId,
    required super.carId,
    super.carMake = '',
    super.carModel = '',
    required super.createdAt,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] as String,
      partType: json['partType'] as String,
      partPosition: json['partPosition'] as String,
      photoPaths: (json['photoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      cost: (json['cost'] as num).toDouble(),
      clientId: json['clientId'] as String,
      carId: json['carId'] as String,
      carMake: json['carMake'] as String? ?? '',
      carModel: json['carModel'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RepairModel.fromEntity(Repair repair) {
    return RepairModel(
      id: repair.id,
      partType: repair.partType,
      partPosition: repair.partPosition,
      photoPaths: repair.photoPaths,
      description: repair.description,
      date: repair.date,
      cost: repair.cost,
      clientId: repair.clientId,
      carId: repair.carId,
      carMake: repair.carMake,
      carModel: repair.carModel,
      createdAt: repair.createdAt,
    );
  }
}