import 'package:equatable/equatable.dart';
import '../../domain/entities/car.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCars extends CarEvent {}

class AddCarEvent extends CarEvent {
  final String clientId;
  final String make;
  final String model;
  final String plate;

  const AddCarEvent({
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
  });

  @override
  List<Object?> get props => [clientId, make, model, plate];
}

class UpdateCarEvent extends CarEvent {
  final Car car;

  const UpdateCarEvent({required this.car});

  @override
  List<Object?> get props => [car];
}

class DeleteCarEvent extends CarEvent {
  final String carId;

  const DeleteCarEvent({required this.carId});

  @override
  List<Object?> get props => [carId];
}

class SearchCarsEvent extends CarEvent {
  final String query;

  const SearchCarsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class LoadCarMakes extends CarEvent {}

class LoadCarModels extends CarEvent {
  final String make;

  const LoadCarModels({required this.make});

  @override
  List<Object?> get props => [make];
}
