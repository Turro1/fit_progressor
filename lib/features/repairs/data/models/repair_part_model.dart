import '../../domain/entities/repair_part.dart';

class RepairPartModel extends RepairPart {
  const RepairPartModel({
    required super.id,
    required super.type,
    required super.name,
    super.description,
    required super.cost,
  });

  factory RepairPartModel.fromJson(Map<String, dynamic> json) {
    return RepairPartModel(
      id: json['id'] as String,
      type: RepairPartType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RepairPartType.other,
      ),
      name: json['name'] as String,
      description: json['description'] as String?,
      cost: json['cost'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'description': description,
      'cost': cost,
    };
  }

  factory RepairPartModel.fromEntity(RepairPart entity) {
    return RepairPartModel(
      id: entity.id,
      type: entity.type,
      name: entity.name,
      description: entity.description,
      cost: entity.cost,
    );
  }
}
