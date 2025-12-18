import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

abstract class RepairsState extends Equatable {
  const RepairsState();

  @override
  List<Object?> get props => [];
}

class RepairsInitial extends RepairsState {}

class RepairsLoading extends RepairsState {}

class RepairsLoaded extends RepairsState {
  final List<Repair> repairs;
  final String? searchQuery;
  final String? filterCarId;

  const RepairsLoaded({
    required this.repairs,
    this.searchQuery,
    this.filterCarId,
  });

  @override
  List<Object?> get props => [repairs, searchQuery, filterCarId];

  RepairsLoaded copyWith({
    List<Repair>? repairs,
    String? searchQuery,
    String? filterCarId,
  }) {
    return RepairsLoaded(
      repairs: repairs ?? this.repairs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCarId: filterCarId ?? this.filterCarId,
    );
  }
}

class RepairsError extends RepairsState {
  final String message;

  const RepairsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RepairsOperationSuccess extends RepairsState {
  final String message;

  const RepairsOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
