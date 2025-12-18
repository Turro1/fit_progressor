import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/material.dart' as material_entity;

class MaterialCard extends StatelessWidget {
  final material_entity.Material material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const MaterialCard({
    Key? key,
    required this.material,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color stockColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    if (material.isLowStock) {
      stockColor = theme.colorScheme.secondary;
    }
    if (material.isOutOfStock) {
      stockColor = theme.colorScheme.error;
    }

    return EntityCard(
      slidableKey: ValueKey(material.id),
      groupTag: 'material_actions',
      enableSwipeActions: true,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      leading: Icon(
        Icons.precision_manufacturing_rounded,
        size: 30,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        material.name,
        style: theme.textTheme.titleLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                size: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Закуп. цена: ${CurrencyFormatter.format(material.cost)}',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Мин. остаток: ${material.minQuantity} ${material.unit.displayName}',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('На складе:', style: theme.textTheme.bodyMedium),
              Text(
                '${material.quantity} ${material.unit.displayName}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: stockColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
