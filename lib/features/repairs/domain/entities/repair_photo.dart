import 'package:fit_progressor/shared/domain/entities/entity.dart';

class RepairPhoto extends Entity {
  final String repairId;
  final String name;
  final String type; // MIME type
  final String data; // Base64 encoded data
  final DateTime createdAt;

  RepairPhoto({
    required String id,
    required this.repairId,
    required this.name,
    required this.type,
    required this.data,
    required this.createdAt,
  }) :super(id: id, createdAt: createdAt);

  bool get isImage => type.startsWith('image/');
  bool get isPdf => type == 'application/pdf';

  RepairPhoto copyWith({
    String? id,
    String? repairId,
    String? name,
    String? type,
    String? data,
    DateTime? createdAt,
  }) {
    return RepairPhoto(
      id: id ?? this.id,
      repairId: repairId ?? this.repairId,
      name: name ?? this.name,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [ id, repairId, name, type, data, createdAt];
}