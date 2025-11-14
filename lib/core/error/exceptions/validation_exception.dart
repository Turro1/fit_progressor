import 'package:fit_progressor/core/error/exceptions/app_exception.dart';

/// Исключение при валидации данных
class ValidationException extends AppException {
  const ValidationException({required super.message});
}