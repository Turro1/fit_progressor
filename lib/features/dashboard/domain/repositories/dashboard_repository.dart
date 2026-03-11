import 'package:dartz/dartz.dart';
import 'package:car_repair_manager/core/error/failures/failure.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
}
