import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:fit_progressor/features/cars/data/models/car_model.dart';
import 'package:hive/hive.dart';

class CarLocalDataSourceHiveImpl implements CarLocalDataSource{
  static const String _boxName = 'cars';
  final HiveInterface hive;

    CarLocalDataSourceHiveImpl({required this.hive});

  Box<CarModel> get _box => hive.box<CarModel>(_boxName);

  @override
  Future<List<CarModel>> getAllCars() async {
    try{
      return _box.values.toList();
    }
    catch(e){
      throw CacheException(message: 'Не удалось получить автомобили из кэша');
    }
  }

  @override
  Future<CarModel> getCarById(String id) {
    // TODO: implement getCarById
    throw UnimplementedError();
  }

  @override
  Future<CarModel> saveCar(CarModel car) {
    // TODO: implement saveCar
    throw UnimplementedError();
  }

  @override
  Future<List<CarModel>> searchCars(String query) {
    // TODO: implement searchCars
    throw UnimplementedError();
  }

  @override
  Future<CarModel> upadteCar(CarModel car) {
    // TODO: implement upadteCar
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteCar(String id) {
    // TODO: implement deleteCar
    throw UnimplementedError();
  }
}