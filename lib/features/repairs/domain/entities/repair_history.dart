

import 'package:fit_progressor/features/repairs/domain/entities/history_type.dart';

class RepairHistory {
  final String id;
  final HistoryType type;
  final String note;
  final DateTime timestamp;

  RepairHistory({
    required this.id,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  RepairHistory copyWith({
    String? id,
    HistoryType? type,
    String? note,
    DateTime? timestamp,
  }) {
    return RepairHistory(
      id: id ?? this.id,
      type: type ?? this.type,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}