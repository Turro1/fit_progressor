import '../../domain/entities/car_photo.dart';

class CarPhotoModel extends CarPhoto {
  const CarPhotoModel({
    required super.id,
    required super.carId,
    required super.photoPath,
    super.description,
    required super.createdAt,
  });

  factory CarPhotoModel.fromJson(Map<String, dynamic> json) {
    return CarPhotoModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      photoPath: json['photoPath'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'photoPath': photoPath,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CarPhotoModel.fromEntity(CarPhoto entity) {
    return CarPhotoModel(
      id: entity.id,
      carId: entity.carId,
      photoPath: entity.photoPath,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
