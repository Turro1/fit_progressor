import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_filter.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';

abstract class RepairsEvent extends Equatable {
  const RepairsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepairs extends RepairsEvent {
  final String? carId;
  final String? clientId;

  const LoadRepairs({this.carId, this.clientId});

  @override
  List<Object?> get props => [carId, clientId];
}

class AddRepairEvent extends RepairsEvent {
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
  final List<RepairMaterial> materials;

  const AddRepairEvent({
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
    this.materials = const [],
  });

  @override
  List<Object?> get props => [
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
    materials,
  ];
}

class UpdateRepairEvent extends RepairsEvent {
  final Repair repair;

  const UpdateRepairEvent({required this.repair});

  @override
  List<Object?> get props => [repair];
}

class DeleteRepairEvent extends RepairsEvent {
  final String repairId;

  const DeleteRepairEvent({required this.repairId});

  @override
  List<Object?> get props => [repairId];
}

class SearchRepairsEvent extends RepairsEvent {
  final String query;
  final String? carId;

  const SearchRepairsEvent({required this.query, this.carId});

  @override
  List<Object?> get props => [query, carId];
}

class FilterRepairsEvent extends RepairsEvent {
  final RepairFilter filter;

  const FilterRepairsEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class ClearFiltersEvent extends RepairsEvent {
  const ClearFiltersEvent();
}
