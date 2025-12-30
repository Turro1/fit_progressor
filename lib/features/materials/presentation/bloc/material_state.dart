import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/material_filter.dart';

abstract class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object?> get props => [];
}

class MaterialInitial extends MaterialState {}

class MaterialLoading extends MaterialState {
  final MaterialFilter? currentFilter;

  const MaterialLoading({this.currentFilter});

  @override
  List<Object?> get props => [currentFilter];
}

class MaterialLoaded extends MaterialState {
  final List<Material> materials;
  final String? searchQuery;
  final MaterialFilter filter;

  const MaterialLoaded({
    required this.materials,
    this.searchQuery,
    this.filter = const MaterialFilter(),
  });

  @override
  List<Object?> get props => [materials, searchQuery, filter];
}

class MaterialOperationSuccess extends MaterialState {
  final String message;

  const MaterialOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class MaterialError extends MaterialState {
  final String message;

  const MaterialError({required this.message});

  @override
  List<Object?> get props => [message];
}
