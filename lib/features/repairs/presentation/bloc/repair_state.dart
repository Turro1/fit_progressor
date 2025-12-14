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
  final String? carIdFilter; // Added carIdFilter

  const RepairLoaded({
    required this.repairs,
    this.searchQuery,
    this.statusFilter,
    this.carIdFilter, // Added to constructor
  });

  RepairLoaded copyWith({
    List<Repair>? repairs,
    String? searchQuery,
    RepairStatus? statusFilter,
    String? carIdFilter, // Added to copyWith
  }) {
    return RepairLoaded(
      repairs: repairs ?? this.repairs,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      carIdFilter: carIdFilter ?? this.carIdFilter, // Added to copyWith
    );
  }

  @override
  List<Object?> get props => [repairs, searchQuery, statusFilter, carIdFilter]; // Added to props
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
