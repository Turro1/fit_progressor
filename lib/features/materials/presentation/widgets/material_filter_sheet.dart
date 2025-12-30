import 'package:fit_progressor/features/materials/domain/entities/material.dart';
import 'package:fit_progressor/features/materials/domain/entities/material_filter.dart';
import 'package:flutter/material.dart';

/// Bottom sheet для выбора фильтров материалов
class MaterialFilterSheet extends StatefulWidget {
  final MaterialFilter initialFilter;
  final Function(MaterialFilter) onApply;

  const MaterialFilterSheet({
    Key? key,
    required this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<MaterialFilterSheet> createState() => _MaterialFilterSheetState();
}

class _MaterialFilterSheetState extends State<MaterialFilterSheet> {
  late List<MaterialUnit> _selectedUnits;
  late List<StockStatus> _selectedStockStatuses;

  @override
  void initState() {
    super.initState();
    _selectedUnits = List.from(widget.initialFilter.units);
    _selectedStockStatuses = List.from(widget.initialFilter.stockStatuses);
  }

  void _toggleUnit(MaterialUnit unit) {
    setState(() {
      if (_selectedUnits.contains(unit)) {
        _selectedUnits.remove(unit);
      } else {
        _selectedUnits.add(unit);
      }
    });
  }

  void _toggleStockStatus(StockStatus status) {
    setState(() {
      if (_selectedStockStatuses.contains(status)) {
        _selectedStockStatuses.remove(status);
      } else {
        _selectedStockStatuses.add(status);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedUnits.clear();
      _selectedStockStatuses.clear();
    });
  }

  void _apply() {
    final filter = MaterialFilter(
      units: _selectedUnits,
      stockStatuses: _selectedStockStatuses,
    );
    widget.onApply(filter);
    Navigator.of(context).pop();
  }

  bool get _hasActiveFilters =>
      _selectedUnits.isNotEmpty || _selectedStockStatuses.isNotEmpty;

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
                  // Статус наличия
                  _buildSectionTitle('Наличие', theme),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StockStatus.values.map((status) {
                      final isSelected = _selectedStockStatuses.contains(status);
                      return FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (_) => _toggleStockStatus(status),
                        selectedColor: _getStockStatusColor(status).withValues(alpha: 0.2),
                        checkmarkColor: _getStockStatusColor(status),
                        avatar: Icon(
                          _getStockStatusIcon(status),
                          size: 18,
                          color: isSelected
                              ? _getStockStatusColor(status)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? _getStockStatusColor(status)
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Единица измерения
                  _buildSectionTitle('Единица измерения', theme),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MaterialUnit.values.map((unit) {
                      final isSelected = _selectedUnits.contains(unit);
                      return FilterChip(
                        label: Text(_getUnitFullName(unit)),
                        selected: isSelected,
                        onSelected: (_) => _toggleUnit(unit),
                        selectedColor:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
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
                  _hasActiveFilters ? 'Применить фильтры' : 'Показать все',
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

  Color _getStockStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  IconData _getStockStatusIcon(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return Icons.check_circle_outline;
      case StockStatus.lowStock:
        return Icons.warning_amber_outlined;
      case StockStatus.outOfStock:
        return Icons.remove_circle_outline;
    }
  }

  String _getUnitFullName(MaterialUnit unit) {
    switch (unit) {
      case MaterialUnit.pcs:
        return 'Штуки';
      case MaterialUnit.l:
        return 'Литры';
      case MaterialUnit.kg:
        return 'Килограммы';
      case MaterialUnit.m:
        return 'Метры';
      case MaterialUnit.kit:
        return 'Комплекты';
    }
  }
}
