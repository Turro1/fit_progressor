import 'package:equatable/equatable.dart';

abstract class Entity extends Equatable {
  final String id;
  final DateTime? createdAt;

  const Entity({required this.id, required this.createdAt});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
