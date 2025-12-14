import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Форматирует число в валюту с символом рубля
  /// Пример: 1 234 567 ₽
  static String format(double amount) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return '${formatter.format(amount)} ₽';
  }

  /// Форматирует число в валюту без символа
  /// Пример: 1 234 567
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(amount);
  }

  /// Форматирует число с копейками
  /// Пример: 1 234 567.89 ₽
  static String formatWithCents(double amount) {
    final formatter = NumberFormat('#,##0.00', 'ru_RU');
    return '${formatter.format(amount)} ₽';
  }

  /// Форматирует компактно для больших чисел
  /// Пример: 1.2М ₽, 15К ₽
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}М ₽';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}К ₽';
    } else {
      return format(amount);
    }
  }

  /// Форматирует с указанием валюты
  /// Пример: USD 1,234.56
  static String formatWithCurrency(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: currencyCode,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Парсит строку в число
  static double? parse(String text) {
    try {
      // Убираем пробелы и символ рубля
      final cleaned = text.replaceAll(' ', '').replaceAll('₽', '').trim();
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Форматирует разницу (положительное со знаком +)
  /// Пример: +1 234 ₽ или -567 ₽
  static String formatDifference(double amount) {
    final sign = amount >= 0 ? '+' : '';
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return '$sign${formatter.format(amount)} ₽';
  }

  /// Форматирует процент
  /// Пример: 15.5%
  static String formatPercent(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
