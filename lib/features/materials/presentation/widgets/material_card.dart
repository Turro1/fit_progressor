import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/material.dart' as material_entity;

class MaterialCard extends StatelessWidget {
  final material_entity.Material material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MaterialCard({
    Key? key,
    required this.material,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color stockColor = theme.colorScheme.onSurface;
    if (material.isLowStock) {
      stockColor = theme.colorScheme.secondary;
    }
    if (material.isOutOfStock) {
      stockColor = theme.colorScheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Закуп. цена: ${CurrencyFormatter.format(material.cost)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Мин. остаток: ${material.minQuantity} ${material.unit.displayName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${material.quantity}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: stockColor,
                ),
              ),
              Text(
                material.unit.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: theme.colorScheme.error),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
