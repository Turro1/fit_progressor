import 'package:dartz/dartz.dart';
import '../../../../core/error/failures/failure.dart';
import '../entities/repair.dart';

abstract class RepairRepository {
  Future<Either<Failure, List<Repair>>> getRepairs({String? carId});
  Future<Either<Failure, Repair>> getRepairById(String id);
  Future<Either<Failure, Repair>> addRepair(Repair repair);
  Future<Either<Failure, Repair>> updateRepair(Repair repair);
  Future<Either<Failure, void>> deleteRepair(String repairId);
  Future<Either<Failure, List<Repair>>> searchRepairs(
    String query, {
    String? carId,
  });
}
