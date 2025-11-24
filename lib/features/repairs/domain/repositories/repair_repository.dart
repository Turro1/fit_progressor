import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/repair.dart';
import '../entities/repair_status.dart';

abstract class RepairRepository {

  // Получить ремонты
  Future<Either<Failure, List<Repair>>> getRepairs();

  // Добавить новый ремонт
  Future<Either<Failure, Repair>> addRepair(Repair repair);

  // Обновить ремонт
  Future<Either<Failure, Repair>> updateRepair(Repair repair);

  // Удалить ремонт
  Future<Either<Failure, void>> deleteRepair(String repairId);

  // Найти ремонты по запросу
  Future<Either<Failure, List<Repair>>> searchRepairs(String query);

  // Получить ремонты по статусу
  Future<Either<Failure, List<Repair>>> getRepairsByStatus(RepairStatus status);

  // Получить ремонты автомобиля
  Future<Either<Failure, List<Repair>>> getRepairsByCar(String carId);
}