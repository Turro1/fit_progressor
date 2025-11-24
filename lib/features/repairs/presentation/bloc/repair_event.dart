import 'package:equatable/equatable.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';

abstract class RepairEvent extends Equatable {
  const RepairEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepairs extends RepairEvent {}

class AddRepairEvent extends RepairEvent {
  final String carId;
  final RepairStatus status;
  final String description;
  final double costWork;

  const AddRepairEvent({
    required this.carId,
    required this.status,
    required this.description,
    required this.costWork,
  });

  @override
  List<Object?> get props => [carId, status, description, costWork];
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