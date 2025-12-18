import 'package:fit_progressor/shared/domain/entities/entity.dart';

// Автомобиль
class Car extends Entity {
  final String clientId;
  final String make;
  final String model;
  final String plate;
  final String clientName;

  const Car({
    required String id,
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
    this.clientName = '',
    DateTime? createdAt,
  }) : super(id: id, createdAt: createdAt);

  Car copyWith({
    String? id,
    String? clientId,
    String? make,
    String? model,
    String? plate,
    String? clientName,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      make: make ?? this.make,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fullName => '$make $model';

  @override
  List<Object?> get props => [
    id,
    clientId,
    make,
    model,
    plate,
    clientName,
    createdAt,
  ];
}
