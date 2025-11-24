import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairs implements UseCase<List<Repair>, NoParams> {
  final RepairRepository repository;

  GetRepairs(this.repository);

  @override
  Future<Either<Failure, List<Repair>>> call(NoParams params) async {
    return await repository.getRepairs();
  }
}