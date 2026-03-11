import 'package:car_repair_manager/core/error/failures/failure.dart';

/// Ошибка кэша/локального хранилища
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
