import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fit_progressor/core/theme/theme_cubit.dart';
import 'package:fit_progressor/core/sync/bloc/sync_bloc.dart';
import 'package:fit_progressor/core/sync/bloc/sync_state.dart';
import 'package:fit_progressor/core/sync/sync_engine.dart';
import 'package:fit_progressor/core/services/export_service.dart';
import 'package:fit_progressor/core/services/data_seeder_service.dart';
import 'package:fit_progressor/core/services/cache_cleaner_service.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_event.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_bloc.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_event.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fit_progressor/shared/widgets/export_sheet.dart';
import 'package:fit_progressor/injection_container.dart' as di;

/// Страница настроек
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Ключ для перестроения карточки очистки
  int _clearCardKey = 0;

  void _refreshClearCard() {
    setState(() {
      _clearCardKey++;
    });
  }

  /// Перезагружает все BLOCs после очистки данных
  void _reloadAllBlocs() {
    // Перезагружаем все данные
    context.read<RepairsBloc>().add(LoadRepairs());
    context.read<ClientBloc>().add(LoadClients());
    context.read<CarBloc>().add(const LoadCars());
    context.read<MaterialBloc>().add(LoadMaterials());
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Секция "Данные"
          _buildSectionHeader(context, 'Данные'),
          const SizedBox(height: 8),
          _buildExportCard(context),
          const SizedBox(height: 8),
          _buildClearCacheCard(context),
          const SizedBox(height: 24),

          // Секция "Синхронизация"
          _buildSectionHeader(context, 'Синхронизация'),
          const SizedBox(height: 8),
          _buildSyncCard(context),
          const SizedBox(height: 24),

          // Секция "Внешний вид"
          _buildSectionHeader(context, 'Внешний вид'),
          const SizedBox(height: 8),
          _buildThemeCard(context),
          const SizedBox(height: 24),

          // Секция "О приложении"
          _buildSectionHeader(context, 'О приложении'),
          const SizedBox(height: 8),
          _buildAboutCard(context),

          // Секция "Для разработчиков" (только в debug)
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Для разработчиков'),
            const SizedBox(height: 8),
            _buildDebugCard(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildExportCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_download),
        title: const Text('Экспорт данных'),
        subtitle: const Text('PDF и CSV отчёты'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showExportSheet(context),
      ),
    );
  }

  Widget _buildClearCacheCard(BuildContext context) {
    final cleaner = di.sl<CacheCleanerService>();

    return FutureBuilder<CacheStats>(
      key: ValueKey(_clearCardKey), // Ключ для перестроения
      future: cleaner.getStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        String subtitle = 'Очистка локальных данных';

        if (stats != null) {
          if (stats.hasPendingChanges) {
            subtitle = '${stats.pendingChangesCount} изм. не синхронизировано';
          } else if (stats.hasData) {
            subtitle = '${stats.totalDataCount} записей';
          } else {
            subtitle = 'Нет данных';
          }
        }

        return Card(
          child: ListTile(
            leading: Icon(
              Icons.cleaning_services,
              color: stats?.hasPendingChanges == true
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            title: const Text('Очистить данные'),
            subtitle: Text(
              subtitle,
              style: stats?.hasPendingChanges == true
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearCacheDialog(context, stats),
          ),
        );
      },
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
              return ExportResult.failure('Загрузите данные на странице "Ремонты"');

            case ExportDataType.clients:
              final clientsState = context.read<ClientBloc>().state;
              if (clientsState is ClientLoaded) {
                if (format == ExportType.pdf) {
                  return exportService.exportClientsToPdf(clientsState.clients);
                } else {
                  return exportService.exportClientsToCsv(clientsState.clients);
                }
              }
              return ExportResult.failure('Загрузите данные на странице "Клиенты"');

            case ExportDataType.cars:
              final carsState = context.read<CarBloc>().state;
              if (carsState is CarLoaded) {
                return exportService.exportCarsToCsv(carsState.cars);
              }
              return ExportResult.failure('Загрузите данные на странице "Автомобили"');
          }
        },
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        String subtitle;
        IconData statusIcon;
        Color statusColor;

        if (state.mode == SyncMode.server) {
          subtitle = 'Сервер запущен (${state.connectedClients.length} подключений)';
          statusIcon = Icons.cloud_done;
          statusColor = Colors.green;
        } else if (state.mode == SyncMode.client && state.isConnectedToServer) {
          subtitle = 'Подключено к ${state.serverInfo?.serverName ?? "серверу"}';
          statusIcon = Icons.cloud_done;
          statusColor = Colors.green;
        } else {
          subtitle = 'Не настроено';
          statusIcon = Icons.cloud_off;
          statusColor = Colors.grey;
        }

        return Card(
          child: ListTile(
            leading: Icon(statusIcon, color: statusColor),
            title: const Text('Синхронизация'),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/sync'),
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(state.themeMode.icon),
                title: const Text('Тема оформления'),
                subtitle: Text(state.themeMode.displayName),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildThemeOption(
                      context,
                      'Светлая',
                      Icons.light_mode,
                      state.themeMode == AppThemeMode.light,
                      () => context.read<ThemeCubit>().setThemeMode(AppThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context,
                      'Тёмная',
                      Icons.dark_mode,
                      state.themeMode == AppThemeMode.dark,
                      () => context.read<ThemeCubit>().setThemeMode(AppThemeMode.dark),
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context,
                      'Системная',
                      Icons.settings_brightness,
                      state.themeMode == AppThemeMode.system,
                      () => context.read<ThemeCubit>().setThemeMode(AppThemeMode.system),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('FitProgressor'),
            subtitle: Text('Версия 1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Лицензии'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'FitProgressor',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebugCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.bug_report,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Заполнить тестовыми данными'),
            subtitle: const Text('Клиенты, авто, ремонты, материалы'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSeederDialog(context),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, CacheStats? stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ClearCacheSheet(
        stats: stats,
        onCleared: () {
          _refreshClearCard();
          _reloadAllBlocs();
        },
      ),
    );
  }

  void _showSeederDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заполнить тестовыми данными?'),
        content: const Text(
          'Будут созданы тестовые клиенты, автомобили, ремонты и материалы.\n\n'
          'Это действие добавит данные к существующим.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _runSeeder(context);
            },
            child: const Text('Заполнить'),
          ),
        ],
      ),
    );
  }

  void _runSeeder(BuildContext context) async {
    final seeder = di.sl<DataSeederService>();

    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text('Создание данных...'),
            ],
          ),
        ),
      ),
    );

    SeederResult result;
    try {
      result = await seeder.seedAll();
    } catch (e) {
      result = SeederResult(
        success: false,
        message: 'Ошибка: $e',
      );
    }

    // Закрываем индикатор - используем Navigator.of с rootNavigator
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Обновляем все данные
    if (context.mounted) {
      _reloadAllBlocs();
      _refreshClearCard();
    }

    // Показываем результат
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

