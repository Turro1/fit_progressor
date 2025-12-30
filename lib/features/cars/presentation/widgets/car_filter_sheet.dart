import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:fit_progressor/features/cars/domain/entities/car_filter.dart';
import 'package:flutter/material.dart';

/// Bottom sheet для выбора фильтров автомобилей
class CarFilterSheet extends StatefulWidget {
  final CarFilter initialFilter;
  final List<String> availableMakes;
  final Function(CarFilter) onApply;

  const CarFilterSheet({
    Key? key,
    required this.initialFilter,
    required this.availableMakes,
    required this.onApply,
  }) : super(key: key);

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late List<String> _selectedMakes;

  @override
  void initState() {
    super.initState();
    _selectedMakes = List.from(widget.initialFilter.makes);
  }

  void _toggleMake(String make) {
    setState(() {
      if (_selectedMakes.contains(make)) {
        _selectedMakes.remove(make);
      } else {
        _selectedMakes.add(make);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMakes.clear();
    });
  }

  void _apply() {
    final filter = CarFilter(makes: _selectedMakes);
    widget.onApply(filter);
    Navigator.of(context).pop();
  }

  bool get _hasActiveFilters => _selectedMakes.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фильтры',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: _clearAll,
                    child: Text(
                      'Сбросить',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Марка автомобиля
                  _buildSectionTitle('Марка', theme),
                  const SizedBox(height: 12),
                  if (widget.availableMakes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Нет доступных марок',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableMakes.map((make) {
                        final isSelected = _selectedMakes.contains(make);
                        return _CarMakeChip(
                          make: make,
                          isSelected: isSelected,
                          onSelected: () => _toggleMake(make),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check),
                label: Text(
                  _hasActiveFilters
                      ? 'Показать (${_selectedMakes.length})'
                      : 'Показать все',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CarMakeChip extends StatelessWidget {
  final String make;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CarMakeChip({
    required this.make,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.15)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Car logo
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    CarLogoHelper.getLogoPath(make),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.directions_car,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                make,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
