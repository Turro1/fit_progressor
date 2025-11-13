import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

class DashboardStats {
  final int activeRepairsCount;
  final int lowStockMaterialsCount;
  final double monthlyRevenue;
  final double monthlyProfit;
  final List<Repair> recentRepairs;

  DashboardStats({
    required this.activeRepairsCount,
    required this.lowStockMaterialsCount,
    required this.monthlyRevenue,
    required this.monthlyProfit,
    required this.recentRepairs,
  });
}