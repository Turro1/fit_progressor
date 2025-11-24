import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_repair.dart';
import '../../domain/usecases/delete_repair.dart';
import '../../domain/usecases/filter_repairs_by_status.dart';
import '../../domain/usecases/get_repairs.dart';
import '../../domain/usecases/search_repairs.dart';
import '../../domain/usecases/update_repair.dart';
import 'repair_event.dart';
import 'repair_state.dart';

class RepairBloc extends Bloc<RepairEvent, RepairState> {
  final GetRepairs getRepairs;
  final AddRepair addRepair;
  final UpdateRepair updateRepair;
  final DeleteRepair deleteRepair;
  final SearchRepairs searchRepairs;
  final FilterRepairsByStatus filterRepairsByStatus;

  RepairBloc({
    required this.getRepairs,
    required this.addRepair,
    required this.updateRepair,
    required this.deleteRepair,
    required this.searchRepairs,
    required this.filterRepairsByStatus,
  }) : super(RepairInitial()) {
    on<LoadRepairs>(_onLoadRepairs);
    on<AddRepairEvent>(_onAddRepair);
    on<UpdateRepairEvent>(_onUpdateRepair);
    on<DeleteRepairEvent>(_onDeleteRepair);
    on<SearchRepairsEvent>(_onSearchRepairs);
    on<FilterRepairsByStatusEvent>(_onFilterRepairsByStatus);
  }

  Future<void> _onLoadRepairs(
    LoadRepairs event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());
    final result = await getRepairs(NoParams());
    result.fold(
      (failure) => emit(const RepairError(message: 'Не удалось загрузить ремонты')),
      (repairs) {
        // Сортируем по дате создания (новые сначала)
        final sortedRepairs = List.from(repairs) as List<Repair>
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(repairs: sortedRepairs));
      },
    );
  }

  Future<void> _onAddRepair(
    AddRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());
    final params = AddRepairParams(
      carId: event.carId,
      status: event.status,
      description: event.description,
      costWork: event.costWork,
    );
    final result = await addRepair(params);

    await result.fold(
      (failure) async {
        emit(const RepairError(message: 'Не удалось добавить ремонт'));
      },
      (repair) async {
        emit(const RepairOperationSuccess(message: 'Ремонт создан'));
        add(LoadRepairs());
      },
    );
  }

  Future<void> _onUpdateRepair(
    UpdateRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());
    final result = await updateRepair(event.repair);

    await result.fold(
      (failure) async {
        emit(const RepairError(message: 'Не удалось обновить ремонт'));
      },
      (repair) async {
        emit(const RepairOperationSuccess(message: 'Ремонт обновлен'));
        add(LoadRepairs());
      },
    );
  }

  Future<void> _onDeleteRepair(
    DeleteRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());
    final result = await deleteRepair(event.repairId);

    await result.fold(
      (failure) async {
        emit(const RepairError(message: 'Не удалось удалить ремонт'));
      },
      (_) async {
        emit(const RepairOperationSuccess(message: 'Ремонт удален'));
        add(LoadRepairs());
      },
    );
  }

  Future<void> _onSearchRepairs(
    SearchRepairsEvent event,
    Emitter<RepairState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadRepairs());
      return;
    }

    emit(RepairLoading());
    final result = await searchRepairs(event.query);
    result.fold(
      (failure) => emit(const RepairError(message: 'Ошибка поиска')),
      (repairs) {
        final sortedRepairs = List.from(repairs) as List<Repair>
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(repairs: sortedRepairs, searchQuery: event.query));
      },
    );
  }

  Future<void> _onFilterRepairsByStatus(
    FilterRepairsByStatusEvent event,
    Emitter<RepairState> emit,
  ) async {
    if (event.status == null) {
      add(LoadRepairs());
      return;
    }

    emit(RepairLoading());
    final result = await filterRepairsByStatus(event.status!);
    result.fold(
      (failure) => emit(const RepairError(message: 'Ошибка фильтрации')),
      (repairs) {
        final sortedRepairs = List.from(repairs) as List<Repair>
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(
          repairs: sortedRepairs,
          statusFilter: event.status,
        ));
      },
    );
  }
}