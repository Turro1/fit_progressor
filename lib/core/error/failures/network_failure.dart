import 'package:fit_progressor/core/error/failures/failure.dart';

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}