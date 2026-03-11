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
import 'package:car_repair_manager/core/utils/car_logo_helper.dart';
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Position and car
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Position
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
                            repairWithDetails.carFullName,
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

              // Right side: Date-time and cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Date in relative format (Сегодня, Завтра, etc.)
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
                          DateFormatter.formatRelativeWithFuture(repair.date),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Cost
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

    // Priority: car logo, then photo, then icon
    if (repair.carMake.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CarLogoHelper.getLogoWidget(context, repair.carMake, size: 40),
        ),
      );
    }

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
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.build_circle_rounded,
          color: theme.colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }
}
