import 'package:equatable/equatable.dart';

class RepairMaterial extends Equatable {
  final String materialId;
  final double quantity;
  final double cost;

  const RepairMaterial({
    required this.materialId,
    required this.quantity,
    required this.cost,
  });

  double get totalCost => quantity * cost;

  @override
  List<Object?> get props => [materialId, quantity, cost];
}