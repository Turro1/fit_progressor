import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int activeRepairs;
  final int lowStockMaterials;

  const DashboardStats({
    required this.activeRepairs,
    required this.lowStockMaterials,
  });

  @override
  List<Object?> get props => [
        activeRepairs,
        lowStockMaterials,
      ];
}
