import 'package:fit_progressor/core/error/failures/failure.dart';

/// Ошибка кэша/локального хранилища
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
