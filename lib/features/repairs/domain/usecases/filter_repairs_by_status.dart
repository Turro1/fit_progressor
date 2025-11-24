import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../entities/repair_status.dart';
import '../repositories/repair_repository.dart';

class FilterRepairsByStatus implements UseCase<List<Repair>, RepairStatus> {
  final RepairRepository repository;

  FilterRepairsByStatus(this.repository);

  @override
  Future<Either<Failure, List<Repair>>> call(RepairStatus params) async {
    return await repository.getRepairsByStatus(params);
  }
}