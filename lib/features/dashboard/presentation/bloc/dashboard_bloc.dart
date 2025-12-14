import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../repairs/domain/usecases/get_repairs.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetRepairs getRepairs;

  DashboardBloc({required this.getDashboardStats, required this.getRepairs})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final statsEither = await getDashboardStats(NoParams());
    final repairsEither = await getRepairs(NoParams());

    statsEither.fold(
      (failure) => emit(
        const DashboardError(message: 'Не удалось загрузить статистику'),
      ),
      (stats) {
        repairsEither.fold(
          (failure) => emit(
            const DashboardError(message: 'Не удалось загрузить ремонты'),
          ),
          (repairs) {
            if (kDebugMode) {
              debugPrint('Total repairs loaded: ${repairs.length}');
              final repairsWithPlannedDate = repairs.where((r) => r.plannedAt != null).toList();
              debugPrint('Repairs with plannedAt date: ${repairsWithPlannedDate.length}');
              for (var r in repairsWithPlannedDate) {
                debugPrint('  - Repair ID: ${r.id}, plannedAt: ${r.plannedAt}');
              }
            }

            final upcomingRepairs = repairs
                .where((r) => r.plannedAt != null && r.plannedAt!.isAfter(DateTime.now()))
                .toList();
            
            if (kDebugMode) {
              debugPrint('Upcoming repairs after filtering: ${upcomingRepairs.length}');
            }

            upcomingRepairs.sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

            emit(DashboardLoaded(stats: stats, recentRepairs: upcomingRepairs));
          },
        );
      },
    );
  }
}
