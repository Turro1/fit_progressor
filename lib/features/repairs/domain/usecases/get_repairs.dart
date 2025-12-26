import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairs implements UseCase<List<Repair>, GetRepairsParams> {
  final RepairRepository repairRepository;

  GetRepairs(this.repairRepository);

  @override
  Future<Either<Failure, List<Repair>>> call(GetRepairsParams params) async {
    return await repairRepository.getRepairs(carId: params.carId);
  }
}

class GetRepairsParams extends Equatable {
  final String? carId;
  final String? clientId;

  const GetRepairsParams({this.carId, this.clientId});

  @override
  List<Object?> get props => [carId, clientId];
}
