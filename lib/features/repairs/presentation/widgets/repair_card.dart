import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/repair.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const RepairCard({
    Key? key,
    required this.repair,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EntityCard(
      slidableKey: ValueKey(repair.id),
      groupTag: 'repair_actions',
      enableSwipeActions: onEdit != null || onDelete != null,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      compact: false,
      elevation: 2.0,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        radius: 28,
        child: Icon(
          Icons.build_circle,
          size: 32,
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        repair.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (repair.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              repair.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.iconTheme.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(repair.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      metadata: [
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              _formatCurrency(repair.cost),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
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
