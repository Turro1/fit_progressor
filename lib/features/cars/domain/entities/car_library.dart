import 'package:equatable/equatable.dart';

/// Библиотека марок и моделей автомобилей для автозаполнения
class CarLibrary extends Equatable {
  final Map<String, List<String>> makeModels;

  const CarLibrary({required this.makeModels});

  @override
  List<Object?> get props => [makeModels];

  List<String> getMakes() {
    return makeModels.keys.toList()..sort();
  }

  List<String> getModels(String make) {
    return makeModels[make.toUpperCase()] ?? [];
  }

  bool hasMake(String make) {
    return makeModels.containsKey(make.toUpperCase());
  }
}
