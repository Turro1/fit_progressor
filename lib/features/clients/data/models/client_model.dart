import 'package:hive/hive.dart';
import '../../domain/entities/client.dart';

@HiveType(typeId: 0)
class ClientModel extends Client {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final DateTime createdAt;

  const ClientModel({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt 
  }) : super(
          id: id,
          name: name,
          phone: phone,
          createdAt: createdAt
        );

  /// Создание модели из entity
  factory ClientModel.fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      name: client.name,
      phone: client.phone,
      createdAt: client.createdAt
    );
  }

  /// Конвертация в entity
  Client toEntity() {
    return Client(
      id: id,
      name: name,
      phone: phone, 
      createdAt: createdAt,
    );
  }

  /// Из JSON (для SharedPreferences)
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] as DateTime
    );
  }

  /// В JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'createdAt': createdAt
    };
  }

  /// CopyWith для удобного обновления
  ClientModel copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt
    );
  }

  @override
  String toString() => 'ClientModel(id: $id, name: $name, phone: $phone, createdAt: $createdAt)';
}