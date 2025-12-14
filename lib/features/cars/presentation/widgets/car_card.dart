import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart'; // Import the generic EntityCard
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
      leading: Icon(
        Icons.directions_car,
        size: 30,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        '${car.make} ${car.model}',
        style: theme.textTheme.titleLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        car.plate,
        style: theme.textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}