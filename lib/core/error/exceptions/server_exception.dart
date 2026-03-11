import 'package:car_repair_manager/core/error/exceptions/app_exception.dart';

/// Исключение сервера
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({required super.message, this.statusCode});
}
