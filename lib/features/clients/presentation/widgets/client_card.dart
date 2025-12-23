import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/entity_card.dart';
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

  String _formatPhone(String phone) {
    // Форматирование телефона: +7 (999) 123-45-67
    if (phone.isEmpty) return phone;

    // Убираем все кроме цифр
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 11 && digits.startsWith('7')) {
      // Российский номер
      return '+373 (${digits.substring(1, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 9)}-${digits.substring(9, 11)}';
    } else if (digits.length >= 10) {
      // Другой формат
      return '+${digits.substring(0, 3)} (${digits.substring(3, 6)}) ${digits.substring(6, 9)}-${digits.substring(9, 11)}';
    }

    return phone; // Возвращаем как есть, если не можем отформатировать
  }

  int _getCarsCount() {
    // TODO: Получить реальное количество автомобилей из репозитория
    // Пока возвращаем 0, так как в entity Client нет этого поля
    return 0;
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
        if (_getCarsCount() > 0)
          Text(
            '${_getCarsCount()} автомобилей',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
