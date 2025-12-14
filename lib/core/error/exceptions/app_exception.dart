/// Базовый класс для всех исключений
abstract class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => message;
}
