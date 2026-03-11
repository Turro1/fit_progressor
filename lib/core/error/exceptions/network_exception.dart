import 'package:car_repair_manager/core/error/exceptions/app_exception.dart';

/// Исключение при работе с сетью
class NetworkException extends AppException {
  const NetworkException({required super.message});
}
