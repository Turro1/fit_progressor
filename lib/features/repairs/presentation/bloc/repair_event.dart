import 'package:equatable/equatable.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';
import '../../domain/entities/repair_material.dart';
import '../../domain/entities/repair_part.dart';

abstract class RepairEvent extends Equatable {
  const RepairEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepairs extends RepairEvent {
  final String? carIdFilter; // Optional filter for car ID

  const LoadRepairs({this.carIdFilter});

  @override
  List<Object?> get props => [carIdFilter];
}

class AddRepairEvent extends RepairEvent {
  final String carId;
  final String clientId;
  final RepairStatus status;
  final String description;
  final double costWork;
  final List<RepairMaterial> materials;
  final List<RepairPart> parts;
  final List<String> photos;
  final DateTime? plannedAt;

  const AddRepairEvent({
    required this.carId,
    required this.clientId,
    required this.status,
    required this.description,
    required this.costWork,
    this.materials = const [],
    this.parts = const [],
    this.photos = const [],
    this.plannedAt,
  });

  @override
  List<Object?> get props => [
    carId,
    clientId,
    status,
    description,
    costWork,
    materials,
    parts,
    photos,
    plannedAt,
  ];
}

class UpdateRepairEvent extends RepairEvent {
  final Repair repair;

  const UpdateRepairEvent({required this.repair});

  @override
  List<Object?> get props => [repair];
}

class DeleteRepairEvent extends RepairEvent {
  final String repairId;

  const DeleteRepairEvent({required this.repairId});

  @override
  List<Object?> get props => [repairId];
}

class SearchRepairsEvent extends RepairEvent {
  final String query;

  const SearchRepairsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterRepairsByStatusEvent extends RepairEvent {
  final RepairStatus? status;

  const FilterRepairsByStatusEvent({this.status});

  @override
  List<Object?> get props => [status];
}
