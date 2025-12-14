import 'package:equatable/equatable.dart';

enum RepairPartType {
  suspension('Подвеска'),
  engine('Двигатель'),
  brakes('Тормоза'),
  body('Кузов'),
  interior('Салон'),
  electrical('Электрика'),
  transmission('Трансмиссия'),
  other('Другое');

  final String displayName;
  const RepairPartType(this.displayName);
}

class RepairPart extends Equatable {
  final String id;
  final RepairPartType type;
  final String name; // e.g., "Амортизатор передний левый", "Воздушная подушка"
  final String? description;
  final double cost; // Cost of the part itself

  const RepairPart({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.cost,
  });

  RepairPart copyWith({
    String? id,
    RepairPartType? type,
    String? name,
    String? description,
    double? cost,
  }) {
    return RepairPart(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
    );
  }

  @override
  List<Object?> get props => [id, type, name, description, cost];
}
