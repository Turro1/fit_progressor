import '../models/repair_model.dart';

/// Параметры фильтрации для getRepairsFiltered
class RepairFilterParams {
  final String? carId;
  final String? clientId;
  final List<int>? statuses; // RepairStatus.index values
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? limit;
  final int? offset;

  const RepairFilterParams({
    this.carId,
    this.clientId,
    this.statuses,
    this.dateFrom,
    this.dateTo,
    this.limit,
    this.offset,
  });

  bool get hasFilters =>
      carId != null ||
      clientId != null ||
      (statuses != null && statuses!.isNotEmpty) ||
      dateFrom != null ||
      dateTo != null;
}

abstract class RepairLocalDataSource {
  Future<List<RepairModel>> getRepairs();
  Future<RepairModel> getRepairById(String id);
  Future<RepairModel> addRepair(RepairModel repair);
  Future<RepairModel> updateRepair(RepairModel repair);
  Future<void> deleteRepair(String repairId);
  Future<List<RepairModel>> searchRepairs(String query);

  /// Загружает ремонты с фильтрацией на уровне datasource (оптимизация)
  Future<List<RepairModel>> getRepairsFiltered(RepairFilterParams params);

  /// Возвращает общее количество ремонтов (для пагинации)
  Future<int> getRepairsCount([RepairFilterParams? params]);
}
