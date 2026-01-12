import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/material_filter.dart';
import '../../domain/usecases/add_material.dart';
import '../../domain/usecases/delete_material.dart';
import '../../domain/usecases/get_materials.dart';
import '../../domain/usecases/search_materials.dart';
import '../../domain/usecases/update_material.dart';
import 'material_event.dart';
import 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final GetMaterials getMaterials;
  final AddMaterial addMaterial;
  final UpdateMaterial updateMaterial;
  final DeleteMaterial deleteMaterial;
  final SearchMaterials searchMaterials;

  MaterialFilter _currentFilter = const MaterialFilter();

  MaterialBloc({
    required this.getMaterials,
    required this.addMaterial,
    required this.updateMaterial,
    required this.deleteMaterial,
    required this.searchMaterials,
  }) : super(MaterialInitial()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<AddMaterialEvent>(_onAddMaterial);
    on<UpdateMaterialEvent>(_onUpdateMaterial);
    on<DeleteMaterialEvent>(_onDeleteMaterial);
    on<RestoreMaterialEvent>(_onRestoreMaterial);
    on<SearchMaterialsEvent>(_onSearchMaterials);
    on<FilterMaterialsEvent>(_onFilterMaterials);
    on<ClearMaterialFiltersEvent>(_onClearFilters);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading(currentFilter: _currentFilter));
    final result = await getMaterials(NoParams());
    result.fold(
      (failure) =>
          emit(const MaterialError(message: 'Не удалось загрузить материалы')),
      (materials) {
        final filtered = _applyFilter(materials, _currentFilter);
        emit(MaterialLoaded(materials: filtered, filter: _currentFilter));
      },
    );
  }

  Future<void> _onAddMaterial(
    AddMaterialEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final params = AddMaterialParams(
      name: event.name,
      quantity: event.quantity,
      unit: event.unit,
      minQuantity: event.minQuantity,
      cost: event.cost,
    );
    final result = await addMaterial(params);

    await result.fold(
      (failure) async =>
          emit(const MaterialError(message: 'Не удалось добавить материал')),
      (_) async {
        emit(const MaterialOperationSuccess(message: 'Материал добавлен'));
        // Не вызываем LoadMaterials здесь - это будет сделано в UI после закрытия модала
      },
    );
  }

  Future<void> _onUpdateMaterial(
    UpdateMaterialEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final result = await updateMaterial(event.material);

    await result.fold(
      (failure) async =>
          emit(const MaterialError(message: 'Не удалось обновить материал')),
      (_) async {
        emit(const MaterialOperationSuccess(message: 'Материал обновлен'));
        // Не вызываем LoadMaterials здесь - это будет сделано в UI после закрытия модала
      },
    );
  }

  Future<void> _onDeleteMaterial(
    DeleteMaterialEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final result = await deleteMaterial(event.materialId);

    await result.fold(
      (failure) async =>
          emit(const MaterialError(message: 'Не удалось удалить материал')),
      (_) async {
        emit(const MaterialOperationSuccess(message: 'Материал удален'));
        add(const LoadMaterials());
      },
    );
  }

  Future<void> _onRestoreMaterial(
    RestoreMaterialEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final params = AddMaterialParams(
      name: event.material.name,
      quantity: event.material.quantity,
      unit: event.material.unit,
      minQuantity: event.material.minQuantity,
      cost: event.material.cost,
      existingId: event.material.id,
    );
    final result = await addMaterial(params);

    await result.fold(
      (failure) async =>
          emit(const MaterialError(message: 'Не удалось восстановить материал')),
      (_) async {
        emit(const MaterialOperationSuccess(message: 'Материал восстановлен'));
        add(const LoadMaterials());
      },
    );
  }

  Future<void> _onSearchMaterials(
    SearchMaterialsEvent event,
    Emitter<MaterialState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadMaterials());
      return;
    }

    emit(MaterialLoading(currentFilter: _currentFilter));
    final result = await searchMaterials(event.query);
    result.fold(
      (failure) => emit(const MaterialError(message: 'Ошибка поиска')),
      (materials) {
        final filtered = _applyFilter(materials, _currentFilter);
        emit(MaterialLoaded(
          materials: filtered,
          searchQuery: event.query,
          filter: _currentFilter,
        ));
      },
    );
  }

  Future<void> _onFilterMaterials(
    FilterMaterialsEvent event,
    Emitter<MaterialState> emit,
  ) async {
    _currentFilter = event.filter;
    add(const LoadMaterials());
  }

  Future<void> _onClearFilters(
    ClearMaterialFiltersEvent event,
    Emitter<MaterialState> emit,
  ) async {
    _currentFilter = const MaterialFilter();
    add(const LoadMaterials());
  }

  List<Material> _applyFilter(List<Material> materials, MaterialFilter filter) {
    if (!filter.isActive) return materials;

    return materials.where((material) {
      // Фильтр по единице измерения
      if (filter.units.isNotEmpty && !filter.units.contains(material.unit)) {
        return false;
      }

      // Фильтр по статусу наличия
      if (filter.stockStatuses.isNotEmpty) {
        final stockStatus = _getStockStatus(material);
        if (!filter.stockStatuses.contains(stockStatus)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  StockStatus _getStockStatus(Material material) {
    if (material.isOutOfStock) return StockStatus.outOfStock;
    if (material.isLowStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}
