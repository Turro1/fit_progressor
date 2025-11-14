import 'package:equatable/equatable.dart';

/// Базовый класс для всех ошибок
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}