import 'package:equatable/equatable.dart';

enum HistoryType {
  statusChange('Изменение статуса'),
  noteAdded('Добавлена заметка'),
  materialAdded('Добавлен материал'),
  materialRemoved('Удален материал'),
  photoAdded('Добавлено фото'),
  photoRemoved('Удалено фото'),
  costChanged('Изменена стоимость'),
  descriptionChanged('Изменено описание');

  final String displayName;

  const HistoryType(this.displayName);
}

class RepairHistory extends Equatable {
  final String id;
  final DateTime timestamp;
  final HistoryType type;
  final String description;

  const RepairHistory({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
  });

  RepairHistory copyWith({
    String? id,
    DateTime? timestamp,
    HistoryType? type,
    String? description,
  }) {
    return RepairHistory(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, type, description];
}
