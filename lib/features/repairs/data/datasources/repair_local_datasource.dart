import '../../domain/entities/repair_status.dart';
import '../models/repair_model.dart';

abstract class RepairLocalDataSource {
  Future<List<RepairModel>> getRepairs();
  Future<RepairModel> addRepair(RepairModel repair);
  Future<RepairModel> updateRepair(RepairModel repair);
  Future<void> deleteRepair(String repairId);
  Future<List<RepairModel>> searchRepairs(String query);
  Future<List<RepairModel>> getRepairsByStatus(RepairStatus status);
  Future<List<RepairModel>> getRepairsByCar(String carId);
}