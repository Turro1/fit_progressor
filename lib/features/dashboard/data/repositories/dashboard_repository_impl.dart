import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/materials/domain/repositories/material_repository.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final RepairRepository repairRepository;
  final MaterialRepository materialRepository;
  final ClientRepository clientRepository;
  final CarRepository carRepository;

  DashboardRepositoryImpl({
    required this.repairRepository,
    required this.materialRepository,
    required this.clientRepository,
    required this.carRepository,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    // Используем getDashboardData и извлекаем только stats
    final result = await getDashboardData();
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.stats),
    );
  }

  /// Строит данные для графика выручки за 30 дней
  /// [daysOffset] - смещение от сегодня (0 = последние 30 дней, 30 = 30-60 дней назад)
  RevenueChartData _buildRevenueChart(
    List<Repair> repairs,
    DateTime now,
    int daysOffset,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final dailyData = <DailyRevenue>[];
    double maxValue = 0;
    double totalRevenue = 0;

    // 30 дней с учетом смещения
    for (int i = 29 + daysOffset; i >= daysOffset; i--) {
      final date = today.subtract(Duration(days: i));

      final dayRepairs = repairs.where((repair) {
        final repairDate = DateTime(
          repair.date.year,
          repair.date.month,
          repair.date.day,
        );
        return repairDate == date && repair.status == RepairStatus.completed;
      }).toList();

      final dayRevenue = dayRepairs.fold<double>(
        0.0,
        (sum, r) => sum + r.cost,
      );

      if (dayRevenue > maxValue) {
        maxValue = dayRevenue;
      }
      totalRevenue += dayRevenue;

      dailyData.add(DailyRevenue(
        date: date,
        revenue: dayRevenue,
        repairsCount: dayRepairs.length,
      ));
    }

    return RevenueChartData(
      dailyRevenue: dailyData,
      maxValue: maxValue,
      totalRevenue: totalRevenue,
    );
  }

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    // Параллельная загрузка всех данных для оптимизации
    final repairsEither = await repairRepository.getRepairs();
    final materialsEither = await materialRepository.getAllMaterials();
    final clientsEither = await clientRepository.getAllClients();
    final carsEither = await carRepository.getCars();

    // Используем fold для безопасного извлечения данных
    return repairsEither.fold(
      (failure) => Left(failure),
      (repairs) => materialsEither.fold(
        (failure) => Left(failure),
        (materials) => clientsEither.fold(
          (failure) => Left(failure),
          (clients) => carsEither.fold(
            (failure) => Left(failure),
            (cars) {
              // Вычисляем статистику
              final stats = _calculateStats(repairs, materials, clients, cars);

              return Right(DashboardData(
                stats: stats,
                repairs: repairs,
                clients: clients,
                cars: cars,
                materials: materials,
              ));
            },
          ),
        ),
      ),
    );
  }

  /// Вычисляет статистику из загруженных данных
  DashboardStats _calculateStats(
    List<Repair> repairs,
    List<Material> materials,
    List<Client> clients,
    List<Car> cars,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Прошлый месяц
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    // Активные ремонты (в работе, не завершенные)
    final activeRepairs = repairs.where((repair) {
      return repair.status == RepairStatus.pending ||
          repair.status == RepairStatus.inProgress;
    }).length;

    // Материалы с низким остатком
    final lowStockMaterials = materials.where((material) {
      return material.quantity < material.minQuantity;
    }).length;

    // Ремонты за текущий месяц
    final monthlyRepairs = repairs.where((repair) {
      return repair.date.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          repair.date.isBefore(
            endOfMonth.add(const Duration(seconds: 1)),
          );
    }).toList();

    // Ремонты за прошлый месяц
    final lastMonthRepairs = repairs.where((repair) {
      return repair.date.isAfter(
            startOfLastMonth.subtract(const Duration(seconds: 1)),
          ) &&
          repair.date.isBefore(
            endOfLastMonth.add(const Duration(seconds: 1)),
          );
    }).toList();

    // Месячная выручка (только завершенные)
    final completedMonthlyRepairs = monthlyRepairs
        .where((r) => r.status == RepairStatus.completed)
        .toList();
    final monthlyRevenue = completedMonthlyRepairs.fold<double>(
      0.0,
      (sum, repair) => sum + repair.cost,
    );

    // Выручка прошлого месяца
    final completedLastMonthRepairs = lastMonthRepairs
        .where((r) => r.status == RepairStatus.completed)
        .toList();
    final lastMonthRevenue = completedLastMonthRepairs.fold<double>(
      0.0,
      (sum, repair) => sum + repair.cost,
    );

    // Количество завершенных ремонтов за месяц
    final completedRepairsThisMonth = completedMonthlyRepairs.length;
    final lastMonthCompletedRepairs = completedLastMonthRepairs.length;

    // Просроченные ремонты (дата в прошлом, но не завершен и не отменен)
    final overdueRepairs = repairs.where((repair) {
      final repairDate = DateTime(
        repair.date.year,
        repair.date.month,
        repair.date.day,
      );
      return repairDate.isBefore(today) &&
          repair.status != RepairStatus.completed &&
          repair.status != RepairStatus.cancelled;
    }).length;

    // Средняя стоимость ремонта (текущий месяц)
    final averageRepairCost = completedMonthlyRepairs.isNotEmpty
        ? completedMonthlyRepairs.fold<double>(
              0.0,
              (sum, r) => sum + r.cost,
            ) /
            completedMonthlyRepairs.length
        : 0.0;

    // Средняя стоимость ремонта (прошлый месяц)
    final lastMonthAverageCost = completedLastMonthRepairs.isNotEmpty
        ? completedLastMonthRepairs.fold<double>(
              0.0,
              (sum, r) => sum + r.cost,
            ) /
            completedLastMonthRepairs.length
        : 0.0;

    // Чистая выручка (прибыль) = выручка - стоимость материалов
    final monthlyMaterialsCost = completedMonthlyRepairs.fold<double>(
      0.0,
      (sum, repair) => sum + repair.materialsCost,
    );
    final monthlyNetRevenue = monthlyRevenue - monthlyMaterialsCost;

    // Чистая выручка прошлого месяца
    final lastMonthMaterialsCost = completedLastMonthRepairs.fold<double>(
      0.0,
      (sum, repair) => sum + repair.materialsCost,
    );
    final lastMonthNetRevenue = lastMonthRevenue - lastMonthMaterialsCost;

    // Расчёт трендов
    final revenueTrend = TrendData.fromValues(monthlyRevenue, lastMonthRevenue);
    final netRevenueTrend = TrendData.fromValues(
      monthlyNetRevenue,
      lastMonthNetRevenue,
    );
    final completedRepairsTrend = TrendData.fromValues(
      completedRepairsThisMonth.toDouble(),
      lastMonthCompletedRepairs.toDouble(),
    );
    final averageCostTrend = TrendData.fromValues(
      averageRepairCost,
      lastMonthAverageCost,
    );

    // Данные для графика выручки по дням (последние 30 дней)
    final revenueChart = _buildRevenueChart(repairs, now, 0);
    // Данные за предыдущий период (30-60 дней назад)
    final previousPeriodChart = _buildRevenueChart(repairs, now, 30);

    return DashboardStats(
      activeRepairs: activeRepairs,
      lowStockMaterials: lowStockMaterials,
      monthlyRevenue: monthlyRevenue,
      completedRepairsThisMonth: completedRepairsThisMonth,
      totalClients: clients.length,
      totalCars: cars.length,
      overdueRepairs: overdueRepairs,
      averageRepairCost: averageRepairCost,
      monthlyNetRevenue: monthlyNetRevenue,
      netRevenueTrend: netRevenueTrend,
      revenueTrend: revenueTrend,
      completedRepairsTrend: completedRepairsTrend,
      averageCostTrend: averageCostTrend,
      revenueChart: revenueChart,
      previousPeriodChart: previousPeriodChart,
      lastMonthRevenue: lastMonthRevenue,
      lastMonthCompletedRepairs: lastMonthCompletedRepairs,
    );
  }
}
