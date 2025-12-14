import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart'; // Import the generic EntityCard
import '../../domain/entities/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ClientCard({
    Key? key,
    required this.client,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

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
      // margin: const EdgeInsets.only(bottom: 15), // Removed hardcoded margin
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withAlpha(50),
        radius: 24,
        child: Text(
          client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        client.name,
        style: theme.textTheme.titleLarge,
      ),
      subtitle: Row(
        children: [
          Icon(Icons.call, size: 16, color: theme.iconTheme.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              client.phone,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
