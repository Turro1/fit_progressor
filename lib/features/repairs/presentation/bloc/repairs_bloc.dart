import 'package:fit_progressor/core/services/material_stock_service.dart';
import 'package:fit_progressor/features/repairs/data/services/repair_image_service.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_filter.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/add_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/delete_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repair_by_id.dart';
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
  final RepairImageService imageService;
  final MaterialStockService stockService;
  final GetRepairById getRepairById;

  RepairsBloc({
    required this.getRepairs,
    required this.addRepair,
    required this.updateRepair,
    required this.deleteRepair,
    required this.searchRepairs,
    required this.imageService,
    required this.stockService,
    required this.getRepairById,
  }) : super(RepairsInitial()) {
    on<LoadRepairs>(_onLoadRepairs);
    on<AddRepairEvent>(_onAddRepair);
    on<UpdateRepairEvent>(_onUpdateRepair);
    on<DeleteRepairEvent>(_onDeleteRepair);
    on<SearchRepairsEvent>(_onSearchRepairs);
    on<FilterRepairsEvent>(_onFilterRepairs);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  Future<void> _onLoadRepairs(
    LoadRepairs event,
    Emitter<RepairsState> emit,
  ) async {
    // Сохраняем текущий фильтр при перезагрузке
    RepairFilter currentFilter = const RepairFilter();
    if (state is RepairsLoaded) {
      currentFilter = (state as RepairsLoaded).filter;
    }

    emit(RepairsLoading(currentFilter: currentFilter));

    // Если фильтруем по carId или clientId, всё равно загружаем ВСЕ ремонты
    // чтобы allRepairs для badge в навигации оставался актуальным
    final result = await getRepairs(const GetRepairsParams());
    result.fold(
      (failure) =>
          emit(const RepairsError(message: 'Не удалось загрузить ремонты')),
      (allRepairs) {
        // Фильтрация по carId если указан
        var filteredRepairs = allRepairs;
        if (event.carId != null) {
          filteredRepairs = allRepairs
              .where((r) => r.carId == event.carId)
              .toList();
        }
        // Фильтрация по clientId если указан
        if (event.clientId != null) {
          filteredRepairs = filteredRepairs
              .where((r) => r.clientId == event.clientId)
              .toList();
        }
        final finalRepairs = _applyFilter(filteredRepairs, currentFilter);
        emit(RepairsLoaded(
          repairs: finalRepairs,
          allRepairs: allRepairs, // Всегда сохраняем ВСЕ ремонты
          filterCarId: event.carId,
          filter: currentFilter,
        ));
      },
    );
  }

  /// Применяет фильтр к списку ремонтов
  List<Repair> _applyFilter(List<Repair> repairs, RepairFilter filter) {
    if (!filter.isActive) return repairs;

    return repairs.where((repair) {
      // Фильтр по статусу
      if (filter.statuses.isNotEmpty &&
          !filter.statuses.contains(repair.status)) {
        return false;
      }

      // Фильтр по типу детали
      if (filter.partTypes.isNotEmpty &&
          !filter.partTypes.contains(repair.partType)) {
        return false;
      }

      // Фильтр по дате (от)
      if (filter.dateFrom != null) {
        final startOfDay = DateTime(
          filter.dateFrom!.year,
          filter.dateFrom!.month,
          filter.dateFrom!.day,
        );
        if (repair.date.isBefore(startOfDay)) {
          return false;
        }
      }

      // Фильтр по дате (до)
      if (filter.dateTo != null) {
        final endOfDay = DateTime(
          filter.dateTo!.year,
          filter.dateTo!.month,
          filter.dateTo!.day,
          23,
          59,
          59,
        );
        if (repair.date.isAfter(endOfDay)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _onAddRepair(
    AddRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    // Сохраняем текущий фильтр по автомобилю, если он есть
    String? currentCarId;
    if (state is RepairsLoaded) {
      currentCarId = (state as RepairsLoaded).filterCarId;
    }

    emit(RepairsLoading());

    // 1. Сгенерировать ID для ремонта
    final repairId = 'repair_${DateTime.now().millisecondsSinceEpoch}';

    // 2. Сохранить изображения в постоянное хранилище
    final savedPhotoPaths = <String>[];
    for (final tempPath in event.photoPaths) {
      try {
        final savedPath = await imageService.saveImage(tempPath, repairId);
        savedPhotoPaths.add(savedPath);
      } catch (e) {
        // Логировать, но продолжать
      }
    }

    // 3. Создать параметры с сохранёнными путями
    final params = AddRepairParams(
      partType: event.partType,
      partPosition: event.partPosition,
      photoPaths: savedPhotoPaths,
      description: event.description,
      date: event.date,
      cost: event.cost,
      clientId: event.clientId,
      carId: event.carId,
      carMake: event.carMake,
      carModel: event.carModel,
      materials: event.materials,
    );
    final result = await addRepair(params);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось добавить ремонт'));
      },
      (repair) async {
        // 4. Списать материалы со склада
        if (event.materials.isNotEmpty) {
          await stockService.deductMaterials(event.materials);
        }
        emit(const RepairsOperationSuccess(message: 'Ремонт добавлен'));
        // Перезагружаем с сохранением фильтра
        add(LoadRepairs(carId: currentCarId));
      },
    );
  }

  Future<void> _onUpdateRepair(
    UpdateRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    // Сохраняем текущий фильтр по автомобилю, если он есть
    String? currentCarId;
    if (state is RepairsLoaded) {
      currentCarId = (state as RepairsLoaded).filterCarId;
    }

    emit(RepairsLoading());

    // 1. Получить старый ремонт для корректировки материалов
    final oldRepairResult = await getRepairById(event.repair.id);

    // 2. Обновить ремонт
    final result = await updateRepair(event.repair);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось обновить ремонт'));
      },
      (repair) async {
        // 3. Скорректировать материалы на складе
        await oldRepairResult.fold(
          (failure) async {},
          (oldRepair) async {
            await stockService.adjustMaterials(
              oldRepair.materials,
              event.repair.materials,
            );
          },
        );
        emit(const RepairsOperationSuccess(message: 'Ремонт обновлен'));
        // Перезагружаем с сохранением фильтра
        add(LoadRepairs(carId: currentCarId));
      },
    );
  }

  Future<void> _onDeleteRepair(
    DeleteRepairEvent event,
    Emitter<RepairsState> emit,
  ) async {
    // Сохраняем текущий фильтр по автомобилю, если он есть
    String? currentCarId;
    if (state is RepairsLoaded) {
      currentCarId = (state as RepairsLoaded).filterCarId;
    }

    emit(RepairsLoading());

    // 1. Получить ремонт для возврата материалов
    final repairResult = await getRepairById(event.repairId);

    // 2. Удалить ремонт
    final result = await deleteRepair(event.repairId);

    await result.fold(
      (failure) async {
        emit(const RepairsError(message: 'Не удалось удалить ремонт'));
      },
      (_) async {
        // 3. Вернуть материалы на склад
        await repairResult.fold(
          (failure) async {},
          (repair) async {
            if (repair.materials.isNotEmpty) {
              await stockService.returnMaterials(repair.materials);
            }
          },
        );
        emit(const RepairsOperationSuccess(message: 'Ремонт удален'));
        // Перезагружаем с сохранением фильтра
        add(LoadRepairs(carId: currentCarId));
      },
    );
  }

  Future<void> _onSearchRepairs(
    SearchRepairsEvent event,
    Emitter<RepairsState> emit,
  ) async {
    // Сохраняем текущий фильтр
    RepairFilter currentFilter = const RepairFilter();
    List<Repair> allRepairs = [];
    if (state is RepairsLoaded) {
      currentFilter = (state as RepairsLoaded).filter;
      allRepairs = (state as RepairsLoaded).allRepairs;
    }

    if (event.query.isEmpty) {
      add(LoadRepairs(carId: event.carId));
      return;
    }

    emit(RepairsLoading(currentFilter: currentFilter));
    final result = await searchRepairs(
      SearchRepairsParams(query: event.query, carId: event.carId),
    );
    result.fold(
      (failure) => emit(const RepairsError(message: 'Ошибка поиска')),
      (repairs) {
        final filteredRepairs = _applyFilter(repairs, currentFilter);
        emit(RepairsLoaded(
          repairs: filteredRepairs,
          allRepairs: allRepairs.isNotEmpty ? allRepairs : repairs,
          searchQuery: event.query,
          filterCarId: event.carId,
          filter: currentFilter,
        ));
      },
    );
  }

  Future<void> _onFilterRepairs(
    FilterRepairsEvent event,
    Emitter<RepairsState> emit,
  ) async {
    if (state is RepairsLoaded) {
      final currentState = state as RepairsLoaded;
      final filteredRepairs = _applyFilter(currentState.allRepairs, event.filter);
      emit(currentState.copyWith(
        repairs: filteredRepairs,
        filter: event.filter,
      ));
    } else {
      // Если состояние не Loaded, загружаем данные с фильтром
      emit(RepairsLoading(currentFilter: event.filter));
      final result = await getRepairs(const GetRepairsParams());
      result.fold(
        (failure) =>
            emit(const RepairsError(message: 'Не удалось загрузить ремонты')),
        (repairs) {
          final filteredRepairs = _applyFilter(repairs, event.filter);
          emit(RepairsLoaded(
            repairs: filteredRepairs,
            allRepairs: repairs,
            filter: event.filter,
          ));
        },
      );
    }
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<RepairsState> emit,
  ) async {
    if (state is RepairsLoaded) {
      final currentState = state as RepairsLoaded;
      emit(currentState.copyWith(
        repairs: currentState.allRepairs,
        filter: const RepairFilter(),
      ));
    }
  }
}
