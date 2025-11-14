import 'package:fit_progressor/core/error/failures/failure.dart';

/// Ошибка сервера
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}