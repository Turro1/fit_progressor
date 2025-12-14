import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_car.dart';
import '../../domain/usecases/delete_car.dart';
import '../../domain/usecases/get_car_makes.dart';
import '../../domain/usecases/get_car_models.dart';
import '../../domain/usecases/get_cars.dart';
import '../../domain/usecases/search_cars.dart';
import '../../domain/usecases/update_car.dart';
import 'car_event.dart';
import 'car_state.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCars;
  final AddCar addCar;
  final UpdateCar updateCar;
  final DeleteCar deleteCar;
  final SearchCars searchCars;
  final GetCarMakes getCarMakes;
  final GetCarModels getCarModels;

  CarBloc({
    required this.getCars,
    required this.addCar,
    required this.updateCar,
    required this.deleteCar,
    required this.searchCars,
    required this.getCarMakes,
    required this.getCarModels,
  }) : super(CarInitial()) {
    on<LoadCars>(_onLoadCars);
    on<AddCarEvent>(_onAddCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<SearchCarsEvent>(_onSearchCars);
    on<LoadCarMakes>(_onLoadCarMakes);
    on<LoadCarModels>(_onLoadCarModels);
  }

  Future<void> _onLoadCars(LoadCars event, Emitter<CarState> emit) async {
    debugPrint('DEBUG: CarBloc - _onLoadCars event received.');
    emit(CarLoading());
    try {
      final result = await getCars(NoParams());
      result.fold(
        (failure) {
          debugPrint('DEBUG: CarBloc - _onLoadCars failed: $failure');
          emit(const CarError(message: 'Не удалось загрузить автомобили'));
        },
        (cars) {
          debugPrint('DEBUG: CarBloc - _onLoadCars loaded ${cars.length} cars.');
          emit(CarLoaded(cars: cars));
        },
      );
    } catch (e) {
      debugPrint('DEBUG: CarBloc - _onLoadCars caught exception: $e');
      emit(CarError(message: 'Произошла ошибка при загрузке автомобилей: $e'));
    }
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    final params = AddCarParams(
      clientId: event.clientId,
      make: event.make,
      model: event.model,
      plate: event.plate,
    );
    final result = await addCar(params);

    await result.fold(
      (failure) async {
        emit(const CarError(message: 'Не удалось добавить автомобиль'));
      },
      (car) async {
        emit(const CarOperationSuccess(message: 'Автомобиль добавлен'));
        add(LoadCars());
      },
    );
  }

  Future<void> _onUpdateCar(
    UpdateCarEvent event,
    Emitter<CarState> emit,
  ) async {
    emit(CarLoading());
    final result = await updateCar(event.car);

    await result.fold(
      (failure) async {
        emit(const CarError(message: 'Не удалось обновить автомобиль'));
      },
      (car) async {
        emit(const CarOperationSuccess(message: 'Автомобиль обновлен'));
        add(LoadCars());
      },
    );
  }

  Future<void> _onDeleteCar(
    DeleteCarEvent event,
    Emitter<CarState> emit,
  ) async {
    emit(CarLoading());
    final result = await deleteCar(event.carId);

    await result.fold(
      (failure) async {
        emit(const CarError(message: 'Не удалось удалить автомобиль'));
      },
      (_) async {
        emit(const CarOperationSuccess(message: 'Автомобиль удален'));
        add(LoadCars());
      },
    );
  }

  Future<void> _onSearchCars(
    SearchCarsEvent event,
    Emitter<CarState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadCars());
      return;
    }

    emit(CarLoading());
    final result = await searchCars(event.query);
    result.fold(
      (failure) => emit(const CarError(message: 'Ошибка поиска')),
      (cars) => emit(CarLoaded(cars: cars, searchQuery: event.query)),
    );
  }

  Future<void> _onLoadCarMakes(
    LoadCarMakes event,
    Emitter<CarState> emit,
  ) async {
    final result = await getCarMakes(NoParams());
    result.fold(
      (failure) => emit(const CarError(message: 'Не удалось загрузить марки')),
      (makes) => emit(CarMakesLoaded(makes: makes)),
    );
  }

  Future<void> _onLoadCarModels(
    LoadCarModels event,
    Emitter<CarState> emit,
  ) async {
    final result = await getCarModels(event.make);
    result.fold(
      (failure) => emit(const CarError(message: 'Не удалось загрузить модели')),
      (models) => emit(CarModelsLoaded(models: models)),
    );
  }
}
