import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import '../../domain/entities/material.dart' as entity;

class MaterialCard extends StatelessWidget {
  final entity.Material material;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MaterialCard({
    Key? key,
    required this.material,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine stock status color
    Color getStatusColor() {
      if (material.isOutOfStock) {
        return theme.colorScheme.error;
      } else if (material.isLowStock) {
        return Colors.orange;
      }
      return theme.colorScheme.secondary;
    }

    // Determine stock status icon
    IconData getStatusIcon() {
      if (material.isOutOfStock) {
        return Icons.error_outline;
      } else if (material.isLowStock) {
        return Icons.warning_amber_rounded;
      }
      return Icons.check_circle_outline;
    }

    return EntityCard(
      slidableKey: ValueKey(material.id),
      groupTag: 'material_actions',
      enableSwipeActions: onEdit != null || onDelete != null,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      compact: false,
      elevation: 2.0,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: getStatusColor().withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.inventory_2_rounded,
          size: 32,
          color: getStatusColor(),
        ),
      ),
      title: Text(
        material.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(
            getStatusIcon(),
            size: 16,
            color: getStatusColor(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${material.quantity.toStringAsFixed(1)} ${material.unit.displayName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      metadata: [
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 14,
              color: theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '${material.cost.toStringAsFixed(2)} ₽',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.low_priority,
              size: 14,
              color: theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Мин: ${material.minQuantity.toStringAsFixed(1)} ${material.unit.displayName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.6,
                ),
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
