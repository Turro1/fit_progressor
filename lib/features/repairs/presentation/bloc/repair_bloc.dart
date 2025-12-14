import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/repair.dart';
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
        List<Repair> filteredRepairs = repairs;
        if (event.carIdFilter != null) {
          filteredRepairs = filteredRepairs
              .where((repair) => repair.carId == event.carIdFilter)
              .toList();
        }
        
        // Sort repairs by creation date, newest first
        final sortedRepairs = List<Repair>.from(filteredRepairs)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(
          repairs: sortedRepairs,
          carIdFilter: event.carIdFilter, // Pass carIdFilter to state
        ));
      },
    );
  }

  Future<void> _onAddRepair(
    AddRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading()); // Indicate loading while adding
    final params = AddRepairParams(
      carId: event.carId,
      clientId: event.clientId,
      status: event.status,
      description: event.description,
      costWork: event.costWork,
      materials: event.materials,
      parts: event.parts,
      photos: event.photos,
      plannedAt: event.plannedAt,
    );
    final result = await addRepair(params);
    result.fold(
      (failure) => emit(const RepairError(message: 'Не удалось добавить ремонт')),
      (repair) async {
        emit(const RepairOperationSuccess(message: 'Ремонт успешно добавлен'));
        add(LoadRepairs()); // Reload repairs after successful addition
      },
    );
  }

  Future<void> _onUpdateRepair(
    UpdateRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading()); // Indicate loading while updating
    final result = await updateRepair(event.repair);
    result.fold(
      (failure) => emit(const RepairError(message: 'Не удалось обновить ремонт')),
      (repair) async {
        emit(const RepairOperationSuccess(message: 'Ремонт успешно обновлен'));
        add(LoadRepairs()); // Reload repairs after successful update
      },
    );
  }

  Future<void> _onDeleteRepair(
    DeleteRepairEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading()); // Indicate loading while deleting
    final result = await deleteRepair(event.repairId);
    result.fold(
      (failure) => emit(const RepairError(message: 'Не удалось удалить ремонт')),
      (_) async {
        emit(const RepairOperationSuccess(message: 'Ремонт успешно удален'));
        add(LoadRepairs()); // Reload repairs after successful deletion
      },
    );
  }

  Future<void> _onSearchRepairs(
    SearchRepairsEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading()); // Indicate loading while searching
    final result = await searchRepairs(event.query);
    result.fold(
      (failure) => emit(const RepairError(message: 'Ошибка при поиске ремонтов')),
      (repairs) {
        final sortedRepairs = List<Repair>.from(repairs)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(repairs: sortedRepairs, searchQuery: event.query));
      },
    );
  }

  Future<void> _onFilterRepairsByStatus(
    FilterRepairsByStatusEvent event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading()); // Indicate loading while filtering
    if (event.status == null) {
      add(LoadRepairs()); // Load all if filter is cleared
      return;
    }
    final result = await filterRepairsByStatus(event.status!);
    result.fold(
      (failure) => emit(const RepairError(message: 'Ошибка при фильтрации ремонтов')),
      (repairs) {
        final sortedRepairs = List<Repair>.from(repairs)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(RepairLoaded(repairs: sortedRepairs, statusFilter: event.status));
      },
    );
  }
}
