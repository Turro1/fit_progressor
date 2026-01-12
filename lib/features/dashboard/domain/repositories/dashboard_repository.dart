import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/dashboard_data.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  /// Загружает все данные для Dashboard одним запросом (оптимизация)
  Future<Either<Failure, DashboardData>> getDashboardData();
}
