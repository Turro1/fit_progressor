import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../cars/domain/usecases/get_cars.dart';
import '../../../clients/domain/usecases/get_clients.dart';
import '../../../materials/domain/usecases/get_materials.dart';
import '../../../repairs/domain/usecases/get_repairs.dart';
import '../../domain/entities/repair_with_details.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetRepairs getRepairs;
  final GetClients getClients;
  final GetCars getCars;
  final GetMaterials getMaterials;

  DashboardBloc({
    required this.getDashboardStats,
    required this.getRepairs,
    required this.getClients,
    required this.getCars,
    required this.getMaterials,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    // Загружаем все необходимые данные
    final statsEither = await getDashboardStats(NoParams());
    final repairsEither = await getRepairs(const GetRepairsParams());
    final clientsEither = await getClients(NoParams());
    final carsEither = await getCars(NoParams());
    final materialsEither = await getMaterials(NoParams());

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
            clientsEither.fold(
              (failure) => emit(
                const DashboardError(message: 'Не удалось загрузить клиентов'),
              ),
              (clients) {
                carsEither.fold(
                  (failure) => emit(
                    const DashboardError(
                      message: 'Не удалось загрузить автомобили',
                    ),
                  ),
                  (cars) {
                    // Фильтруем будущие ремонты (включая сегодняшние)
                    final today = DateTime.now();
                    final todayOnly = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    final futureRepairs = repairs.where((repair) {
                      final repairDateOnly = DateTime(
                        repair.date.year,
                        repair.date.month,
                        repair.date.day,
                      );
                      return !repairDateOnly.isBefore(todayOnly);
                    }).toList();

                    // Сортируем по дате ремонта (ближайшие первыми)
                    futureRepairs.sort((a, b) => a.date.compareTo(b.date));

                    // Берем первые 10 предстоящих ремонтов
                    final upcoming = futureRepairs.take(10).toList();

                    // Обогащаем данные ремонтов информацией о клиенте и авто
                    final enrichedRepairs = upcoming.map((repair) {
                      final client = clients.firstWhere(
                        (c) => c.id == repair.clientId,
                        orElse: () => clients.first,
                      );
                      final car = cars.firstWhere(
                        (c) => c.id == repair.carId,
                        orElse: () => cars.first,
                      );

                      return RepairWithDetails(
                        repair: repair,
                        clientName: client.name,
                        clientPhone: client.phone,
                        carFullName: car.fullName,
                      );
                    }).toList();

                    // Получаем материалы с низким остатком
                    final lowStockMats = materialsEither.fold(
                      (_) => <dynamic>[],
                      (materials) => materials
                          .where((m) => m.isLowStock || m.isOutOfStock)
                          .toList()
                        ..sort((a, b) => a.quantity.compareTo(b.quantity)),
                    );

                    if (kDebugMode) {
                      debugPrint('Upcoming repairs: ${enrichedRepairs.length}');
                      debugPrint('Low stock materials: ${lowStockMats.length}');
                    }

                    emit(
                      DashboardLoaded(
                        stats: stats,
                        recentRepairs: enrichedRepairs,
                        lowStockMaterials: lowStockMats.cast(),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
