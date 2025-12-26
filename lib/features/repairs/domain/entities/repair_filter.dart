import 'package:equatable/equatable.dart';
import 'repair_status.dart';

/// Модель фильтра для ремонтов
class RepairFilter extends Equatable {
  final List<RepairStatus> statuses;
  final List<String> partTypes;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const RepairFilter({
    this.statuses = const [],
    this.partTypes = const [],
    this.dateFrom,
    this.dateTo,
  });

  /// Пустой фильтр (без ограничений)
  static const empty = RepairFilter();

  /// Проверяет, активен ли хотя бы один фильтр
  bool get isActive =>
      statuses.isNotEmpty ||
      partTypes.isNotEmpty ||
      dateFrom != null ||
      dateTo != null;

  /// Количество активных фильтров
  int get activeCount {
    int count = 0;
    if (statuses.isNotEmpty) count++;
    if (partTypes.isNotEmpty) count++;
    if (dateFrom != null || dateTo != null) count++;
    return count;
  }

  RepairFilter copyWith({
    List<RepairStatus>? statuses,
    List<String>? partTypes,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return RepairFilter(
      statuses: statuses ?? this.statuses,
      partTypes: partTypes ?? this.partTypes,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  @override
  List<Object?> get props => [statuses, partTypes, dateFrom, dateTo];
}
