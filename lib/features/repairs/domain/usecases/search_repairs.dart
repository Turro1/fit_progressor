import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class SearchRepairs implements UseCase<List<Repair>, String> {
  final RepairRepository repository;

  SearchRepairs(this.repository);

  @override
  Future<Either<Failure, List<Repair>>> call(String query) async {
    return await repository.searchRepairs(query);
  }
}
