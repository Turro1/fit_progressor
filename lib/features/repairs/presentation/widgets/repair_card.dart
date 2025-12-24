import 'dart:io';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/photo_viewer.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;

  const RepairCard({Key? key, required this.repair}) : super(key: key);

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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить ремонт?'),
        content: Text('Вы уверены, что хотите удалить "${repair.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RepairsBloc>().add(
                DeleteRepairEvent(repairId: repair.id),
              );
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EntityCard(
      groupTag: 'repairs',
      enableSwipeActions: true,
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Правая часть: Дата-время и стоимость
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
    );
  }

  Widget _buildLeading(BuildContext context, ThemeData theme) {
    final hasPhotos = repair.photoPaths.isNotEmpty;

    Widget avatar;

    // Приоритет: логотип автомобиля, затем фото, затем иконка
    if (repair.carMake.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Image.asset(
          CarLogoHelper.getLogoPath(repair.carMake),
          fit: BoxFit.contain,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            // Если логотип не найден, пытаемся показать фото
            if (hasPhotos) {
              return ClipOval(
                child: Image.file(
                  File(repair.photoPaths.first),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.build_circle,
                      size: 32,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              );
            }
            return Icon(
              Icons.directions_car_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            );
          },
        ),
      );
    } else if (hasPhotos) {
      // Если нет марки, но есть фото
      avatar = CircleAvatar(
        radius: 28,
        backgroundImage: FileImage(File(repair.photoPaths.first)),
        onBackgroundImageError: (error, stackTrace) {},
      );
    } else {
      // Иконка по умолчанию
      avatar = CircleAvatar(
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

    // Если есть фото, делаем аватар кликабельным
    if (hasPhotos) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PhotoViewer(photoPaths: repair.photoPaths, initialIndex: 0),
            ),
          );
        },
        child: Stack(
          children: [
            avatar,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return avatar;
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
