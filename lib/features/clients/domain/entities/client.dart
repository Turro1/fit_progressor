// Клиент
import 'package:fit_progressor/shared/domain/entities/entity.dart';

class Client extends Entity {
  final String name;
  final String phone;
  final int carCount;

  const Client({
    required super.id,
    required this.name,
    required this.phone,
    required super.createdAt,
    this.carCount = 0,
  });

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
    int? carCount,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      carCount: carCount ?? this.carCount,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, carCount];
}
