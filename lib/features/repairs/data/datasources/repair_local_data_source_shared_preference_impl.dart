import 'dart:convert';

import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepairLocalDataSourceImpl implements RepairLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String REPAIRS_KEY = 'CACHED_REPAIRS';

  RepairLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<RepairModel>> getRepairs() async {
    final jsonString = sharedPreferences.getString(REPAIRS_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => RepairModel.fromJson(json)).toList();
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
      return repair.description.toLowerCase().contains(lowercaseQuery);
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
    await sharedPreferences.setString(REPAIRS_KEY, json.encode(jsonList));
  }
}