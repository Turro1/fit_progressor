import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class AddMaterial implements UseCase<Material, AddMaterialParams> {
  final MaterialRepository repository;

  AddMaterial(this.repository);

  @override
  Future<Either<Failure, Material>> call(AddMaterialParams params) async {
    final newMaterial = Material(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
      minQuantity: params.minQuantity,
      cost: params.cost,
      createdAt: DateTime.now(),
    );
    return await repository.addMaterial(newMaterial);
  }
}

class AddMaterialParams extends Equatable {
  final String name;
  final double quantity;
  final MaterialUnit unit;
  final double minQuantity;
  final double cost;

  const AddMaterialParams({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    required this.cost,
  });

  @override
  List<Object?> get props => [name, quantity, unit, minQuantity, cost];
}
