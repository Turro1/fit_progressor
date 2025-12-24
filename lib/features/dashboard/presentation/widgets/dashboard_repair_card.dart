import 'dart:io';
import 'package:fit_progressor/features/dashboard/domain/entities/repair_with_details.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardRepairCard extends StatelessWidget {
  final RepairWithDetails repairWithDetails;

  const DashboardRepairCard({Key? key, required this.repairWithDetails})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repair = repairWithDetails.repair;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка или фото
            _buildLeading(theme),
            const SizedBox(width: 15),

            // Основная информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название ремонта
                  Text(
                    repair.partType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Позиция, автомобиль | Дата-время, стоимость
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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      repair.partPosition,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.8),
                                          ),
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
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.8),
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
                          // Дата и время вместе (если сегодня или завтра)
                          if (_shouldShowTime(repair.date))
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
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          if (_shouldShowTime(repair.date))
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(ThemeData theme) {
    final repair = repairWithDetails.repair;

    // Приоритет: логотип автомобиля, затем фото, затем иконка
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

    if (repair.photoPaths.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: FileImage(File(repair.photoPaths.first)),
        onBackgroundImageError: (error, stackTrace) {},
      );
    }

    return _buildDefaultIcon(theme);
  }

  Widget _buildDefaultIcon(ThemeData theme) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      child: Icon(
        Icons.build_circle_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
    );
  }

  bool _shouldShowTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    return dateOnly == today || dateOnly == tomorrow;
  }
}
