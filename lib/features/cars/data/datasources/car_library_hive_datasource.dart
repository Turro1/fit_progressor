import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_library_local_data_source.dart';
import '../models/car_library_model.dart';

/// Hive implementation of CarLibraryLocalDataSource
class CarLibraryHiveDataSource implements CarLibraryLocalDataSource {
  static const String _carLibraryKey = 'car_library';

  @override
  Future<CarLibraryModel> getCarLibrary() async {
    final data = HiveConfig.settingsBox.get(_carLibraryKey);
    if (data == null) {
      return CarLibraryModel.empty();
    }
    // Data is stored as Map<dynamic, dynamic>, need to convert
    final Map<String, List<String>> makeModels = {};
    (data as Map).forEach((key, value) {
      if (value is List) {
        makeModels[key.toString()] = List<String>.from(value);
      }
    });
    return CarLibraryModel(makeModels: makeModels);
  }

  @override
  Future<List<String>> getCarMakes() async {
    final library = await getCarLibrary();
    return library.getMakes();
  }

  @override
  Future<List<String>> getCarModels(String make) async {
    final library = await getCarLibrary();
    return library.getModels(make);
  }

  @override
  Future<void> addToLibrary(String make, String model) async {
    final library = await getCarLibrary();
    final upperMake = make.toUpperCase();

    // Create new library with added make/model
    final newLibrary = library.addMakeModel(upperMake, model);

    // Save
    await HiveConfig.settingsBox.put(_carLibraryKey, newLibrary.toJson());
  }
}
