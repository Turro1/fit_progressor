import 'package:fit_progressor/features/dashboard/presentation/widgets/dashboard_repair_card.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.read<DashboardBloc>().add(LoadDashboard());
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(LoadDashboard());
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }
              if (state is DashboardLoaded) {
                return _buildLoadedBody(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, DashboardLoaded state) {
    final theme = Theme.of(context);
    final groupedRepairs = groupBy(
      state.recentRepairs,
      (repair) => DateUtils.dateOnly(repair.repair.date),
    );

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Row(
          children: [
            Icon(
              Icons.query_stats,
              color: theme.colorScheme.onSurface,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text('Сводка', style: theme.textTheme.headlineMedium),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 15) / 2;
            final cardHeight = cardWidth * 0.65;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: cardWidth / cardHeight,
              children: [
                StatCard(
                  label: 'Активные ремонты',
                  value: state.stats.activeRepairs.toString(),
                  icon: Icons.build,
                  valueColor: theme.colorScheme.secondary,
                ),
                StatCard(
                  label: 'Просрочено',
                  value: state.stats.overdueRepairs.toString(),
                  icon: Icons.schedule,
                  valueColor: state.stats.overdueRepairs > 0
                      ? theme.colorScheme.error
                      : Colors.green,
                ),
                StatCard(
                  label: 'Месячная выручка',
                  value: '${_formatMoney(state.stats.monthlyRevenue)} ₽',
                  icon: Icons.attach_money,
                  valueColor: theme.colorScheme.tertiary,
                ),
                StatCard(
                  label: 'Выполнено за месяц',
                  value: state.stats.completedRepairsThisMonth.toString(),
                  icon: Icons.check_circle,
                  valueColor: Colors.green,
                ),
                StatCard(
                  label: 'Средний чек',
                  value: '${_formatMoney(state.stats.averageRepairCost)} ₽',
                  icon: Icons.receipt_long,
                  valueColor: theme.colorScheme.primary,
                ),
                StatCard(
                  label: 'Низкий остаток',
                  value: state.stats.lowStockMaterials.toString(),
                  icon: Icons.warning_amber,
                  valueColor: state.stats.lowStockMaterials > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 25),
        Text('Предстоящие ремонты', style: theme.textTheme.titleLarge),
        const SizedBox(height: 15),
        if (state.recentRepairs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Нет предстоящих ремонтов',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...groupedRepairs.entries.map((entry) {
            final date = entry.key;
            final repairs = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    _formatDate(date),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ...repairs.map(
                  (repair) => DashboardRepairCard(repairWithDetails: repair),
                ),
              ],
            );
          }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final tomorrow = DateUtils.addDaysToDate(today, 1);
    if (date == today) {
      return 'Сегодня';
    } else if (date == tomorrow) {
      return 'Завтра';
    } else {
      return DateFormat('d MMMM y', 'ru').format(date);
    }
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}М';
    } else if (value >= 1000) {
      final formatted = NumberFormat('#,##0', 'ru').format(value.round());
      return formatted;
    }
    return value.toStringAsFixed(0);
  }
}
