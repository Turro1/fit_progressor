import '../models/car_photo_model.dart';
import '../models/repair_model.dart';

abstract class RepairLocalDataSource {
  Future<List<RepairModel>> getRepairs();
  Future<RepairModel> getRepairById(String id);
  Future<RepairModel> addRepair(RepairModel repair);
  Future<RepairModel> updateRepair(RepairModel repair);
  Future<void> deleteRepair(String repairId);
  Future<List<RepairModel>> searchRepairs(String query);
}

abstract class CarPhotoLocalDataSource {
  Future<List<CarPhotoModel>> getCarPhotos(String carId);
  Future<CarPhotoModel> addCarPhoto(CarPhotoModel photo);
  Future<void> deleteCarPhoto(String photoId);
}
