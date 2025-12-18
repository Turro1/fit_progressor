import 'package:fit_progressor/features/cars/domain/entities/car.dart';

class CarModel extends Car {
  const CarModel({
    required super.id,
    required super.clientId,
    required super.make,
    required super.model,
    required super.plate,
    super.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final String id =
        json['id'] as String? ?? (throw const FormatException('Missing id'));
    final String clientId = json['clientId'] as String? ?? '';
    final String make = json['make'] as String? ?? '';
    final String model = json['model'] as String? ?? '';
    final String plate = json['plate'] as String? ?? '';
    final DateTime? createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null;

    return CarModel(
      id: id,
      clientId: clientId,
      make: make,
      model: model,
      plate: plate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'make': make,
      'model': model,
      'plate': plate,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CarModel.fromEntity(Car client) {
    return CarModel(
      id: client.id,
      clientId: client.clientId,
      make: client.make,
      model: client.model,
      plate: client.plate,
      createdAt: client.createdAt,
    );
  }
}
