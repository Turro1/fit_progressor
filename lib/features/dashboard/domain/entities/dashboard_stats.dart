import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int activeRepairs;
  final int lowStockMaterials;
  final double revenueThisMonth;
  final double profitThisMonth;

  const DashboardStats({
    required this.activeRepairs,
    required this.lowStockMaterials,
    required this.revenueThisMonth,
    required this.profitThisMonth,
  });

  @override
  List<Object?> get props => [
    activeRepairs,
    lowStockMaterials,
    revenueThisMonth,
    profitThisMonth,
  ];
}
