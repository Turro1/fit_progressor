import 'package:car_repair_manager/core/error/failures/failure.dart';

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
