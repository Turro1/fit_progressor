import 'package:equatable/equatable.dart';

class RepairMaterial extends Equatable {
  final String materialId;
  final String name;
  final int quantity;
  final double price;

  const RepairMaterial({
    required this.materialId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  RepairMaterial copyWith({
    String? materialId,
    String? name,
    int? quantity,
    double? price,
  }) {
    return RepairMaterial(
      materialId: materialId ?? this.materialId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [materialId, name, quantity, price];
}
