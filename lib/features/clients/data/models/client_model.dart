import 'package:fit_progressor/features/clients/domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.phone,
    required super.name,
    super.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ClientModel.fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      phone: client.phone,
      name: client.name,
      createdAt: client.createdAt,
    );
  }

  Client toEntity() {
    return Client(id: id, phone: phone, name: name, createdAt: createdAt);
  }
}
