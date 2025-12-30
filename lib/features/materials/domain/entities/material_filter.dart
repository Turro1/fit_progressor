import 'package:equatable/equatable.dart';
import 'material.dart';

/// Статус наличия материала
enum StockStatus {
  inStock,    // В наличии (quantity > minQuantity)
  lowStock,   // Заканчивается (0 < quantity <= minQuantity)
  outOfStock, // Нет в наличии (quantity <= 0)
}

extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.inStock:
        return 'В наличии';
      case StockStatus.lowStock:
        return 'Заканчивается';
      case StockStatus.outOfStock:
        return 'Нет в наличии';
    }
  }
}

/// Модель фильтра для материалов
class MaterialFilter extends Equatable {
  final List<MaterialUnit> units;
  final List<StockStatus> stockStatuses;

  const MaterialFilter({
    this.units = const [],
    this.stockStatuses = const [],
  });

  /// Пустой фильтр (без ограничений)
  static const empty = MaterialFilter();

  /// Проверяет, активен ли хотя бы один фильтр
  bool get isActive => units.isNotEmpty || stockStatuses.isNotEmpty;

  /// Количество активных фильтров
  int get activeCount {
    int count = 0;
    if (units.isNotEmpty) count++;
    if (stockStatuses.isNotEmpty) count++;
    return count;
  }

  MaterialFilter copyWith({
    List<MaterialUnit>? units,
    List<StockStatus>? stockStatuses,
  }) {
    return MaterialFilter(
      units: units ?? this.units,
      stockStatuses: stockStatuses ?? this.stockStatuses,
    );
  }

  @override
  List<Object?> get props => [units, stockStatuses];
}
