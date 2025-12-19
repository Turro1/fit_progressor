import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';

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
      // TODO: Improve search by including car and client details.
      // This will require fetching car and client data first.
      return repair.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _saveRepairs(List<RepairModel> repairs) async {
    final jsonList = repairs.map((r) => r.toJson()).toList();
    await sharedPreferences.setString(repairsKey, json.encode(jsonList));
  }

  @override
  Future<RepairModel> getRepairById(String id) async {
    final repairs = await getRepairs();
    return repairs.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Repair not found'),
    );
  }
}