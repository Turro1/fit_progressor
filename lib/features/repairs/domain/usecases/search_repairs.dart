import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class SearchRepairs implements UseCase<List<Repair>, SearchRepairsParams> {
  final RepairRepository repository;

  SearchRepairs(this.repository);

  @override
  Future<Either<Failure, List<Repair>>> call(SearchRepairsParams params) async {
    return await repository.searchRepairs(params.query, carId: params.carId);
  }
}

class SearchRepairsParams extends Equatable {
  final String query;
  final String? carId;

  const SearchRepairsParams({required this.query, this.carId});

  @override
  List<Object?> get props => [query, carId];
}
