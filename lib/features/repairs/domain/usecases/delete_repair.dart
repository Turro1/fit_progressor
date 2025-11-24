import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/repair_repository.dart';

class DeleteRepair implements UseCase<void, String> {
  final RepairRepository repository;

  DeleteRepair(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteRepair(params);
  }
}