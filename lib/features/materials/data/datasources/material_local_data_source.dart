import '../models/material_model.dart';

abstract class MaterialLocalDataSource {
  Future<List<MaterialModel>> getMaterials();
  Future<void> cacheMaterials(List<MaterialModel> materials);
}
