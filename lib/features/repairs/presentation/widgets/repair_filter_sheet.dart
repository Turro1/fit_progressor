import 'package:fit_progressor/features/repairs/domain/entities/part_types.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_filter.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet для выбора фильтров ремонтов
class RepairFilterSheet extends StatefulWidget {
  final RepairFilter initialFilter;
  final Function(RepairFilter) onApply;

  const RepairFilterSheet({
    Key? key,
    required this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<RepairFilterSheet> createState() => _RepairFilterSheetState();
}

class _RepairFilterSheetState extends State<RepairFilterSheet> {
  late List<RepairStatus> _selectedStatuses;
  late List<String> _selectedPartTypes;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _selectedStatuses = List.from(widget.initialFilter.statuses);
    _selectedPartTypes = List.from(widget.initialFilter.partTypes);
    _dateFrom = widget.initialFilter.dateFrom;
    _dateTo = widget.initialFilter.dateTo;
  }

  void _toggleStatus(RepairStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  void _togglePartType(String partType) {
    setState(() {
      if (_selectedPartTypes.contains(partType)) {
        _selectedPartTypes.remove(partType);
      } else {
        _selectedPartTypes.add(partType);
      }
    });
  }

  Future<void> _selectDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );
    if (date != null) {
      setState(() {
        _dateFrom = date;
        // Если дата "до" раньше даты "от", сбрасываем её
        if (_dateTo != null && _dateTo!.isBefore(date)) {
          _dateTo = null;
        }
      });
    }
  }

  Future<void> _selectDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? _dateFrom ?? DateTime.now(),
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );
    if (date != null) {
      setState(() {
        _dateTo = date;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _selectedStatuses.clear();
      _selectedPartTypes.clear();
      _dateFrom = null;
      _dateTo = null;
    });
  }

  void _apply() {
    final filter = RepairFilter(
      statuses: _selectedStatuses,
      partTypes: _selectedPartTypes,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
    widget.onApply(filter);
    Navigator.of(context).pop();
  }

  bool get _hasActiveFilters =>
      _selectedStatuses.isNotEmpty ||
      _selectedPartTypes.isNotEmpty ||
      _dateFrom != null ||
      _dateTo != null;

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
                  // Статус
                  _buildSectionTitle('Статус', theme),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: RepairStatus.values.map((status) {
                      final isSelected = _selectedStatuses.contains(status);
                      return FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (_) => _toggleStatus(status),
                        selectedColor: _getStatusColor(status).withValues(alpha: 0.2),
                        checkmarkColor: _getStatusColor(status),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? _getStatusColor(status)
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Тип детали
                  _buildSectionTitle('Тип детали', theme),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PartTypes.all.map((partType) {
                      final isSelected = _selectedPartTypes.contains(partType);
                      return FilterChip(
                        label: Text(partType),
                        selected: isSelected,
                        onSelected: (_) => _togglePartType(partType),
                        selectedColor:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Период
                  _buildSectionTitle('Период', theme),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'От',
                          date: _dateFrom,
                          dateFormat: _dateFormat,
                          onTap: _selectDateFrom,
                          onClear: () => setState(() => _dateFrom = null),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateButton(
                          label: 'До',
                          date: _dateTo,
                          dateFormat: _dateFormat,
                          onTap: _selectDateTo,
                          onClear: () => setState(() => _dateTo = null),
                          theme: theme,
                        ),
                      ),
                    ],
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

  Color _getStatusColor(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return Colors.orange;
      case RepairStatus.inProgress:
        return Colors.blue;
      case RepairStatus.completed:
        return Colors.green;
      case RepairStatus.cancelled:
        return Colors.grey;
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final ThemeData theme;

  const _DateButton({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
    required this.onClear,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
          color: date != null
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: date != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    date != null ? dateFormat.format(date!) : 'Выбрать',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: date != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
