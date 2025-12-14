import '../../domain/entities/repair_history.dart';

class RepairHistoryModel extends RepairHistory {
  const RepairHistoryModel({
    required super.id,
    required super.timestamp,
    required super.type,
    required super.description,
  });

  factory RepairHistoryModel.fromJson(Map<String, dynamic> json) {
    return RepairHistoryModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: HistoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => HistoryType.noteAdded,
      ),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'description': description,
    };
  }

  factory RepairHistoryModel.fromEntity(RepairHistory entity) {
    return RepairHistoryModel(
      id: entity.id,
      timestamp: entity.timestamp,
      type: entity.type,
      description: entity.description,
    );
  }
}
