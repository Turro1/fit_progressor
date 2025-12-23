import 'package:equatable/equatable.dart';

class Repair extends Equatable {
  final String id;
  final String partType;
  final String partPosition;
  final List<String> photoPaths;
  final String description;
  final DateTime date;
  final double cost;
  final String clientId;
  final String carId;
  final String carMake;
  final String carModel;
  final DateTime createdAt;

  const Repair({
    required this.id,
    required this.partType,
    required this.partPosition,
    this.photoPaths = const [],
    this.description = '',
    required this.date,
    required this.cost,
    required this.clientId,
    required this.carId,
    this.carMake = '',
    this.carModel = '',
    required this.createdAt,
  });

  String get name => '$partType $partPosition';

  @override
  List<Object?> get props => [
    id,
    partType,
    partPosition,
    photoPaths,
    description,
    date,
    cost,
    clientId,
    carId,
    carMake,
    carModel,
    createdAt,
  ];

  Repair copyWith({
    String? id,
    String? partType,
    String? partPosition,
    List<String>? photoPaths,
    String? description,
    DateTime? date,
    double? cost,
    String? clientId,
    String? carId,
    String? carMake,
    String? carModel,
    DateTime? createdAt,
  }) {
    return Repair(
      id: id ?? this.id,
      partType: partType ?? this.partType,
      partPosition: partPosition ?? this.partPosition,
      photoPaths: photoPaths ?? this.photoPaths,
      description: description ?? this.description,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      clientId: clientId ?? this.clientId,
      carId: carId ?? this.carId,
      carMake: carMake ?? this.carMake,
      carModel: carModel ?? this.carModel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}