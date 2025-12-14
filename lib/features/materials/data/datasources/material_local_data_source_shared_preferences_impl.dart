import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/material_model.dart';
import 'material_local_data_source.dart';

const cachedMaterials = 'cachedMaterials';

class MaterialLocalDataSourceSharedPreferencesImpl
    implements MaterialLocalDataSource {
  final SharedPreferences sharedPreferences;

  MaterialLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<List<MaterialModel>> getMaterials() {
    final jsonString = sharedPreferences.getString(cachedMaterials);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final materials =
          jsonList.map((json) => MaterialModel.fromJson(json)).toList();
      return Future.value(materials);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheMaterials(List<MaterialModel> materials) {
    final jsonList = materials.map((material) => material.toJson()).toList();
    return sharedPreferences.setString(
      cachedMaterials,
      json.encode(jsonList),
    );
  }
}
