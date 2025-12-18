import 'package:fit_progressor/features/repairs/domain/usecases/add_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/delete_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/search_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/update_repair.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RepairsBloc extends Bloc<RepairsEvent, RepairsState> {
  final GetRepairs getRepairs;
  final AddRepair addRepair;
  final UpdateRepair updateRepair;
  final DeleteRepair deleteRepair;
  final SearchRepairs searchRepairs;

  RepairsBloc({
    required this.getRepairs,
    required this.addRepair,
    required this.updateRepair,
    required this.deleteRepair,
    required this.searchRepairs,
  }) : super(RepairsInitial()) {
    on<LoadRepairs>(_onLoadRepairs);
    on<AddRepairEvent>(_onAddRepair);
    on<UpdateRepairEvent>(_onUpdateRepair);
    on<DeleteRepairEvent>(_onDeleteRepair);
    on<SearchRepairsEvent>(_onSearchRepairs);
  }

  Future<void> _onLoadRepairs(
    LoadRepairs event,
    Emitter<RepairsState> emit,
  ) async {
    emit(RepairsLoading());
    final result = await getRepairs(GetRepairsParams(carId: event.carId));
    result.fold(
      (failure) =>
          emit(const RepairsError(message: 'Не удалось загрузить ремонты')),
      (repairs) => emit(RepairsLoaded(
        repairs: repairs,
        filterCarId: event.carId,
      )),
    );
  }

  Future<void> _onAddRepair(
    AddRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    emit(RepairsLoading());
    final params = AddRepairParams(
      name: event.name,
      description: event.description,
      date: event.date,
      cost: event.cost,
      clientId: event.clientId,
      carId: event.carId,
    );
    final result = await addRepair(params);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось добавить ремонт'));
      },
      (repair) async {
        emit(const RepairsOperationSuccess(message: 'Ремонт добавлен'));
        add(const LoadRepairs());
      },
    );
  }

  Future<void> _onUpdateRepair(
    UpdateRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    emit(RepairsLoading());
    final result = await updateRepair(event.repair);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось обновить ремонт'));
      },
      (repair) async {
        emit(const RepairsOperationSuccess(message: 'Ремонт обновлен'));
        add(const LoadRepairs());
      },
    );
  }

  Future<void> _onDeleteRepair(
    DeleteRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    emit(RepairsLoading());
    final result = await deleteRepair(event.repairId);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось удалить ремонт'));
      },
      (_) async {
        emit(const RepairsOperationSuccess(message: 'Ремонт удален'));
        add(const LoadRepairs());
      },
    );
  }

  Future<void> _onSearchRepairs(
    SearchRepairsEvent event,
    Emitter<RepairsState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadRepairs(carId: event.carId));
      return;
    }

    emit(RepairsLoading());
    final result = await searchRepairs(
      SearchRepairsParams(query: event.query, carId: event.carId),
    );
    result.fold(
      (failure) => emit(const RepairsError(message: 'Ошибка поиска')),
      (repairs) => emit(RepairsLoaded(
        repairs: repairs,
        searchQuery: event.query,
        filterCarId: event.carId,
      )),
    );
  }
}
