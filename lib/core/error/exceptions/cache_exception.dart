import 'package:fit_progressor/core/error/exceptions/app_exception.dart';

/// Исключение при работе с кэшем/локальным хранилищем
class CacheException extends AppException {
  const CacheException({required super.message});
}
