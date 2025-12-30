import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/widgets/client_form_modal.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/dashboard_repair_card.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart' show MaterialUnitExtension;
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:fit_progressor/shared/widgets/tap_scale_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
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

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
            child: Row(
              children: [
                Icon(
                  Icons.query_stats,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Сводка', style: theme.textTheme.headlineMedium),
                ),
                _ActionButton(
                  icon: Icons.settings,
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Настройки',
                ),
              ],
            ),
          ),
        ),

        // Статистические карточки (Grid)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildListDelegate([
              StatCard(
                label: 'Чистая прибыль',
                value: '${_formatMoney(state.stats.monthlyNetRevenue)} ₽',
                numericValue: state.stats.monthlyNetRevenue,
                icon: Icons.trending_up,
                valueColor: state.stats.monthlyNetRevenue >= 0
                    ? Colors.green
                    : theme.colorScheme.error,
                trend: state.stats.netRevenueTrend,
                isHighlighted: true,
                tooltipContent: TrendTooltipContent(
                  currentValue: '${_formatMoney(state.stats.monthlyNetRevenue)} ₽',
                  previousValue: '${_formatMoney(state.stats.netRevenueTrend.previousValue)} ₽',
                  periodLabel: 'Прошлый месяц',
                  isPositive: state.stats.monthlyNetRevenue >= state.stats.netRevenueTrend.previousValue,
                ),
              ),
              StatCard(
                label: 'Выполнено за месяц',
                value: state.stats.completedRepairsThisMonth.toString(),
                numericValue: state.stats.completedRepairsThisMonth.toDouble(),
                icon: Icons.check_circle,
                valueColor: Colors.green,
                trend: state.stats.completedRepairsTrend,
                tooltipContent: TrendTooltipContent(
                  currentValue: '${state.stats.completedRepairsThisMonth} ремонтов',
                  previousValue: '${state.stats.lastMonthCompletedRepairs} ремонтов',
                  periodLabel: 'Прошлый месяц',
                  isPositive: state.stats.completedRepairsThisMonth >= state.stats.lastMonthCompletedRepairs,
                ),
              ),
              StatCard(
                label: 'Средний чек',
                value: '${_formatMoney(state.stats.averageRepairCost)} ₽',
                numericValue: state.stats.averageRepairCost,
                icon: Icons.receipt_long,
                valueColor: theme.colorScheme.primary,
                trend: state.stats.averageCostTrend,
                tooltipContent: TrendTooltipContent(
                  currentValue: '${_formatMoney(state.stats.averageRepairCost)} ₽',
                  previousValue: '${_formatMoney(state.stats.averageCostTrend.previousValue)} ₽',
                  periodLabel: 'Прошлый месяц',
                  isPositive: state.stats.averageRepairCost >= state.stats.averageCostTrend.previousValue,
                ),
              ),
              StatCard(
                label: 'Низкий остаток',
                value: state.stats.lowStockMaterials.toString(),
                numericValue: state.stats.lowStockMaterials.toDouble(),
                icon: Icons.warning_amber,
                valueColor: state.stats.lowStockMaterials > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
                invertTrendColors: true,
                tooltipContent: LowStockTooltipContent(
                  items: state.lowStockMaterials.map((m) => LowStockItem(
                    name: m.name,
                    quantity: m.quantity.toStringAsFixed(
                      m.quantity.truncateToDouble() == m.quantity ? 0 : 1,
                    ),
                    unit: m.unit.displayName,
                    isOutOfStock: m.isOutOfStock,
                  )).toList(),
                ),
              ),
            ]),
          ),
        ),

        // Быстрые действия
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: _QuickActionsSection(),
          ),
        ),

        // График выручки
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: RevenueChart(
              data: state.stats.revenueChart,
              previousPeriodData: state.stats.previousPeriodChart,
            ),
          ),
        ),

        // Заголовок "Предстоящие ремонты"
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
            child: Text('Предстоящие ремонты', style: theme.textTheme.titleLarge),
          ),
        ),

        // Список ремонтов или EmptyState
        if (state.recentRepairs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.build_circle_outlined,
              title: 'Нет предстоящих ремонтов',
              message: 'Запланированные ремонты будут отображаться здесь',
              onPrimaryAction: () => _showRepairForm(context),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ...groupedRepairs.entries.expand((entry) {
                  final date = entry.key;
                  final repairs = entry.value;
                  return [
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
                  ];
                }),
                const SizedBox(height: 20), // Отступ снизу
              ]),
            ),
          ),
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

  void _showRepairForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RepairsBloc>()),
          BlocProvider.value(value: context.read<CarBloc>()),
          BlocProvider.value(value: context.read<ClientBloc>()),
        ],
        child: const RepairFormModal(),
      ),
    );
  }
}

/// Универсальная кнопка действия
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Секция быстрых действий
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Быстрые действия', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.build_circle,
                label: 'Ремонт',
                color: theme.colorScheme.primary,
                onTap: () => _showRepairForm(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.person_add,
                label: 'Клиент',
                color: theme.colorScheme.secondary,
                onTap: () => _showClientForm(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.directions_car,
                label: 'Авто',
                color: theme.colorScheme.tertiary,
                onTap: () => _showCarForm(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRepairForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RepairsBloc>()),
          BlocProvider.value(value: context.read<CarBloc>()),
          BlocProvider.value(value: context.read<ClientBloc>()),
        ],
        child: const RepairFormModal(),
      ),
    );
  }

  void _showClientForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ClientBloc>(),
        child: const ClientFormModal(),
      ),
    );
  }

  void _showCarForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CarBloc>()),
          BlocProvider.value(value: context.read<ClientBloc>()),
        ],
        child: const CarFormModal(),
      ),
    );
  }
}

/// Кнопка быстрого действия с bounce-анимацией
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BounceWrapper(
      onTap: onTap,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
