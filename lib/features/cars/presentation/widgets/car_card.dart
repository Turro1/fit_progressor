import 'package:flutter/material.dart';
import 'package:car_repair_manager/shared/widgets/entity_card.dart';
import 'package:car_repair_manager/core/widgets/country_flag.dart';
import '../../domain/entities/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap; // Optional tap action
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCard({
    Key? key,
    required this.car,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EntityCard(
      slidableKey: ValueKey(car.id),
      groupTag: 'car_actions',
      enableSwipeActions: onEdit != null || onDelete != null,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      // Новый дизайн
      compact: false,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.directions_car_rounded,
            size: 28,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        '${car.make} ${car.model}',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: PlateWithFlag(
        plate: car.plate,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      metadata: [
        if (car.clientName.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: theme.iconTheme.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  car.clientName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
      trailing: onTap != null
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.iconTheme.color,
              ),
            )
          : null,
    );
  }
}
