import 'package:equatable/equatable.dart';

enum HistoryType { statusChange, note }

class RepairHistory extends Equatable {
  final DateTime timestamp;
  final HistoryType type;
  final String note;

  const RepairHistory({
    required this.timestamp,
    required this.type,
    required this.note,
  });

  @override
  List<Object?> get props => [timestamp, type, note];
}