import 'dart:developer' as developer;

class CarLogoHelper {
  static const String _basePath = 'assets/logos/optimized/';

  /// Получить путь к логотипу по марке автомобиля
  /// Преобразует название марки в формат имени файла (lowercase, пробелы -> дефисы)
  static String getLogoPath(String make) {
    // Нормализуем название марки: lowercase, пробелы -> дефисы
    final normalizedMake = make.toLowerCase().trim().replaceAll(' ', '-');
    final path = '$_basePath$normalizedMake.png';

    developer.log('CarLogoHelper: make="$make" -> path="$path"', name: 'CarLogoHelper');

    return path;
  }
}
