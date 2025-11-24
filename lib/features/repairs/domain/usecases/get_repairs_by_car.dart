import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairsByCar implements UseCase<List<Repair>, String> {
  final RepairRepository repository;

  GetRepairsByCar(this.repository);

  @override
  Future<Either<Failure, List<Repair>>> call(String params) async {
    return await repository.getRepairsByCar(params);
  }
}