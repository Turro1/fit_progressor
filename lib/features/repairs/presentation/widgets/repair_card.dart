import 'package:car_repair_manager/features/repairs/domain/entities/repair.dart';
import 'package:car_repair_manager/features/repairs/domain/entities/repair_status.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:car_repair_manager/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:car_repair_manager/features/repairs/presentation/widgets/repair_detail_sheet.dart';
import 'package:car_repair_manager/shared/widgets/entity_card.dart';
import 'package:car_repair_manager/shared/widgets/highlighted_text.dart';
import 'package:car_repair_manager/shared/widgets/delete_confirmation_dialog.dart';
import 'package:car_repair_manager/shared/services/undo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;
  final bool compact;

  /// Поисковый запрос для подсветки
  final String? searchQuery;

  const RepairCard({
    Key? key,
    required this.repair,
    this.compact = false,
    this.searchQuery,
  }) : super(key: key);

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<RepairsBloc>(),
        child: RepairFormModal(repair: repair),
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final repairsBloc = context.read<RepairsBloc>();

    // Показываем диалог подтверждения
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      data: DeleteConfirmationData(
        title: 'Удалить ремонт?',
        itemName: repair.partType,
        itemSubtitle:
            '${repair.carMake} ${repair.carModel} • ${DateFormat('dd.MM.yyyy').format(repair.date)}',
        icon: Icons.build_outlined,
        warnings: [
          'Стоимость: ${repair.cost.toStringAsFixed(0)} ₽',
          if (repair.materials.isNotEmpty)
            'Материалы будут возвращены на склад',
        ],
      ),
    );

    if (confirmed && context.mounted) {
      // Сохраняем копию ремонта для возможности восстановления
      final deletedRepair = repair;

      // Удаляем ремонт
      repairsBloc.add(DeleteRepairEvent(repairId: repair.id));

      // Показываем SnackBar с возможностью отмены
      UndoService.showUndoSnackBar(
        context: context,
        message: '${repair.partType} удалён',
        onUndo: () {
          // Восстанавливаем ремонт
          repairsBloc.add(RestoreRepairEvent(repair: deletedRepair));
        },
      );
    }
  }

  void _showDetailSheet(BuildContext context) {
    RepairDetailSheet.show(context, repair);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactCard(context, theme);
    }

    return EntityCard(
      groupTag: 'repairs',
      enableSwipeActions: true,
      onTap: () => _showDetailSheet(context),
      onEdit: () => _showEditModal(context),
      onDelete: () => _confirmDelete(context),
      leading: _buildLeading(context, theme),
      title: Row(
        children: [
          Expanded(
            child: HighlightedText(
              text: repair.partType,
              query: searchQuery,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(context, theme),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          // Информационные строки
          // Позиция
          if (repair.partPosition.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: HighlightedText(
                      text: repair.partPosition,
                      query: searchQuery,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // Автомобиль
          if (repair.carMake.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: HighlightedText(
                      text: '${repair.carMake} ${repair.carModel}',
                      query: searchQuery,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // Нижняя строка: дата | фото | стоимость
          Row(
            children: [
              // Дата
              Icon(
                Icons.event,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd.MM.yy').format(repair.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('HH:mm').format(repair.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),

              // Фото индикатор
              if (repair.photoPaths.isNotEmpty) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.photo_library_outlined,
                  size: 14,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 3),
                Text(
                  '${repair.photoPaths.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(),

              // Стоимость — крупная и заметная
              Text(
                '${repair.cost.toStringAsFixed(0)} ₽',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    final hasPhotos = repair.photoPaths.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(context, repair.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                repair.partType,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateFormat('dd.MM.yy').format(repair.date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (repair.partPosition.isNotEmpty)
                              Expanded(
                                child: Text(
                                  repair.partPosition,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            // Photo indicator
                            if (hasPhotos) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 12,
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${repair.photoPaths.length}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onTertiaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${repair.cost.toStringAsFixed(0)} ₽',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, RepairStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case RepairStatus.pending:
        return theme.colorScheme.tertiary; // Warning/Pending
      case RepairStatus.inProgress:
        return theme.colorScheme.primary; // Active
      case RepairStatus.completed:
        return const Color(0xFF34C759); // Success Green
      case RepairStatus.cancelled:
        return theme.colorScheme.error; // Error Red
    }
  }

  Widget _buildLeading(BuildContext context, ThemeData theme) {
    final statusColor = _getStatusColor(context, repair.status);
    final statusIcon = _getStatusIcon(repair.status);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(statusIcon, size: 28, color: statusColor)),
    );
  }

  IconData _getStatusIcon(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return Icons.schedule_rounded;
      case RepairStatus.inProgress:
        return Icons.engineering_rounded;
      case RepairStatus.completed:
        return Icons.check_circle_rounded;
      case RepairStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme) {
    Color badgeColor;
    Color textColor;

    switch (repair.status) {
      case RepairStatus.pending:
        badgeColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case RepairStatus.inProgress:
        badgeColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case RepairStatus.completed:
        badgeColor = const Color(
          0xFF34C759,
        ).withValues(alpha: 0.2); // Success container
        textColor = const Color(0xFF1B5E20); // Dark green
        break;
      case RepairStatus.cancelled:
        badgeColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        break;
    }

    return GestureDetector(
      onTap: () => _showStatusChangeDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          repair.status.displayName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить статус'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RepairStatus.values.map((status) {
            final isSelected = status == repair.status;
            return ListTile(
              selected: isSelected,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(status.displayName),
              onTap: () {
                Navigator.pop(dialogContext);
                if (status != repair.status) {
                  context.read<RepairsBloc>().add(
                    UpdateRepairEvent(repair: repair.copyWith(status: status)),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}
