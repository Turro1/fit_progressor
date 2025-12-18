/// Система токенов пространства и размеров для приложения
///
/// Использует базовый модуль 4px для консистентного spacing
class AppSpacing {
  // Базовые размеры (4px модуль)
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium
  static const double lg = 16.0; // Large
  static const double xl = 20.0; // Extra large
  static const double xxl = 24.0; // 2X Large
  static const double xxxl = 32.0; // 3X Large

  // Семантические размеры для конкретных случаев
  static const double cardPadding = lg; // 16dp - внутренний padding карточек
  static const double pagePadding = lg; // 16dp - padding страниц
  static const double listItemSpacing =
      md; // 12dp - расстояние между элементами списка
  static const double sectionSpacing = xxl; // 24dp - расстояние между секциями
  static const double modalPadding = xl; // 20dp - padding модальных окон
}

/// Система токенов радиусов скругления
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 9999.0; // Полное скругление (круг/pill)
}

/// Система уровней elevation для Material 3
class AppElevation {
  static const double level0 = 0.0; // Без elevation
  static const double level1 = 1.0; // Минимальный подъем
  static const double level2 = 3.0; // Стандартный подъем
  static const double level3 = 6.0; // Средний подъем
  static const double level4 = 8.0; // Высокий подъем
  static const double level5 = 12.0; // Максимальный подъем
}
