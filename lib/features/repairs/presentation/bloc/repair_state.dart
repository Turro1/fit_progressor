import 'package:equatable/equatable.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';

abstract class RepairState extends Equatable {
  const RepairState();

  @override
  List<Object?> get props => [];
}

class RepairInitial extends RepairState {}

class RepairLoading extends RepairState {}

class RepairLoaded extends RepairState {
  final List<Repair> repairs;
  final String? searchQuery;
  final RepairStatus? statusFilter;

  const RepairLoaded({
    required this.repairs,
    this.searchQuery,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [repairs, searchQuery, statusFilter];

  RepairLoaded copyWith({
    List<Repair>? repairs,
    String? searchQuery,
    RepairStatus? statusFilter,
  }) {
    return RepairLoaded(
      repairs: repairs ?? this.repairs,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class RepairError extends RepairState {
  final String message;

  const RepairError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RepairOperationSuccess extends RepairState {
  final String message;

  const RepairOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}