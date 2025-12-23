import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/repair_with_details.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<RepairWithDetails> recentRepairs;

  const DashboardLoaded({required this.stats, required this.recentRepairs});

  @override
  List<Object> get props => [stats, recentRepairs];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
