import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

//Репозиторий ремонтов
abstract class RepairRepository {

  // Получить все ремонты
  Future<Either<Failure, List<Repair>>> getAllRepairs();

  // Получить ремонт по ID
  Future<Either<Failure, Repair>> getRepairById(String id);
  
  // Добавить новый ремонт
  Future<Either<Failure, Repair>> addRepair(Repair repair);

  // Обновить существующий ремонт
  Future<Either<Failure, Repair>> updateRepair(Repair repair);

  // Удалить ремонт
  Future<Either<Failure, void>> deleteRepair(String id);

  // Поиск ремонтов по запросу
  Future<Either<Failure, List<Repair>>> searchRepairs(String query);
}