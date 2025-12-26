import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_filter.dart';

abstract class RepairsState extends Equatable {
  const RepairsState();

  @override
  List<Object?> get props => [];
}

class RepairsInitial extends RepairsState {}

class RepairsLoading extends RepairsState {
  /// Сохраняем текущий фильтр во время загрузки
  final RepairFilter? currentFilter;

  const RepairsLoading({this.currentFilter});

  @override
  List<Object?> get props => [currentFilter];
}

class RepairsLoaded extends RepairsState {
  final List<Repair> repairs;
  final List<Repair> allRepairs; // Все ремонты до фильтрации
  final String? searchQuery;
  final String? filterCarId;
  final RepairFilter filter;

  const RepairsLoaded({
    required this.repairs,
    this.allRepairs = const [],
    this.searchQuery,
    this.filterCarId,
    this.filter = const RepairFilter(),
  });

  @override
  List<Object?> get props => [repairs, allRepairs, searchQuery, filterCarId, filter];

  RepairsLoaded copyWith({
    List<Repair>? repairs,
    List<Repair>? allRepairs,
    String? searchQuery,
    String? filterCarId,
    RepairFilter? filter,
  }) {
    return RepairsLoaded(
      repairs: repairs ?? this.repairs,
      allRepairs: allRepairs ?? this.allRepairs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCarId: filterCarId ?? this.filterCarId,
      filter: filter ?? this.filter,
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
