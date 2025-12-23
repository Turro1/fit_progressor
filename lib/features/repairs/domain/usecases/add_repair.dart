import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class AddRepair implements UseCase<Repair, AddRepairParams> {
  final RepairRepository repairRepository;

  AddRepair({required this.repairRepository});

  @override
  Future<Either<Failure, Repair>> call(AddRepairParams params) async {
    final now = DateTime.now();

    final repair = Repair(
      id: 'repair_${now.millisecondsSinceEpoch}',
      partType: params.partType,
      partPosition: params.partPosition,
      photoPaths: params.photoPaths,
      description: params.description,
      date: params.date,
      cost: params.cost,
      clientId: params.clientId,
      carId: params.carId,
      carMake: params.carMake,
      carModel: params.carModel,
      createdAt: now,
    );

    return await repairRepository.addRepair(repair);
  }
}

class AddRepairParams extends Equatable {
  final String partType;
  final String partPosition;
  final List<String> photoPaths;
  final String description;
  final DateTime date;
  final double cost;
  final String clientId;
  final String carId;
  final String carMake;
  final String carModel;

  const AddRepairParams({
    required this.partType,
    required this.partPosition,
    this.photoPaths = const [],
    this.description = '',
    required this.date,
    required this.cost,
    required this.clientId,
    required this.carId,
    this.carMake = '',
    this.carModel = '',
  });

  @override
  List<Object?> get props => [
    partType,
    partPosition,
    photoPaths,
    description,
    date,
    cost,
    clientId,
    carId,
    carMake,
    carModel,
  ];
}
