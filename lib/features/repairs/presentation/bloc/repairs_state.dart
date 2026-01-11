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
  final List<Repair> repairs; // Отображаемые ремонты (с пагинацией)
  final List<Repair> allRepairs; // Все ремонты до фильтрации
  final List<Repair> filteredRepairs; // Все ремонты после фильтрации (для пагинации)
  final String? searchQuery;
  final String? filterCarId;
  final RepairFilter filter;
  final bool hasMore; // Есть ли ещё элементы для подгрузки
  final bool isLoadingMore; // Идёт ли подгрузка

  const RepairsLoaded({
    required this.repairs,
    this.allRepairs = const [],
    this.filteredRepairs = const [],
    this.searchQuery,
    this.filterCarId,
    this.filter = const RepairFilter(),
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        repairs,
        allRepairs,
        filteredRepairs,
        searchQuery,
        filterCarId,
        filter,
        hasMore,
        isLoadingMore,
      ];

  RepairsLoaded copyWith({
    List<Repair>? repairs,
    List<Repair>? allRepairs,
    List<Repair>? filteredRepairs,
    String? searchQuery,
    String? filterCarId,
    RepairFilter? filter,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RepairsLoaded(
      repairs: repairs ?? this.repairs,
      allRepairs: allRepairs ?? this.allRepairs,
      filteredRepairs: filteredRepairs ?? this.filteredRepairs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCarId: filterCarId ?? this.filterCarId,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
