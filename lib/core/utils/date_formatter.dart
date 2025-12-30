import 'package:intl/intl.dart';

class DateFormatter {
  /// Форматирует дату в формат "дд.мм.гггг"
  /// Пример: 15.11.2024
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// Форматирует дату и время в формат "дд.мм.гггг чч:мм"
  /// Пример: 15.11.2024 14:30
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  /// Форматирует только время в формат "чч:мм"
  /// Пример: 14:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Форматирует дату в короткий формат "дд.мм"
  /// Пример: 15.11
  static String formatShortDate(DateTime date) {
    return DateFormat('dd.MM').format(date);
  }

  /// Форматирует дату в длинный формат с названием месяца
  /// Пример: 15 ноября 2024
  static String formatLongDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ru_RU').format(date);
  }

  /// Форматирует для API (ISO 8601)
  /// Пример: 2024-11-15T14:30:00.000Z
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }

  /// Парсит строку в DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Возвращает относительное время
  /// Пример: "Сегодня", "Вчера", "2 дня назад"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня ${formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Вчера ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_getDaysWord(difference.inDays)} назад';
    } else {
      return formatDate(date);
    }
  }

  static String _getDaysWord(int days) {
    final absDays = days.abs();
    if (absDays % 10 == 1 && absDays % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(absDays % 10) &&
        ![12, 13, 14].contains(absDays % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  /// Возвращает относительное время с поддержкой будущих дат
  /// Пример: "Сегодня 14:30", "Завтра 10:00", "Через 2 дня 15:00"
  static String formatRelativeWithFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Сегодня ${formatTime(date)}';
    } else if (difference == 1) {
      return 'Завтра ${formatTime(date)}';
    } else if (difference == -1) {
      return 'Вчера ${formatTime(date)}';
    } else if (difference > 1 && difference < 7) {
      return 'Через $difference ${_getDaysWord(difference)} ${formatTime(date)}';
    } else if (difference < -1 && difference > -7) {
      return '${-difference} ${_getDaysWord(-difference)} назад';
    } else {
      return formatDateTime(date);
    }
  }
}
