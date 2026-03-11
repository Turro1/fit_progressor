import 'package:car_repair_manager/core/error/exceptions/app_exception.dart';

/// Исключение при валидации данных
class ValidationException extends AppException {
  const ValidationException({required super.message});
}
