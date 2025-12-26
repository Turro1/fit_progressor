import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
import 'package:fit_progressor/core/utils/moldova_formatters.dart';
import '../../domain/entities/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final int carsCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ClientCard({
    Key? key,
    required this.client,
    this.carsCount = 0,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  String _formatPhone(String phone) {
    if (phone.isEmpty) return 'Не указан';
    return MoldovaValidators.formatPhoneForDisplay(phone);
  }

  String _getCarsCountText() {
    if (carsCount == 0) return '';
    if (carsCount == 1) return '1 автомобиль';
    if (carsCount >= 2 && carsCount <= 4) return '$carsCount автомобиля';
    return '$carsCount автомобилей';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EntityCard(
      slidableKey: ValueKey(client.id),
      groupTag: 'client_actions',
      enableSwipeActions: onEdit != null || onDelete != null,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      // Новый дизайн
      compact: false,
      elevation: 2.0,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        radius: 28, // 56dp diameter
        child: Text(
          client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      title: Text(
        client.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(
            Icons.phone,
            size: 16,
            color: theme.iconTheme.color?.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _formatPhone(client.phone),
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
        if (carsCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getCarsCountText(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
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