/// Диалог выбора типа очистки
class _ClearCacheSheet extends StatefulWidget {
  final CacheStats? stats;
  final VoidCallback onCleared;

  const _ClearCacheSheet({
    this.stats,
    required this.onCleared,
  });

  @override
  State<_ClearCacheSheet> createState() => _ClearCacheSheetState();
}

class _ClearCacheSheetState extends State<_ClearCacheSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.stats;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cleaning_services, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Очистка данных',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Статистика
            if (stats != null) ...[
              _buildStatsCard(context, stats),
              const SizedBox(height: 16),
            ],

            // Предупреждение о несинхронизированных данных
            if (stats?.hasPendingChanges == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${stats!.pendingChangesCount} изменений ещё не синхронизировано. '
                        'Они будут потеряны при полной очистке.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Информация о синхронизации
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Данные удаляются только на этом устройстве. '
                      'При следующей синхронизации они будут восстановлены с сервера.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Опции очистки
            _buildClearOption(
              context,
              icon: Icons.auto_delete_outlined,
              title: 'Очистить старую историю синхронизации',
              subtitle: 'Удалить записи старше 7 дней (безопасно)',
              onTap: _isLoading ? null : () => _clearSyncedChanges(context),
            ),
            const SizedBox(height: 8),
            _buildClearOption(
              context,
              icon: Icons.sync_disabled,
              title: 'Сбросить метаданные синхронизации',
              subtitle: 'Очистить историю подключений и изменений',
              onTap: _isLoading ? null : () => _clearSyncMetadata(context),
            ),
            const SizedBox(height: 8),
            _buildClearOption(
              context,
              icon: Icons.delete_outline,
              title: 'Удалить все данные на этом устройстве',
              subtitle: 'Ремонты, клиенты, авто, материалы',
              isDestructive: true,
              onTap: _isLoading ? null : () => _clearAllData(context),
            ),
            const SizedBox(height: 8),
            _buildClearOption(
              context,
              icon: Icons.restart_alt,
              title: 'Полный сброс',
              subtitle: 'Удалить всё и начать с чистого листа',
              isDestructive: true,
              onTap: _isLoading ? null : () => _clearEverything(context),
            ),

            const SizedBox(height: 16),

            // Кнопка отмены
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, CacheStats stats) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Текущие данные',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatChip(context, 'Ремонты', stats.repairsCount),
              _buildStatChip(context, 'Клиенты', stats.clientsCount),
              _buildStatChip(context, 'Авто', stats.carsCount),
              _buildStatChip(context, 'Материалы', stats.materialsCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClearOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return Material(
      color: isDestructive
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(color: color),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearSyncedChanges(BuildContext context) async {
    await _performClear(
      context,
      () => di.sl<CacheCleanerService>().clearSyncedChanges(),
    );
  }

  Future<void> _clearSyncMetadata(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Сбросить метаданные?',
      message: 'История синхронизации будет удалена. '
          'При следующей синхронизации все данные будут переданы заново.',
    );

    if (confirmed == true && context.mounted) {
      await _performClear(
        context,
        () => di.sl<CacheCleanerService>().clearSyncMetadata(),
      );
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Удалить все данные?',
      message: 'Все ремонты, клиенты, автомобили и материалы будут удалены на этом устройстве. '
          'При синхронизации данные могут быть восстановлены с сервера.',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await _performClear(
        context,
        () => di.sl<CacheCleanerService>().clearAllData(),
      );
    }
  }

  Future<void> _clearEverything(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Полный сброс?',
      message: 'ВСЕ данные и настройки синхронизации будут удалены на этом устройстве. '
          'Приложение вернётся к начальному состоянию. '
          'Это действие нельзя отменить!',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await _performClear(
        context,
        () => di.sl<CacheCleanerService>().clearEverything(),
      );
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(isDestructive ? 'Удалить' : 'Подтвердить'),
          ),
        ],
      ),
    );
  }

  Future<void> _performClear(
    BuildContext context,
    Future<ClearResult> Function() clearAction,
  ) async {
    setState(() => _isLoading = true);

    try {
      final result = await clearAction();

      if (context.mounted) {
        // Закрываем sheet
        Navigator.pop(context);

        // Уведомляем родителя об очистке
        widget.onCleared();

        // Показываем результат
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
