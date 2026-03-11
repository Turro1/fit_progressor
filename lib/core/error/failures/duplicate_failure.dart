import 'package:car_repair_manager/core/error/failures/failure.dart';

/// Ошибка дублирования данных
class DuplicateFailure extends Failure {
  const DuplicateFailure({required super.message});
}
