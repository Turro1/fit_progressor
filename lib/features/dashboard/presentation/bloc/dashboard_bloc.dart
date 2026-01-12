import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../clients/domain/entities/client.dart';
import '../../domain/entities/repair_with_details.dart';
import '../../domain/usecases/get_dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({
    required this.getDashboardData,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    // Один запрос загружает все данные (оптимизация)
    final result = await getDashboardData(NoParams());

    result.fold(
      (failure) {
        emit(const DashboardError(message: 'Не удалось загрузить данные'));
      },
      (data) {
        final repairs = data.repairs;
        final clients = data.clients;
        final cars = data.cars;
        final materials = data.materials;

        // Фильтруем будущие ремонты (включая сегодняшние)
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
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
            orElse: () => Client(
              id: '',
              name: 'Неизвестный',
              phone: '',
              createdAt: DateTime.now(),
            ),
          );
          final car = cars.firstWhere(
            (c) => c.id == repair.carId,
            orElse: () => cars.isNotEmpty ? cars.first : throw Exception('No cars'),
          );

          return RepairWithDetails(
            repair: repair,
            clientName: client.name,
            clientPhone: client.phone,
            carFullName: car.fullName,
          );
        }).toList();

        // Получаем материалы с низким остатком
        final lowStockMats = materials
            .where((m) => m.isLowStock || m.isOutOfStock)
            .toList()
          ..sort((a, b) => a.quantity.compareTo(b.quantity));

        if (kDebugMode) {
          debugPrint('Upcoming repairs: ${enrichedRepairs.length}');
          debugPrint('Low stock materials: ${lowStockMats.length}');
        }

        emit(
          DashboardLoaded(
            stats: data.stats,
            recentRepairs: enrichedRepairs,
            lowStockMaterials: lowStockMats,
          ),
        );
      },
    );
  }
}
