import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_detail_sheet.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import 'package:fit_progressor/shared/widgets/delete_confirmation_dialog.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;
  final bool compact;

  const RepairCard({
    Key? key,
    required this.repair,
    this.compact = false,
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

    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      data: DeleteConfirmationData(
        title: 'Удалить ремонт?',
        itemName: repair.partType,
        itemSubtitle: '${repair.carMake} ${repair.carModel} • ${DateFormat('dd.MM.yyyy').format(repair.date)}',
        icon: Icons.build_outlined,
        warnings: [
          'Стоимость: ${repair.cost.toStringAsFixed(0)} ₽',
          'Это действие нельзя отменить',
        ],
      ),
    );

    if (confirmed) {
      repairsBloc.add(DeleteRepairEvent(repairId: repair.id));
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
            child: Text(
              repair.partType,
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
          const SizedBox(height: 8),

          // Компактный layout: Позиция и автомобиль | Дата-время и стоимость
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Левая часть: Позиция и автомобиль
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Позиция
                    if (repair.partPosition.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              repair.partPosition,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Автомобиль (если есть)
                    if (repair.carMake.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${repair.carMake} ${repair.carModel}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Правая часть: Дата-время, фото и стоимость
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Дата и время вместе
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('dd.MM.yyyy').format(repair.date)} - ${DateFormat('HH:mm').format(repair.date)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Фото индикатор и стоимость
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Индикатор фото
                      if (repair.photoPaths.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 14,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${repair.photoPaths.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Стоимость
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${repair.cost.toStringAsFixed(0)} ₽',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
      elevation: 0,
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
                      color: _getStatusColor(repair.status),
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
                                      color: theme.colorScheme.onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${repair.photoPaths.length}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onTertiaryContainer,
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

  Widget _buildLeading(BuildContext context, ThemeData theme) {
    // Показываем только логотип авто или иконку (фото теперь в галерее миниатюр)
    if (repair.carMake.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Image.asset(
          CarLogoHelper.getLogoPath(repair.carMake),
          fit: BoxFit.contain,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.directions_car_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            );
          },
        ),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      child: Icon(
        Icons.build_circle,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme) {
    Color badgeColor;
    Color textColor;

    switch (repair.status) {
      case RepairStatus.pending:
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case RepairStatus.inProgress:
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case RepairStatus.completed:
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case RepairStatus.cancelled:
        badgeColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
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
