import 'dart:io';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
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
      leading: _buildLeading(theme),
      title: Text(
        repair.partType,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              repair.partPosition,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${repair.carMake} ${repair.carModel}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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

  Widget _buildLeading(ThemeData theme) {
    // Приоритет: логотип автомобиля, затем фото, затем иконка
    if (repair.carMake.isNotEmpty) {
      return CircleAvatar(
        radius: 38,
        backgroundColor: Colors.white,
        child: Image.asset(
          CarLogoHelper.getLogoPath(repair.carMake),
          fit: BoxFit.none,
          scale: 24,
          errorBuilder: (context, error, stackTrace) {
            // Если логотип не найден, пытаемся показать фото
            if (repair.photoPaths.isNotEmpty) {
              return ClipOval(
                child: Image.file(
                  File(repair.photoPaths.first),
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.build_circle,
                      size: 56,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              );
            }
            return Icon(
              Icons.directions_car_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            );
          },
        ),
      );
    }

    // Если нет марки, но есть фото
    if (repair.photoPaths.isNotEmpty) {
      return CircleAvatar(
        radius: 42,
        backgroundImage: FileImage(File(repair.photoPaths.first)),
        onBackgroundImageError: (error, stackTrace) {},
      );
    }

    // Иконка по умолчанию
    return CircleAvatar(
      radius: 42,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Icon(
        Icons.build_circle,
        size: 56,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
