import 'package:fit_progressor/features/materials/domain/entities/material_filter.dart';
import 'package:fit_progressor/shared/widgets/animated_fab.dart';
import 'package:fit_progressor/shared/widgets/animated_list_item.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:fit_progressor/shared/services/undo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/material.dart' as entity;
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material_state;
import '../widgets/material_card.dart';
import '../widgets/material_form_modal.dart';
import '../widgets/material_filter_sheet.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({Key? key}) : super(key: key);

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(const LoadMaterials());
  }

  void _showFilterSheet(BuildContext context, MaterialFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MaterialFilterSheet(
        initialFilter: currentFilter,
        onApply: (filter) {
          context.read<MaterialBloc>().add(FilterMaterialsEvent(filter: filter));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: AnimatedAppearFAB(
        onPressed: () => _showMaterialModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        tooltip: 'Добавить материал',
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
                    Icons.inventory_2,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Материалы', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar with filter
            BlocBuilder<MaterialBloc, material_state.MaterialState>(
              buildWhen: (previous, current) {
                final prevFilter = previous is material_state.MaterialLoaded
                    ? previous.filter
                    : const MaterialFilter();
                final currFilter = current is material_state.MaterialLoaded
                    ? current.filter
                    : (current is material_state.MaterialLoading
                        ? current.currentFilter
                        : const MaterialFilter());
                return prevFilter != currFilter;
              },
              builder: (context, state) {
                final currentFilter = state is material_state.MaterialLoaded
                    ? state.filter
                    : (state is material_state.MaterialLoading
                        ? state.currentFilter ?? const MaterialFilter()
                        : const MaterialFilter());

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      AppSearchBar(
                        hintText: 'Поиск по названию материала...',
                        showFilterButton: true,
                        onFilterTap: () => _showFilterSheet(context, currentFilter),
                        onSearch: (query) {
                          context.read<MaterialBloc>().add(
                            SearchMaterialsEvent(query: query),
                          );
                        },
                      ),
                      // Active filters indicator
                      if (currentFilter.isActive) ...[
                        const SizedBox(height: 8),
                        _ActiveFiltersBar(
                          filter: currentFilter,
                          onClear: () {
                            context.read<MaterialBloc>().add(
                              const ClearMaterialFiltersEvent(),
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
              child: BlocConsumer<MaterialBloc, material_state.MaterialState>(
                listener: (context, state) {
                  if (state is material_state.MaterialError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is material_state.MaterialOperationSuccess) {
                    // Не показываем SnackBar для удаления - его покажет UndoService
                    if (!state.message.contains('удален')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                      );
                    }
                    context.read<MaterialBloc>().add(const LoadMaterials());
                  }
                },
                builder: (context, state) {
                  if (state is material_state.MaterialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is material_state.MaterialLoaded) {
                    if (state.materials.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<MaterialBloc>().add(const LoadMaterials());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: state.filter.isActive
                                    ? 'Ничего не найдено'
                                    : 'Нет материалов',
                                message: state.filter.isActive
                                    ? 'Попробуйте изменить параметры фильтра'
                                    : 'Добавьте первый материал, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<MaterialBloc>().add(const LoadMaterials());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.materials.length,
                        itemBuilder: (context, index) {
                          final material = state.materials[index];
                          return AnimatedListItem(
                            key: ValueKey(material.id),
                            index: index,
                            child: MaterialCard(
                              material: material,
                              onEdit: () => _showMaterialModal(context, material),
                              onDelete: () => _confirmDelete(context, material),
                            ),
                          );
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

  void _showMaterialModal(BuildContext context, [entity.Material? material]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialFormModal(material: material),
    );
  }

  void _confirmDelete(BuildContext context, entity.Material material) async {
    final materialBloc = context.read<MaterialBloc>();
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить материал?'),
        content: Text(
          'Вы уверены, что хотите удалить "${material.name}"?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Сохраняем копию для восстановления
      final deletedMaterial = material;

      // Удаляем материал
      materialBloc.add(DeleteMaterialEvent(materialId: material.id));

      // Показываем Undo SnackBar
      UndoService.showUndoSnackBar(
        context: context,
        message: '${material.name} удалён',
        onUndo: () {
          materialBloc.add(RestoreMaterialEvent(material: deletedMaterial));
        },
      );
    }
  }
}

/// Виджет для отображения активных фильтров
class _ActiveFiltersBar extends StatelessWidget {
  final MaterialFilter filter;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    // Статус наличия
    if (filter.stockStatuses.isNotEmpty) {
      final statusText = filter.stockStatuses.length == 1
          ? filter.stockStatuses.first.displayName
          : '${filter.stockStatuses.length} статуса';
      chips.add(_FilterChip(label: statusText, icon: Icons.inventory_2_outlined));
    }

    // Единицы измерения
    if (filter.units.isNotEmpty) {
      final unitText = filter.units.length == 1
          ? filter.units.first.displayName
          : '${filter.units.length} ед.';
      chips.add(_FilterChip(label: unitText, icon: Icons.straighten_outlined));
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
