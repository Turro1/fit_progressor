import '../../domain/entities/car_library.dart';

class CarLibraryModel extends CarLibrary {
  const CarLibraryModel({required super.makeModels});

  factory CarLibraryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> makeModels = {};
    
    json.forEach((key, value) {
      if (value is List) {
        makeModels[key] = List<String>.from(value);
      }
    });
    
    return CarLibraryModel(makeModels: makeModels);
  }

  Map<String, dynamic> toJson() {
    return makeModels;
  }

  factory CarLibraryModel.fromEntity(CarLibrary library) {
    return CarLibraryModel(makeModels: library.makeModels);
  }

  static CarLibraryModel empty() {
    return const CarLibraryModel(makeModels: {});
  }

  CarLibraryModel addMakeModel(String make, String model) {
    final newMakeModels = Map<String, List<String>>.from(makeModels);
    final upperMake = make.toUpperCase();
    
    if (!newMakeModels.containsKey(upperMake)) {
      newMakeModels[upperMake] = [];
    }
    
    if (!newMakeModels[upperMake]!.contains(model)) {
      newMakeModels[upperMake] = [...newMakeModels[upperMake]!, model];
    }
    
    return CarLibraryModel(makeModels: newMakeModels);
  }
}