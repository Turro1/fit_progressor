import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart'; // Import the generic EntityCard
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import '../../domain/entities/car.dart';
import 'dart:developer' as developer;

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
      elevation: 2.0,
      leading: CircleAvatar(
        radius: 38,
        backgroundColor: Colors.white,
        child: Image.asset(
            CarLogoHelper.getLogoPath(car.make),
            fit: BoxFit.none,
            scale: 24,
            errorBuilder: (context, error, stackTrace) {
              developer.log(
                'Failed to load logo for ${car.make}: $error',
                name: 'CarCard',
                error: error,
                stackTrace: stackTrace,
              );
              return Icon(
                Icons.directions_car_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              );
            },
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
      subtitle: Row(
        children: [
          Icon(
            Icons.confirmation_number,
            size: 16,
            color: theme.iconTheme.color?.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              car.plate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.8,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color,
            )
          : null,
    );
  }
}
