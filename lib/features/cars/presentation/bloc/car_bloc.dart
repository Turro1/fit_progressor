import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/core/error/failures/duplicate_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_filter.dart';
import '../../domain/usecases/add_car.dart';
import '../../domain/usecases/delete_car.dart';
import '../../domain/usecases/get_car_makes.dart';
import '../../domain/usecases/get_car_models.dart';
import '../../domain/usecases/get_cars.dart';
import '../../domain/usecases/search_cars.dart';
import '../../domain/usecases/update_car.dart';
import 'car_event.dart';
import 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCars;
  final AddCar addCar;
  final UpdateCar updateCar;
  final DeleteCar deleteCar;
  final SearchCars searchCars;
  final GetCarMakes getCarMakes;
  final GetCarModels getCarModels;

  CarFilter _currentFilter = const CarFilter();
  List<String> _availableMakes = [];

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
    on<FilterCarsEvent>(_onFilterCars);
    on<ClearCarFiltersEvent>(_onClearFilters);
  }

  Future<void> _onLoadCars(LoadCars event, Emitter<CarState> emit) async {
    emit(CarLoading(currentFilter: _currentFilter));
    try {
      final result = await getCars(NoParams());
      result.fold(
        (failure) =>
            emit(const CarError(message: 'Не удалось загрузить автомобили')),
        (cars) {
          // Собираем уникальные марки для фильтра
          _availableMakes = cars.map((c) => c.make).toSet().toList()..sort();
          final filtered = _applyFilter(cars, _currentFilter);
          emit(CarLoaded(
            cars: filtered,
            filter: _currentFilter,
            availableMakes: _availableMakes,
          ));
        },
      );
    } catch (e) {
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
        final message = failure is DuplicateFailure
            ? failure.message
            : 'Не удалось добавить автомобиль';
        emit(CarError(message: message));
      },
      (car) async {
        emit(const CarOperationSuccess(message: 'Автомобиль добавлен'));
        // Не вызываем LoadCars здесь - это будет сделано в UI после закрытия модала
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
        final message = failure is DuplicateFailure
            ? failure.message
            : 'Не удалось обновить автомобиль';
        emit(CarError(message: message));
      },
      (car) async {
        emit(const CarOperationSuccess(message: 'Автомобиль обновлен'));
        // Не вызываем LoadCars здесь - это будет сделано в UI после закрытия модала
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
      add(const LoadCars());
      return;
    }

    emit(CarLoading(currentFilter: _currentFilter));
    final result = await searchCars(event.query);
    result.fold(
      (failure) => emit(const CarError(message: 'Ошибка поиска')),
      (cars) {
        final filtered = _applyFilter(cars, _currentFilter);
        emit(CarLoaded(
          cars: filtered,
          searchQuery: event.query,
          filter: _currentFilter,
          availableMakes: _availableMakes,
        ));
      },
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

  Future<void> _onFilterCars(
    FilterCarsEvent event,
    Emitter<CarState> emit,
  ) async {
    _currentFilter = event.filter;
    add(const LoadCars());
  }

  Future<void> _onClearFilters(
    ClearCarFiltersEvent event,
    Emitter<CarState> emit,
  ) async {
    _currentFilter = const CarFilter();
    add(const LoadCars());
  }

  List<Car> _applyFilter(List<Car> cars, CarFilter filter) {
    if (!filter.isActive) return cars;

    return cars.where((car) {
      // Фильтр по марке
      if (filter.makes.isNotEmpty && !filter.makes.contains(car.make)) {
        return false;
      }
      return true;
    }).toList();
  }
}
