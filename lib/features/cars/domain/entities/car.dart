import 'package:fit_progressor/shared/domain/entities/entity.dart';

// Автомобиль
class Car extends Entity {
  final String clientId;
  final String make;
  final String model;
  final String plate;

  const Car({
    required String id,
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
    DateTime? createdAt,
  }) : super(id: id, createdAt: createdAt);

  Car copyWith({
    String? id,
    String? clientId,
    String? make,
    String? model,
    String? plate,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      make: make ?? this.make,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [id, clientId, make, model, plate, createdAt];
}