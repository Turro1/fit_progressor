import 'package:fit_progressor/core/services/export_service.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// Тип данных для экспорта
enum ExportDataType {
  repairs('Ремонты', Icons.build_circle),
  clients('Клиенты', Icons.people),
  cars('Автомобили', Icons.directions_car);

  final String label;
  final IconData icon;

  const ExportDataType(this.label, this.icon);
}

/// Результат выбора экспорта
class ExportSelection {
  final ExportDataType dataType;
  final ExportType format;

  ExportSelection({required this.dataType, required this.format});
}

/// Bottom sheet для выбора параметров экспорта
class ExportSheet extends StatefulWidget {
  final Future<ExportResult> Function(ExportDataType dataType, ExportType format)
      onExport;

  const ExportSheet({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  ExportDataType _selectedDataType = ExportDataType.repairs;
  ExportType _selectedFormat = ExportType.pdf;
  bool _isExporting = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);

    try {
      final result = await widget.onExport(_selectedDataType, _selectedFormat);

      if (!mounted) return;

      if (result.success && result.filePath != null) {
        Navigator.pop(context);
        _showSuccessDialog(context, result.filePath!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Ошибка экспорта'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String filePath) {
    Theme.of(context);
    final exportService = ExportService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Экспорт завершён'),
          ],
        ),
        content: const Text('Файл успешно создан. Что вы хотите сделать?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              exportService.shareFile(filePath);
            },
            icon: const Icon(Icons.share),
            label: const Text('Поделиться'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              OpenFilex.open(filePath);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

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

          // Заголовок
          Row(
            children: [
              Icon(Icons.file_download, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Экспорт данных',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Выбор данных
          Text(
            'Данные для экспорта',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ExportDataType.values.map((type) {
              final isSelected = type == _selectedDataType;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(type.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedDataType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Выбор формата
          Text(
            'Формат файла',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _FormatCard(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  description: 'Для печати и просмотра',
                  isSelected: _selectedFormat == ExportType.pdf,
                  onTap: () => setState(() => _selectedFormat = ExportType.pdf),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormatCard(
                  icon: Icons.table_chart,
                  label: 'CSV',
                  description: 'Для Excel и анализа',
                  isSelected: _selectedFormat == ExportType.csv,
                  onTap: () => setState(() => _selectedFormat = ExportType.csv),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Кнопка экспорта
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isExporting ? null : _export,
              icon: _isExporting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.file_download),
              label: Text(_isExporting ? 'Экспорт...' : 'Экспортировать'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

/// Карточка выбора формата
class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
