import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import '../repositories/repair_repository.dart';

class DeleteRepair implements UseCase<void, String> {
  final RepairRepository repairRepository;

  DeleteRepair({
    required this.repairRepository,
  });

  @override
  Future<Either<Failure, void>> call(String repairId) async {
    return await repairRepository.deleteRepair(repairId);
  }
}
