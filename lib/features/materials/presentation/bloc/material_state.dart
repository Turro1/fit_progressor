import 'package:equatable/equatable.dart';
import '../../domain/entities/material.dart';

abstract class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object> get props => [];
}

class MaterialInitial extends MaterialState {}

class MaterialLoading extends MaterialState {}

class MaterialLoaded extends MaterialState {
  final List<Material> materials;
  final String? searchQuery;

  const MaterialLoaded({required this.materials, this.searchQuery});

  @override
  List<Object> get props => [materials, searchQuery ?? ''];
}

class MaterialOperationSuccess extends MaterialState {
  final String message;

  const MaterialOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class MaterialError extends MaterialState {
  final String message;

  const MaterialError({required this.message});

  @override
  List<Object> get props => [message];
}
