import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class UpdateRepair implements UseCase<Repair, Repair> {
  final RepairRepository repository;

  UpdateRepair(this.repository);

  @override
  Future<Either<Failure, Repair>> call(Repair params) async {
    return await repository.updateRepair(params);
  }
}