import 'package:equatable/equatable.dart';

/// Направление тренда
enum TrendDirection {
  up,
  down,
  neutral;

  bool get isPositive => this == TrendDirection.up;
  bool get isNegative => this == TrendDirection.down;
}

/// Данные о тренде
class TrendData extends Equatable {
  final double percentChange;
  final TrendDirection direction;
  final double previousValue;

  const TrendData({
    required this.percentChange,
    required this.direction,
    required this.previousValue,
  });

  const TrendData.neutral()
      : percentChange = 0,
        direction = TrendDirection.neutral,
        previousValue = 0;

  /// Создаёт TrendData из текущего и предыдущего значения
  factory TrendData.fromValues(double current, double previous) {
    if (previous == 0) {
      if (current > 0) {
        return const TrendData(
          percentChange: 100,
          direction: TrendDirection.up,
          previousValue: 0,
        );
      }
      return const TrendData.neutral();
    }

    final change = ((current - previous) / previous) * 100;
    final direction = change > 0.5
        ? TrendDirection.up
        : change < -0.5
            ? TrendDirection.down
            : TrendDirection.neutral;

    return TrendData(
      percentChange: change.abs(),
      direction: direction,
      previousValue: previous,
    );
  }

  @override
  List<Object?> get props => [percentChange, direction, previousValue];
}

/// Данные для графика выручки по дням
class RevenueChartData extends Equatable {
  final List<DailyRevenue> dailyRevenue;
  final double maxValue;
  final double totalRevenue;

  const RevenueChartData({
    required this.dailyRevenue,
    required this.maxValue,
    required this.totalRevenue,
  });

  const RevenueChartData.empty()
      : dailyRevenue = const [],
        maxValue = 0,
        totalRevenue = 0;

  @override
  List<Object?> get props => [dailyRevenue, maxValue, totalRevenue];
}

/// Выручка за день
class DailyRevenue extends Equatable {
  final DateTime date;
  final double revenue;
  final int repairsCount;

  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.repairsCount,
  });

  @override
  List<Object?> get props => [date, revenue, repairsCount];
}

class DashboardStats extends Equatable {
  final int activeRepairs;
  final int lowStockMaterials;
  final double monthlyRevenue;
  final int completedRepairsThisMonth;
  final int totalClients;
  final int totalCars;
  final int overdueRepairs;
  final double averageRepairCost;

  // Чистая выручка (прибыль)
  final double monthlyNetRevenue;
  final TrendData netRevenueTrend;

  // Тренды (сравнение с прошлым месяцем)
  final TrendData revenueTrend;
  final TrendData completedRepairsTrend;
  final TrendData averageCostTrend;

  // Данные для графика
  final RevenueChartData revenueChart;

  // Прошлый месяц
  final double lastMonthRevenue;
  final int lastMonthCompletedRepairs;

  const DashboardStats({
    required this.activeRepairs,
    required this.lowStockMaterials,
    required this.monthlyRevenue,
    required this.completedRepairsThisMonth,
    this.totalClients = 0,
    this.totalCars = 0,
    this.overdueRepairs = 0,
    this.averageRepairCost = 0.0,
    this.monthlyNetRevenue = 0.0,
    this.netRevenueTrend = const TrendData.neutral(),
    this.revenueTrend = const TrendData.neutral(),
    this.completedRepairsTrend = const TrendData.neutral(),
    this.averageCostTrend = const TrendData.neutral(),
    this.revenueChart = const RevenueChartData.empty(),
    this.lastMonthRevenue = 0,
    this.lastMonthCompletedRepairs = 0,
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
    monthlyNetRevenue,
    netRevenueTrend,
    revenueTrend,
    completedRepairsTrend,
    averageCostTrend,
    revenueChart,
    lastMonthRevenue,
    lastMonthCompletedRepairs,
  ];
}
