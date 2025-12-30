import '../models/material_model.dart';

abstract class MaterialLocalDataSource {
  Future<List<MaterialModel>> getMaterials();
  Future<void> cacheMaterials(List<MaterialModel> materials);

  // Эффективные методы для работы с отдельными записями
  Future<MaterialModel> getMaterialById(String id);
  Future<MaterialModel> addMaterial(MaterialModel material);
  Future<MaterialModel> updateMaterial(MaterialModel material);
  Future<void> deleteMaterial(String id);
}
