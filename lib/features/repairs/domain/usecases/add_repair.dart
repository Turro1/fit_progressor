import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../entities/repair_history.dart';
import '../entities/repair_status.dart';
import '../repositories/repair_repository.dart';

class AddRepair implements UseCase<Repair, AddRepairParams> {
  final RepairRepository repository;

  AddRepair(this.repository);

  @override
  Future<Either<Failure, Repair>> call(AddRepairParams params) async {
    final now = DateTime.now();
    final repair = Repair(
      id: 'repair_${now.millisecondsSinceEpoch}',
      carId: params.carId,
      status: params.status,
      description: params.description,
      costWork: params.costWork,
      costParts: 0,
      costPartsCost: 0,
      materials: [],
      materialsCost: 0,
      photos: [],
      history: [
        RepairHistory(
          timestamp: now,
          type: HistoryType.statusChange,
          note: params.status.displayName,
        ),
      ],
      createdAt: now,
    );
    
    return await repository.addRepair(repair);
  }
}

class AddRepairParams {
  final String carId;
  final RepairStatus status;
  final String description;
  final double costWork;

  AddRepairParams({
    required this.carId,
    required this.status,
    required this.description,
    required this.costWork,
  });
}