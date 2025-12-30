import 'package:equatable/equatable.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_filter.dart';

abstract class CarState extends Equatable {
  const CarState();

  @override
  List<Object?> get props => [];
}

class CarInitial extends CarState {}

class CarLoading extends CarState {
  final CarFilter? currentFilter;

  const CarLoading({this.currentFilter});

  @override
  List<Object?> get props => [currentFilter];
}

class CarLoaded extends CarState {
  final List<Car> cars;
  final String? searchQuery;
  final List<String>? availableMakes;
  final List<String>? availableModels;
  final CarFilter filter;

  const CarLoaded({
    required this.cars,
    this.searchQuery,
    this.availableMakes,
    this.availableModels,
    this.filter = const CarFilter(),
  });

  @override
  List<Object?> get props => [
    cars,
    searchQuery,
    availableMakes,
    availableModels,
    filter,
  ];

  CarLoaded copyWith({
    List<Car>? cars,
    String? searchQuery,
    List<String>? availableMakes,
    List<String>? availableModels,
    CarFilter? filter,
  }) {
    return CarLoaded(
      cars: cars ?? this.cars,
      searchQuery: searchQuery ?? this.searchQuery,
      availableMakes: availableMakes ?? this.availableMakes,
      availableModels: availableModels ?? this.availableModels,
      filter: filter ?? this.filter,
    );
  }
}

class CarError extends CarState {
  final String message;

  const CarError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarOperationSuccess extends CarState {
  final String message;

  const CarOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarMakesLoaded extends CarState {
  final List<String> makes;

  const CarMakesLoaded({required this.makes});

  @override
  List<Object?> get props => [makes];
}

class CarModelsLoaded extends CarState {
  final List<String> models;

  const CarModelsLoaded({required this.models});

  @override
  List<Object?> get props => [models];
}
