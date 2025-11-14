import 'package:fit_progressor/core/error/failures/failure.dart';

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}