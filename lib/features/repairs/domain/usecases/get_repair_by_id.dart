import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairById implements UseCase<Repair, String> {
  final RepairRepository repository;

  GetRepairById(this.repository);

  @override
  Future<Either<Failure, Repair>> call(String id) async {
    return await repository.getRepairById(id);
  }
}

class GetRepairByIdParams extends Equatable {
  final String id;

  const GetRepairByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
