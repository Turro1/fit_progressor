import 'package:fit_progressor/shared/widgets/animated_fab.dart';
import 'package:fit_progressor/shared/widgets/animated_list_item.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:fit_progressor/shared/widgets/delete_confirmation_dialog.dart';
import 'package:fit_progressor/shared/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_filter.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../widgets/car_card.dart';
import '../widgets/car_filter_sheet.dart';
import '../widgets/car_form_modal.dart';
import '../widgets/car_repairs_modal.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({Key? key}) : super(key: key);

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  @override
  void initState() {
    super.initState();
    // Load cars on init
    context.read<CarBloc>().add(const LoadCars());
  }

  void _showFilterSheet(BuildContext context, CarFilter currentFilter, List<String> availableMakes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CarFilterSheet(
        initialFilter: currentFilter,
        availableMakes: availableMakes,
        onApply: (filter) {
          context.read<CarBloc>().add(FilterCarsEvent(filter: filter));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: AnimatedAppearFAB(
        onPressed: () => _showCarModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        tooltip: 'Добавить автомобиль',
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
                    Icons.directions_car,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Автомобили', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar with filter
            BlocBuilder<CarBloc, CarState>(
              buildWhen: (previous, current) {
                // Перестраиваем при изменении фильтра или поискового запроса
                final prevFilter = previous is CarLoaded
                    ? previous.filter
                    : const CarFilter();
                final currFilter = current is CarLoaded
                    ? current.filter
                    : (current is CarLoading
                        ? current.currentFilter
                        : const CarFilter());
                final prevQuery = previous is CarLoaded ? previous.searchQuery : '';
                final currQuery = current is CarLoaded ? current.searchQuery : '';
                return prevFilter != currFilter || prevQuery != currQuery;
              },
              builder: (context, state) {
                final currentFilter = state is CarLoaded
                    ? state.filter
                    : (state is CarLoading
                        ? state.currentFilter ?? const CarFilter()
                        : const CarFilter());
                final availableMakes = state is CarLoaded
                    ? state.availableMakes ?? []
                    : <String>[];
                final searchQuery = state is CarLoaded ? state.searchQuery ?? '' : '';
                final hasActiveSearch = searchQuery.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      AppSearchBar(
                        hintText: 'Поиск по марке, модели, номеру или владельцу...',
                        showFilterButton: true,
                        initialValue: searchQuery,
                        onFilterTap: () => _showFilterSheet(context, currentFilter, availableMakes),
                        onSearch: (query) {
                          context.read<CarBloc>().add(SearchCarsEvent(query: query));
                        },
                      ),
                      // Active filters indicator
                      if (currentFilter.isActive || hasActiveSearch) ...[
                        const SizedBox(height: 8),
                        _ActiveFiltersBar(
                          filter: currentFilter,
                          searchQuery: searchQuery,
                          onClear: () {
                            context.read<CarBloc>().add(
                              const ClearCarFiltersEvent(),
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
              child: BlocConsumer<CarBloc, CarState>(
                listenWhen: (previous, current) =>
                    current is CarError || current is CarOperationSuccess,
                listener: (context, state) {
                  if (state is CarError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is CarOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                    context.read<CarBloc>().add(LoadCars());
                  }
                },
                buildWhen: (previous, current) =>
                    current is CarLoading || current is CarLoaded,
                builder: (context, state) {
                  if (state is CarLoading) {
                    return const EntityListSkeleton();
                  }

                  if (state is CarLoaded) {
                    if (state.cars.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CarBloc>().add(const LoadCars());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyState(
                                icon: Icons.directions_car_outlined,
                                title: state.filter.isActive
                                    ? 'Ничего не найдено'
                                    : 'Нет автомобилей',
                                message: state.filter.isActive
                                    ? 'Попробуйте изменить параметры фильтра'
                                    : 'Добавьте первый автомобиль, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CarBloc>().add(const LoadCars());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.cars.length,
                        itemBuilder: (context, index) {
                          final car = state.cars[index];
                          return AnimatedListItem(
                            key: ValueKey(car.id),
                            index: index,
                            child: CarCard(
                              car: car,
                              onTap: () => _showCarRepairsModal(context, car),
                              onEdit: () => _showCarModal(context, car),
                              onDelete: () => _confirmDelete(context, car),
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

  void _showCarModal(BuildContext context, [Car? car]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarFormModal(car: car),
    );
  }

  void _showCarRepairsModal(BuildContext context, Car car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarRepairsModal(car: car),
    );
  }

  void _confirmDelete(BuildContext context, Car car) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      data: DeleteConfirmationData(
        title: 'Удалить автомобиль?',
        itemName: '${car.make} ${car.model}',
        itemSubtitle: car.plate,
        icon: Icons.directions_car_outlined,
        warnings: [
          'Все ремонты этого автомобиля будут удалены',
          'Это действие нельзя отменить',
        ],
      ),
    );

    if (confirmed && context.mounted) {
      context.read<CarBloc>().add(DeleteCarEvent(carId: car.id));
    }
  }
}

/// Виджет для отображения активных фильтров
class _ActiveFiltersBar extends StatelessWidget {
  final CarFilter filter;
  final String searchQuery;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filter,
    this.searchQuery = '',
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearch = searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            hasSearch ? Icons.search : Icons.filter_list,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Поисковый запрос
                if (hasSearch)
                  _FilterChip(
                    label: '"$searchQuery"',
                    icon: Icons.search,
                  ),
                // Марки
                ...filter.makes.map((make) => _FilterChip(
                  label: make,
                  icon: Icons.directions_car_outlined,
                )),
              ],
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
