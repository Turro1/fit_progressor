import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CarModel extends Car{

  @HiveField(0)
  final String clientId;

  @HiveField(1)
  final String make;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final String? plate;

  @HiveField(4)
  final DateTime createdAt;

  const CarModel({
    required String id,
    required this.clientId,
    required this.make,
    required this.model, 
    required this.plate,
    required this.createdAt
  }): super(
          id: id,
          clientId: clientId,
          make: make,
          model: model,
          plate: plate,
          createdAt: createdAt
        );

  /// Создание модели из entity
  factory CarModel.fromEntity(Car car) {
    return CarModel(
      id: car.id, 
      clientId: car.clientId, 
      make: car.make, 
      model: car.model, 
      plate: car.plate, 
      createdAt: car.createdAt);
  }

  /// Конвертация в entity
  Car toEntity() {
    return Car(
      id: id, 
      clientId: clientId, 
      make: make, 
      model: model, 
      createdAt: createdAt);
  }

  /// Из JSON (для SharedPreferences)
  factory CarModel.fromJson(Map<String, dynamic> json) {

    return CarModel(
      id: json['id'] as String,  
      clientId: json['clientId'] as String, 
      make: json['make'] as String,  
      model: json['model'] as String, 
      plate: json['plate'] as String, 
      createdAt: json['createdAt'] as DateTime);
  }

  /// В JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'make': make,
      'model': model,
      'plate': plate,
      'createdAt': createdAt
    };
  }

  /// CopyWith для удобного обновления
  CarModel copyWith({
    String? id,
    String? clientId,
    String? make,
    String? model,
    String? plate,
    DateTime? createdAt
  }) {
    return CarModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      make: make ?? this.make,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      createdAt: createdAt ?? this.createdAt
    );
  }

  @override
  String toString() => 'CarModel(id: $id, clientId: $clientId, make: $make, model: $model, plate: $plate, createdAt: $createdAt)';
}