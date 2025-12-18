import 'package:equatable/equatable.dart';

class Repair extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final double cost;
  final String clientId;
  final String carId;
  final DateTime createdAt;

  const Repair({
    required this.id,
    required this.name,
    this.description = '',
    required this.date,
    required this.cost,
    required this.clientId,
    required this.carId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    date,
    cost,
    clientId,
    carId,
    createdAt,
  ];

  Repair copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    double? cost,
    String? clientId,
    String? carId,
    DateTime? createdAt,
  }) {
    return Repair(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      clientId: clientId ?? this.clientId,
      carId: carId ?? this.carId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}