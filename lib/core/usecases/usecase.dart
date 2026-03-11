import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:car_repair_manager/core/error/failures/failure.dart';

abstract class UseCase<Return, Params> {
  Future<Either<Failure, Return>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
