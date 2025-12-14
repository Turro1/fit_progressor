import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/models/car_photo_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';

class RepairLocalDataSourceImpl implements RepairLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String repairsKey = 'cachedRepairs';

  RepairLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<RepairModel>> getRepairs() async {
    final jsonString = sharedPreferences.getString(repairsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => RepairModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<RepairModel> addRepair(RepairModel repair) async {
    final repairs = await getRepairs();
    repairs.add(repair);
    await _saveRepairs(repairs);
    return repair;
  }

  @override
  Future<RepairModel> updateRepair(RepairModel repair) async {
    final repairs = await getRepairs();
    final index = repairs.indexWhere((r) => r.id == repair.id);
    if (index == -1) {
      throw Exception('Repair not found');
    }
    repairs[index] = repair;
    await _saveRepairs(repairs);
    return repair;
  }

  @override
  Future<void> deleteRepair(String repairId) async {
    final repairs = await getRepairs();
    repairs.removeWhere((r) => r.id == repairId);
    await _saveRepairs(repairs);
  }

  @override
  Future<List<RepairModel>> searchRepairs(String query) async {
    final repairs = await getRepairs();
    final lowercaseQuery = query.toLowerCase();
    return repairs.where((repair) {
      return repair.description.toLowerCase().contains(lowercaseQuery) ||
             repair.carMake!.toLowerCase().contains(lowercaseQuery) ||
             repair.carModel!.toLowerCase().contains(lowercaseQuery) ||
             repair.carPlate!.toLowerCase().contains(lowercaseQuery) ||
             repair.clientName!.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<RepairModel>> getRepairsByStatus(RepairStatus status) async {
    final repairs = await getRepairs();
    return repairs.where((repair) => repair.status == status).toList();
  }

  @override
  Future<List<RepairModel>> getRepairsByCar(String carId) async {
    final repairs = await getRepairs();
    return repairs.where((repair) => repair.carId == carId).toList();
  }

  Future<void> _saveRepairs(List<RepairModel> repairs) async {
    final jsonList = repairs.map((r) => r.toJson()).toList();
    await sharedPreferences.setString(repairsKey, json.encode(jsonList));
  }

  @override
  Future<RepairModel> getRepairById(String id) async {
    final repairs = await getRepairs();
    return repairs.firstWhere((r) => r.id == id,
        orElse: () => throw Exception('Repair not found'));
  }
}

class CarPhotoLocalDataSourceImpl implements CarPhotoLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String carPhotosKey = 'cachedCarPhotos';

  CarPhotoLocalDataSourceImpl({required this.sharedPreferences});

  Future<List<CarPhotoModel>> _getAllCarPhotos() async {
    final jsonString = sharedPreferences.getString(carPhotosKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CarPhotoModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _saveAllCarPhotos(List<CarPhotoModel> photos) async {
    final jsonList = photos.map((p) => p.toJson()).toList();
    await sharedPreferences.setString(carPhotosKey, json.encode(jsonList));
  }

  @override
  Future<List<CarPhotoModel>> getCarPhotos(String carId) async {
    final allPhotos = await _getAllCarPhotos();
    return allPhotos.where((photo) => photo.carId == carId).toList();
  }

  @override
  Future<CarPhotoModel> addCarPhoto(CarPhotoModel photo) async {
    final allPhotos = await _getAllCarPhotos();
    allPhotos.add(photo);
    await _saveAllCarPhotos(allPhotos);
    return photo;
  }

  @override
  Future<void> deleteCarPhoto(String photoId) async {
    final allPhotos = await _getAllCarPhotos();
    allPhotos.removeWhere((photo) => photo.id == photoId);
    await _saveAllCarPhotos(allPhotos);
  }
}
