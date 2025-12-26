import 'package:flutter/services.dart';

/// Тип номерного знака
enum PlateType {
  moldova,      // ABC 123
  transnistria, // A 123 BC
  unknown,
}

/// Форматтер для гос. номера (Молдова + Приднестровье)
/// Молдова: ABC 123 (3 буквы + 3 цифры)
/// Приднестровье: A 123 BC (1 буква + 3 цифры + 2 буквы)
class MoldovaPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Убираем всё кроме букв и цифр, приводим к верхнему регистру
    final text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Определяем тип номера по первым символам
    // Если начинается с буквы, затем цифра - это Приднестровье
    // Если начинается с нескольких букв - это Молдова

    final buffer = StringBuffer();
    bool isTransnistria = false;

    // Проверяем: если второй символ - цифра, то это формат Приднестровья
    if (text.length >= 2 &&
        RegExp(r'[A-Z]').hasMatch(text[0]) &&
        RegExp(r'[0-9]').hasMatch(text[1])) {
      isTransnistria = true;
    }

    if (isTransnistria) {
      // Формат Приднестровья: A 123 BC
      for (int i = 0; i < text.length && buffer.length < 8; i++) {
        final char = text[i];
        final cleanLength = buffer.toString().replaceAll(' ', '').length;

        if (cleanLength == 0) {
          // Первый символ - буква
          if (RegExp(r'[A-Z]').hasMatch(char)) {
            buffer.write(char);
            buffer.write(' ');
          }
        } else if (cleanLength >= 1 && cleanLength < 4) {
          // Символы 2-4 - цифры
          if (RegExp(r'[0-9]').hasMatch(char)) {
            buffer.write(char);
            if (cleanLength == 3) buffer.write(' ');
          }
        } else if (cleanLength >= 4 && cleanLength < 6) {
          // Символы 5-6 - буквы
          if (RegExp(r'[A-Z]').hasMatch(char)) {
            buffer.write(char);
          }
        }
      }
    } else {
      // Формат Молдовы: ABC 123
      for (int i = 0; i < text.length && buffer.length < 7; i++) {
        final char = text[i];
        final cleanLength = buffer.toString().replaceAll(' ', '').length;

        if (cleanLength < 3) {
          // Первые 3 символа - буквы
          if (RegExp(r'[A-Z]').hasMatch(char)) {
            buffer.write(char);
            if (cleanLength == 2) buffer.write(' ');
          }
        } else if (cleanLength >= 3 && cleanLength < 6) {
          // Символы 4-6 - цифры
          if (RegExp(r'[0-9]').hasMatch(char)) {
            buffer.write(char);
          }
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Форматтер для номера телефона (Молдова + Приднестровье)
/// Молдова: +373 XX XXX XXX (мобильные 6x, 7x)
/// Приднестровье: +373 533 XXXXX, +373 552 XXXXX и др.
class MoldovaPhoneFormatter extends TextInputFormatter {
  // Коды Приднестровья
  static const _transnistrianCodes = ['533', '552', '555', '557', '215', '210', '216', '219'];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Получаем только цифры
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Если начинается с 373, убираем код страны для форматирования
    if (digits.startsWith('373')) {
      digits = digits.substring(3);
    }
    // Если начинается с 0, убираем его
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // Ограничиваем до 8 цифр
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    // Определяем тип номера
    bool isTransnistrian = false;
    if (digits.length >= 3) {
      final prefix = digits.substring(0, 3);
      isTransnistrian = _transnistrianCodes.contains(prefix);
    }

    // Форматируем
    final buffer = StringBuffer('+373');

    if (isTransnistrian) {
      // Приднестровье: +373 XXX XXXXX
      for (int i = 0; i < digits.length; i++) {
        if (i == 0 || i == 3) {
          buffer.write(' ');
        }
        buffer.write(digits[i]);
      }
    } else {
      // Молдова: +373 XX XXX XXX
      for (int i = 0; i < digits.length; i++) {
        if (i == 0 || i == 2 || i == 5) {
          buffer.write(' ');
        }
        buffer.write(digits[i]);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Валидаторы для молдавских и приднестровских номеров
class MoldovaValidators {
  // Коды Приднестровья
  static const _transnistrianCodes = ['533', '552', '555', '557', '215', '210', '216', '219'];

  /// Определяет тип номерного знака
  static PlateType getPlateType(String plate) {
    final cleaned = plate.replaceAll(' ', '').toUpperCase();

    if (cleaned.length != 6) return PlateType.unknown;

    // Молдова: 3 буквы + 3 цифры
    if (RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(cleaned)) {
      return PlateType.moldova;
    }

    // Приднестровье: 1 буква + 3 цифры + 2 буквы
    if (RegExp(r'^[A-Z][0-9]{3}[A-Z]{2}$').hasMatch(cleaned)) {
      return PlateType.transnistria;
    }

    return PlateType.unknown;
  }

  /// Валидация гос. номера (Молдова или Приднестровье)
  static String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите гос. номер';
    }

    final cleaned = value.replaceAll(' ', '').toUpperCase();

    if (cleaned.length != 6) {
      return 'Номер должен содержать 6 символов';
    }

    final type = getPlateType(cleaned);

    if (type == PlateType.unknown) {
      return 'Формат: ABC 123 или A 123 BC';
    }

    return null;
  }

  /// Валидация номера телефона (Молдова или Приднестровье)
  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty || value.trim() == '+373') {
      if (required) {
        return 'Введите номер телефона';
      }
      return null;
    }

    // Получаем только цифры
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Должно быть 11 цифр (373 + 8 цифр)
    if (digits.length < 11) {
      return 'Введите полный номер';
    }

    // Проверяем код страны
    if (!digits.startsWith('373')) {
      return 'Номер должен начинаться с +373';
    }

    final localPart = digits.substring(3);

    // Проверяем приднестровские коды (3-значные)
    if (localPart.length >= 3) {
      final prefix3 = localPart.substring(0, 3);
      if (_transnistrianCodes.contains(prefix3)) {
        // Приднестровский номер - валиден
        return null;
      }
    }

    // Проверяем молдавские префиксы (6, 7 - мобильные, 2, 3 - стационарные)
    final prefix1 = localPart.substring(0, 1);
    if (!['2', '3', '6', '7'].contains(prefix1)) {
      return 'Некорректный номер';
    }

    return null;
  }

  /// Форматирование номера телефона для отображения
  static String formatPhoneForDisplay(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8) return phone;

    String localDigits = digits;
    if (digits.startsWith('373')) {
      localDigits = digits.substring(3);
    }

    if (localDigits.length != 8) return phone;

    // Проверяем приднестровские коды
    if (localDigits.length >= 3) {
      final prefix3 = localDigits.substring(0, 3);
      if (_transnistrianCodes.contains(prefix3)) {
        // +373 XXX XXXXX
        return '+373 ${localDigits.substring(0, 3)} ${localDigits.substring(3)}';
      }
    }

    // Молдова: +373 XX XXX XXX
    return '+373 ${localDigits.substring(0, 2)} ${localDigits.substring(2, 5)} ${localDigits.substring(5)}';
  }

  /// Форматирование гос. номера для отображения
  static String formatPlateForDisplay(String plate) {
    final cleaned = plate.replaceAll(' ', '').toUpperCase();

    if (cleaned.length != 6) return plate.toUpperCase();

    final type = getPlateType(cleaned);

    switch (type) {
      case PlateType.moldova:
        // ABC 123
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3)}';
      case PlateType.transnistria:
        // A 123 BC
        return '${cleaned.substring(0, 1)} ${cleaned.substring(1, 4)} ${cleaned.substring(4)}';
      case PlateType.unknown:
        return plate.toUpperCase();
    }
  }

  /// Проверяет, является ли номер приднестровским
  static bool isTransnistrianPlate(String plate) {
    return getPlateType(plate) == PlateType.transnistria;
  }

  /// Проверяет, является ли телефон приднестровским
  static bool isTransnistrianPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6 && digits.startsWith('373')) {
      final prefix = digits.substring(3, 6);
      return _transnistrianCodes.contains(prefix);
    }
    return false;
  }
}
