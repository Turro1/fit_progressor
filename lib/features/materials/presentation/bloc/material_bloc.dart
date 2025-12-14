import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
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
    on<SearchMaterialsEvent>(_onSearchMaterials);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final result = await getMaterials(NoParams());
    result.fold(
      (failure) =>
          emit(const MaterialError(message: 'Не удалось загрузить материалы')),
      (materials) => emit(MaterialLoaded(materials: materials)),
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
        add(LoadMaterials());
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
        add(LoadMaterials());
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
        add(LoadMaterials());
      },
    );
  }

  Future<void> _onSearchMaterials(
    SearchMaterialsEvent event,
    Emitter<MaterialState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadMaterials());
      return;
    }

    emit(MaterialLoading());
    final result = await searchMaterials(event.query);
    result.fold(
      (failure) => emit(const MaterialError(message: 'Ошибка поиска')),
      (materials) =>
          emit(MaterialLoaded(materials: materials, searchQuery: event.query)),
    );
  }
}
