class CarLibrary {
  final Map<String, List<String>> makesAndModels;

  CarLibrary({required this.makesAndModels});

  List<String> get makes => makesAndModels.keys.toList();
  
  List<String> getModelsForMake(String make) {
    return makesAndModels[make] ?? [];
  }

  CarLibrary copyWith({
    Map<String, List<String>>? makesAndModels,
  }) {
    return CarLibrary(
      makesAndModels: makesAndModels ?? this.makesAndModels,
    );
  }
}