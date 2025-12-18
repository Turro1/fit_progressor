import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

abstract class RepairsEvent extends Equatable {
  const RepairsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepairs extends RepairsEvent {
  final String? carId;

  const LoadRepairs({this.carId});

  @override
  List<Object?> get props => [carId];
}

class AddRepairEvent extends RepairsEvent {
  final String name;
  final String description;
  final DateTime date;
  final double cost;
  final String clientId;
  final String carId;

  const AddRepairEvent({
    required this.name,
    required this.description,
    required this.date,
    required this.cost,
    required this.clientId,
    required this.carId,
  });

  @override
  List<Object?> get props => [name, description, date, cost, clientId, carId];
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
