import 'package:equatable/equatable.dart';

/// Модель фильтра для автомобилей
class CarFilter extends Equatable {
  final List<String> makes;

  const CarFilter({
    this.makes = const [],
  });

  /// Пустой фильтр (без ограничений)
  static const empty = CarFilter();

  /// Проверяет, активен ли хотя бы один фильтр
  bool get isActive => makes.isNotEmpty;

  /// Количество активных фильтров
  int get activeCount => makes.isNotEmpty ? 1 : 0;

  CarFilter copyWith({
    List<String>? makes,
  }) {
    return CarFilter(
      makes: makes ?? this.makes,
    );
  }

  @override
  List<Object?> get props => [makes];
}
