import 'package:fit_progressor/core/services/export_service.dart';
import 'package:fit_progressor/core/theme/theme_cubit.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';
import 'package:fit_progressor/features/clients/presentation/widgets/client_form_modal.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/dashboard_repair_card.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:fit_progressor/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/injection_container.dart' as di;
import 'package:fit_progressor/shared/widgets/export_sheet.dart';
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
            Expanded(
              child: Text('Сводка', style: theme.textTheme.headlineMedium),
            ),
            // Export button
            _ActionButton(
              icon: Icons.file_download,
              onPressed: () => _showExportSheet(context),
              tooltip: 'Экспорт',
            ),
            const SizedBox(width: 8),
            // Theme toggle button
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return _ThemeToggleButton(
                  themeMode: themeState.themeMode,
                  onPressed: () => _showThemeSelector(context, themeState.themeMode),
                );
              },
            ),
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
                  label: 'Чистая прибыль',
                  value: '${_formatMoney(state.stats.monthlyNetRevenue)} ₽',
                  icon: Icons.trending_up,
                  valueColor: state.stats.monthlyNetRevenue >= 0
                      ? Colors.green
                      : theme.colorScheme.error,
                  trend: state.stats.netRevenueTrend,
                ),
                StatCard(
                  label: 'Выполнено за месяц',
                  value: state.stats.completedRepairsThisMonth.toString(),
                  icon: Icons.check_circle,
                  valueColor: Colors.green,
                  trend: state.stats.completedRepairsTrend,
                ),
                StatCard(
                  label: 'Средний чек',
                  value: '${_formatMoney(state.stats.averageRepairCost)} ₽',
                  icon: Icons.receipt_long,
                  valueColor: theme.colorScheme.primary,
                  trend: state.stats.averageCostTrend,
                ),
                StatCard(
                  label: 'Низкий остаток',
                  value: state.stats.lowStockMaterials.toString(),
                  icon: Icons.warning_amber,
                  valueColor: state.stats.lowStockMaterials > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  invertTrendColors: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        // Быстрые действия
        _QuickActionsSection(),
        const SizedBox(height: 20),
        // График выручки
        RevenueChart(data: state.stats.revenueChart),
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

  void _showThemeSelector(BuildContext context, AppThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ThemeSelectorSheet(currentMode: currentMode),
    );
  }

  void _showExportSheet(BuildContext context) {
    final exportService = di.sl<ExportService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ExportSheet(
        onExport: (dataType, format) async {
          switch (dataType) {
            case ExportDataType.repairs:
              final repairsState = context.read<RepairsBloc>().state;
              if (repairsState is RepairsLoaded) {
                if (format == ExportType.pdf) {
                  return exportService.exportRepairsToPdf(repairsState.allRepairs);
                } else {
                  return exportService.exportRepairsToCsv(repairsState.allRepairs);
                }
              }
              // Если ремонты не загружены, загружаем через Dashboard
              final dashboardState = context.read<DashboardBloc>().state;
              if (dashboardState is DashboardLoaded) {
                final repairs = dashboardState.recentRepairs
                    .map((r) => r.repair)
                    .toList();
                if (format == ExportType.pdf) {
                  return exportService.exportRepairsToPdf(repairs);
                } else {
                  return exportService.exportRepairsToCsv(repairs);
                }
              }
              return ExportResult.failure('Нет данных для экспорта');

            case ExportDataType.clients:
              final clientsState = context.read<ClientBloc>().state;
              if (clientsState is ClientLoaded) {
                if (format == ExportType.pdf) {
                  return exportService.exportClientsToPdf(clientsState.clients);
                } else {
                  return exportService.exportClientsToCsv(clientsState.clients);
                }
              }
              return ExportResult.failure('Нет данных для экспорта');

            case ExportDataType.cars:
              final carsState = context.read<CarBloc>().state;
              if (carsState is CarLoaded) {
                return exportService.exportCarsToCsv(carsState.cars);
              }
              return ExportResult.failure('Нет данных для экспорта');
          }
        },
      ),
    );
  }
}

/// Кнопка переключения темы
class _ThemeToggleButton extends StatelessWidget {
  final AppThemeMode themeMode;
  final VoidCallback onPressed;

  const _ThemeToggleButton({
    required this.themeMode,
    required this.onPressed,
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            themeMode.icon,
            size: 22,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet для выбора темы
class _ThemeSelectorSheet extends StatelessWidget {
  final AppThemeMode currentMode;

  const _ThemeSelectorSheet({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Тема оформления',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...AppThemeMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return ListTile(
              leading: Icon(
                mode.icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                mode.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              onTap: () {
                context.read<ThemeCubit>().setThemeMode(mode);
                Navigator.pop(context);
              },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
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

/// Кнопка быстрого действия
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

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
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
