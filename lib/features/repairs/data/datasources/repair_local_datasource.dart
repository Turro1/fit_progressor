import '../models/repair_model.dart';

abstract class RepairLocalDataSource {
  Future<List<RepairModel>> getRepairs();
  Future<RepairModel> getRepairById(String id);
  Future<RepairModel> addRepair(RepairModel repair);
  Future<RepairModel> updateRepair(RepairModel repair);
  Future<void> deleteRepair(String repairId);
  Future<List<RepairModel>> searchRepairs(String query);
}
