import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_history.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_part.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';

class Repair extends Equatable {
  final String id;
  final String carId;
  final String clientId;
  final RepairStatus status;
  final String description;
  final double costWork;
  final double costParts; // This will now be derived from RepairParts and RepairMaterials
  final List<RepairMaterial> materials;
  final List<RepairPart> parts; // New field for dynamic repair parts
  final List<String> photos; // List of paths to photos (similar to CarPhoto photoPath)
  final List<RepairHistory> history;
  final DateTime createdAt;
  final DateTime? plannedAt;
  final DateTime? completedAt;

  // Additional fields for display purposes, usually populated by UseCases
  final String? carMake;
  final String? carModel;
  final String? carPlate;
  final String? clientName;

  double get totalCost => costWork + costParts + materials.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get materialsCost => materials.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get partsCost => parts.fold(0.0, (sum, item) => sum + item.cost);
  double get profit => totalCost - (materialsCost + partsCost); // Simplified profit calculation

  const Repair({
    required this.id,
    required this.carId,
    required this.clientId,
    required this.status,
    required this.description,
    required this.costWork,
    this.costParts = 0.0, // Default to 0.0, will be calculated from parts and materials
    this.materials = const [],
    this.parts = const [],
    this.photos = const [],
    this.history = const [],
    required this.createdAt,
    this.plannedAt,
    this.completedAt,
    this.carMake,
    this.carModel,
    this.carPlate,
    this.clientName,
  });

  Repair copyWith({
    String? id,
    String? carId,
    String? clientId,
    RepairStatus? status,
    String? description,
    double? costWork,
    double? costParts,
    List<RepairMaterial>? materials,
    List<RepairPart>? parts,
    List<String>? photos,
    List<RepairHistory>? history,
    DateTime? createdAt,
    DateTime? plannedAt,
    DateTime? completedAt,
    String? carMake,
    String? carModel,
    String? carPlate,
    String? clientName,
  }) {
    return Repair(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      description: description ?? this.description,
      costWork: costWork ?? this.costWork,
      costParts: costParts ?? this.costParts,
      materials: materials ?? this.materials,
      parts: parts ?? this.parts,
      photos: photos ?? this.photos,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      plannedAt: plannedAt ?? this.plannedAt,
      completedAt: completedAt ?? this.completedAt,
      carMake: carMake ?? this.carMake,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      clientName: clientName ?? this.clientName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    carId,
    clientId,
    status,
    description,
    costWork,
    costParts,
    materials,
    parts,
    photos,
    history,
    createdAt,
    plannedAt,
    completedAt,
    carMake,
    carModel,
    carPlate,
    clientName,
  ];
}