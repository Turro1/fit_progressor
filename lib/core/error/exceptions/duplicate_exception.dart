/// Исключение при попытке создать дубликат
class DuplicateException implements Exception {
  final String message;

  const DuplicateException({required this.message});

  @override
  String toString() => message;
}
