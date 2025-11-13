// Клиент
import 'package:fit_progressor/shared/domain/entities/entity.dart';

class Client extends Entity {
  final String name;
  final String? phone;
  final DateTime createdAt;

  const Client({
    required String id,
    required this.name,
    this.phone,
    required this.createdAt,
  }) : super(id: id);

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}