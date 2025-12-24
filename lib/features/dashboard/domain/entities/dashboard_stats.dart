import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int activeRepairs;
  final int lowStockMaterials;
  final double monthlyRevenue;
  final int completedRepairsThisMonth;
  final int totalClients;
  final int totalCars;
  final int overdueRepairs;
  final double averageRepairCost;

  const DashboardStats({
    required this.activeRepairs,
    required this.lowStockMaterials,
    required this.monthlyRevenue,
    required this.completedRepairsThisMonth,
    this.totalClients = 0,
    this.totalCars = 0,
    this.overdueRepairs = 0,
    this.averageRepairCost = 0.0,
  });

  @override
  List<Object?> get props => [
    activeRepairs,
    lowStockMaterials,
    monthlyRevenue,
    completedRepairsThisMonth,
    totalClients,
    totalCars,
    overdueRepairs,
    averageRepairCost,
  ];
}
