import 'dart:io';
import 'package:car_repair_manager/features/dashboard/domain/entities/repair_with_details.dart';
import 'package:car_repair_manager/features/repairs/domain/entities/repair_status.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:car_repair_manager/features/repairs/presentation/widgets/repair_detail_sheet.dart';
import 'package:car_repair_manager/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:car_repair_manager/shared/widgets/entity_card.dart';
import 'package:car_repair_manager/shared/widgets/delete_confirmation_dialog.dart';
import 'package:car_repair_manager/shared/services/undo_service.dart';
import 'package:car_repair_manager/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DashboardRepairCard extends StatelessWidget {
  final RepairWithDetails repairWithDetails;

  const DashboardRepairCard({Key? key, required this.repairWithDetails})
    : super(key: key);

  /// Открыть детальный просмотр ремонта с информацией о клиенте
  void _openRepairDetailSheet(BuildContext context) {
    RepairDetailSheet.show(
      context,
      repairWithDetails.repair,
      clientName: repairWithDetails.clientName,
      clientPhone: repairWithDetails.clientPhone,
    );
  }

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<RepairsBloc>(),
        child: RepairFormModal(repair: repairWithDetails.repair),
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final repair = repairWithDetails.repair;
    final repairsBloc = context.read<RepairsBloc>();

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
      // Сохраняем копию для Undo
      final deletedRepair = repair;

      repairsBloc.add(DeleteRepairEvent(repairId: repair.id));

      // Показываем SnackBar с возможностью отмены
      UndoService.showUndoSnackBar(
        context: context,
        message: '${repair.partType} удалён',
        onUndo: () {
          repairsBloc.add(RestoreRepairEvent(repair: deletedRepair));
        },
      );
    }
  }

  void _showStatusChangeDialog(BuildContext context) {
    final repair = repairWithDetails.repair;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repair = repairWithDetails.repair;

    return EntityCard(
      groupTag: 'dashboard_repairs',
      enableSwipeActions: true,
      onEdit: () => _showEditModal(context),
      onDelete: () => _confirmDelete(context),
      onTap: () => _openRepairDetailSheet(context),
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
          _buildStatusBadge(context, repair.status),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

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
                    child: Text(
                      repair.partPosition,
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
                  child: Text(
                    repairWithDetails.carFullName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Клиент
          if (repairWithDetails.clientName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      repairWithDetails.clientName,
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

          // Нижняя строка: дата | стоимость
          Row(
            children: [
              Icon(
                Icons.event,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatRelativeWithFuture(repair.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),

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

  Widget _buildStatusBadge(BuildContext context, RepairStatus status) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case RepairStatus.pending:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        label = 'Ожидает';
        icon = Icons.schedule;
        break;
      case RepairStatus.inProgress:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        label = 'В работе';
        icon = Icons.engineering;
        break;
      case RepairStatus.completed:
        backgroundColor = const Color(0xFF34C759).withValues(alpha: 0.2);
        textColor = const Color(0xFF1B5E20);
        label = 'Готово';
        icon = Icons.check_circle;
        break;
      case RepairStatus.cancelled:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        label = 'Отменён';
        icon = Icons.cancel;
        break;
    }

    return GestureDetector(
      onTap: () => _showStatusChangeDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, ThemeData theme) {
    final repair = repairWithDetails.repair;

    if (repair.photoPaths.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: FileImage(File(repair.photoPaths.first)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return _buildDefaultIcon(theme);
  }

  Widget _buildDefaultIcon(ThemeData theme) {
    final statusColor = _getStatusColor(repairWithDetails.repair.status);
    final statusIcon = _getStatusIcon(repairWithDetails.repair.status);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(statusIcon, color: statusColor, size: 28)),
    );
  }

  Color _getStatusColor(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return const Color(0xFFFF9800);
      case RepairStatus.inProgress:
        return const Color(0xFF2196F3);
      case RepairStatus.completed:
        return const Color(0xFF34C759);
      case RepairStatus.cancelled:
        return const Color(0xFFE53935);
    }
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
}
