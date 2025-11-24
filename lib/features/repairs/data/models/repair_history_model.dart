import '../../domain/entities/repair_history.dart';

class RepairHistoryModel extends RepairHistory {
  const RepairHistoryModel({
    required super.timestamp,
    required super.type,
    required super.note,
  });

  factory RepairHistoryModel.fromJson(Map<String, dynamic> json) {
    return RepairHistoryModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] == 'status'
          ? HistoryType.statusChange
          : HistoryType.note,
      note: json['note'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type == HistoryType.statusChange ? 'status' : 'note',
      'note': note,
    };
  }

  factory RepairHistoryModel.fromEntity(RepairHistory history) {
    return RepairHistoryModel(
      timestamp: history.timestamp,
      type: history.type,
      note: history.note,
    );
  }
}