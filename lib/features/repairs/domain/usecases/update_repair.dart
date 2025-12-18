import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class UpdateRepair implements UseCase<Repair, Repair> {
  final RepairRepository repairRepository;

  UpdateRepair({
    required this.repairRepository,
  });

  @override
  Future<Either<Failure, Repair>> call(Repair newRepair) async {
    return await repairRepository.updateRepair(newRepair);
  }
}
