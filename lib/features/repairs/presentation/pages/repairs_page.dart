import 'package:fit_progressor/features/repairs/domain/entities/repair_filter.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_card.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_filter_sheet.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({Key? key}) : super(key: key);

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RepairsBloc>().add(const LoadRepairs());
  }

  void _showRepairModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<RepairsBloc>(),
        child: const RepairFormModal(),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, RepairFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepairFilterSheet(
        initialFilter: currentFilter,
        onApply: (filter) {
          context.read<RepairsBloc>().add(FilterRepairsEvent(filter: filter));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRepairModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with icon and title
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.build_circle,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Ремонты', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar with filter
            BlocBuilder<RepairsBloc, RepairsState>(
              buildWhen: (previous, current) {
                // Перестраиваем только при изменении фильтра
                final prevFilter = previous is RepairsLoaded
                    ? previous.filter
                    : const RepairFilter();
                final currFilter = current is RepairsLoaded
                    ? current.filter
                    : (current is RepairsLoading
                        ? current.currentFilter
                        : const RepairFilter());
                return prevFilter != currFilter;
              },
              builder: (context, state) {
                final currentFilter = state is RepairsLoaded
                    ? state.filter
                    : (state is RepairsLoading
                        ? state.currentFilter ?? const RepairFilter()
                        : const RepairFilter());

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      AppSearchBar(
                        hintText: 'Поиск по ремонтам...',
                        showFilterButton: true,
                        onFilterTap: () => _showFilterSheet(context, currentFilter),
                        onSearch: (query) {
                          context.read<RepairsBloc>().add(
                            SearchRepairsEvent(query: query),
                          );
                        },
                      ),
                      // Active filters indicator
                      if (currentFilter.isActive) ...[
                        const SizedBox(height: 8),
                        _ActiveFiltersBar(
                          filter: currentFilter,
                          onClear: () {
                            context.read<RepairsBloc>().add(
                              const ClearFiltersEvent(),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            // Content
            Expanded(
              child: BlocConsumer<RepairsBloc, RepairsState>(
                listener: (context, state) {
                  if (state is RepairsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is RepairsOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                    // Bloc уже вызывает LoadRepairs в _onDeleteRepair/_onAddRepair/_onUpdateRepair
                    // Не нужно дублировать вызов здесь
                  }
                },
                builder: (context, state) {
                  if (state is RepairsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RepairsLoaded) {
                    if (state.repairs.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<RepairsBloc>().add(const LoadRepairs());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyState(
                                icon: Icons.build_circle,
                                title: 'Нет ремонтов',
                                message:
                                    'Добавьте первый ремонт, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<RepairsBloc>().add(const LoadRepairs());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        itemCount: state.repairs.length,
                        itemBuilder: (context, index) {
                          return RepairCard(repair: state.repairs[index]);
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет для отображения активных фильтров
class _ActiveFiltersBar extends StatelessWidget {
  final RepairFilter filter;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    // Статусы
    if (filter.statuses.isNotEmpty) {
      final statusText = filter.statuses.length == 1
          ? filter.statuses.first.displayName
          : '${filter.statuses.length} статуса';
      chips.add(_FilterChip(label: statusText, icon: Icons.flag_outlined));
    }

    // Типы деталей
    if (filter.partTypes.isNotEmpty) {
      final partText = filter.partTypes.length == 1
          ? filter.partTypes.first
          : '${filter.partTypes.length} типа';
      chips.add(_FilterChip(label: partText, icon: Icons.build_outlined));
    }

    // Период
    if (filter.dateFrom != null || filter.dateTo != null) {
      chips.add(_FilterChip(label: 'Период', icon: Icons.calendar_today));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: chips,
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
