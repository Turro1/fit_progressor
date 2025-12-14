import 'package:equatable/equatable.dart';

class CarPhoto extends Equatable {
  final String id;
  final String carId;
  final String photoPath; // Path to the image file or base64 string
  final String? description;
  final DateTime createdAt;

  const CarPhoto({
    required this.id,
    required this.carId,
    required this.photoPath,
    this.description,
    required this.createdAt,
  });

  CarPhoto copyWith({
    String? id,
    String? carId,
    String? photoPath,
    String? description,
    DateTime? createdAt,
  }) {
    return CarPhoto(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, carId, photoPath, description, createdAt];
}
