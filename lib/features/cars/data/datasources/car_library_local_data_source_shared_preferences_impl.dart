import 'dart:convert';
import 'package:fit_progressor/features/cars/data/datasources/car_library_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_library_model.dart';

class CarLibraryLocalDataSourceSharedPreferencesImpl implements CarLibraryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CAR_LIBRARY_KEY = 'CACHED_CAR_LIBRARY';

  CarLibraryLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<CarLibraryModel> getCarLibrary() async {
    final jsonString = sharedPreferences.getString(CAR_LIBRARY_KEY);
    if (jsonString == null) {
      return CarLibraryModel.empty();
    }
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return CarLibraryModel.fromJson(jsonMap);
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
    
    // Создаем новую библиотеку с добавленной маркой/моделью
    final newLibrary = library.addMakeModel(upperMake, model);
    
    // Сохраняем
    await _saveCarLibrary(newLibrary);
  }

  Future<void> _saveCarLibrary(CarLibraryModel library) async {
    await sharedPreferences.setString(
      CAR_LIBRARY_KEY,
      json.encode(library.toJson()),
    );
  }
}