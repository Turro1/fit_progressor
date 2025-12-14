import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final RepairRepository repairRepository;
  final MaterialRepository materialRepository;

  DashboardRepositoryImpl({
    required this.repairRepository,
    required this.materialRepository,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    final repairsEither = await repairRepository.getRepairs();
    final materialsEither = await materialRepository.getAllMaterials();

    return repairsEither.fold((failure) => Left(failure), (repairs) {
      return materialsEither.fold((failure) => Left(failure), (materials) {
        final now = DateTime.now();

        final activeRepairs = repairs
            .where(
              (r) =>
                  r.status == RepairStatus.inProgress ||
                  r.status == RepairStatus.waitingParts,
            )
            .length;

        final lowStockMaterials = materials.where((m) => m.isLowStock).length;

        final revenueThisMonth = repairs
            .where(
              (r) =>
                  r.status == RepairStatus.completed &&
                  r.createdAt.month == now.month &&
                  r.createdAt.year == now.year,
            )
            .fold(0.0, (sum, r) => sum + r.totalCost);

        final profitThisMonth = repairs
            .where(
              (r) =>
                  r.status == RepairStatus.completed &&
                  r.createdAt.month == now.month &&
                  r.createdAt.year == now.year,
            )
            .fold(0.0, (sum, r) => sum + r.profit);

        return Right(
          DashboardStats(
            activeRepairs: activeRepairs,
            lowStockMaterials: lowStockMaterials,
            revenueThisMonth: revenueThisMonth,
            profitThisMonth: profitThisMonth,
          ),
        );
      });
    });
  }
}
