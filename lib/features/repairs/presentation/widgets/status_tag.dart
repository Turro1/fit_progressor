import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart'; // Keep AppColors for info and success
import '../../domain/entities/repair_status.dart';

class StatusTag extends StatelessWidget {
  final RepairStatus status;
  final double fontSize;
  final bool compact;

  const StatusTag({
    Key? key,
    required this.status,
    this.fontSize = 11,
    this.compact = false,
  }) : super(key: key);

  Color _getStatusColor(BuildContext context, RepairStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case RepairStatus.inProgress:
        return AppColors.info; // Using AppColors directly as info is not in ColorScheme
      case RepairStatus.waitingParts:
        return theme.colorScheme.secondary;
      case RepairStatus.completed:
        return AppColors.success; // Using AppColors directly as success is not in ColorScheme
      case RepairStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(context, status).withAlpha((255 * 0.2).round()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(context, status),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
