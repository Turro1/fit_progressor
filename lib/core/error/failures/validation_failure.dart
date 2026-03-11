import 'package:car_repair_manager/core/error/failures/failure.dart';

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
