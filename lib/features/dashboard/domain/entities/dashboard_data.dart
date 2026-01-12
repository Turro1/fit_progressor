import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'dashboard_stats.dart';

/// Все данные для Dashboard в одном объекте
/// Используется для оптимизации - загрузка всех данных одним запросом
class DashboardData extends Equatable {
  final DashboardStats stats;
  final List<Repair> repairs;
  final List<Client> clients;
  final List<Car> cars;
  final List<Material> materials;

  const DashboardData({
    required this.stats,
    required this.repairs,
    required this.clients,
    required this.cars,
    required this.materials,
  });

  @override
  List<Object?> get props => [stats, repairs, clients, cars, materials];
}
