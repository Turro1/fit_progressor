import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/material_filter.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterials extends MaterialEvent {
  const LoadMaterials();
}

class AddMaterialEvent extends MaterialEvent {
  final String name;
  final double quantity;
  final MaterialUnit unit;
  final double minQuantity;
  final double cost;

  const AddMaterialEvent({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    required this.cost,
  });

  @override
  List<Object?> get props => [name, quantity, unit, minQuantity, cost];
}

class UpdateMaterialEvent extends MaterialEvent {
  final Material material;

  const UpdateMaterialEvent({required this.material});

  @override
  List<Object?> get props => [material];
}

class DeleteMaterialEvent extends MaterialEvent {
  final String materialId;

  const DeleteMaterialEvent({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}

class SearchMaterialsEvent extends MaterialEvent {
  final String query;

  const SearchMaterialsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterMaterialsEvent extends MaterialEvent {
  final MaterialFilter filter;

  const FilterMaterialsEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class ClearMaterialFiltersEvent extends MaterialEvent {
  const ClearMaterialFiltersEvent();
}
