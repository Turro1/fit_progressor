import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair_status.dart';

class StatusTag extends StatelessWidget {
  final RepairStatus status;

  const StatusTag({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case RepairStatus.inProgress:
        backgroundColor = AppColors.accentPrimary;
        textColor = Colors.black;
        break;
      case RepairStatus.waitingParts:
        backgroundColor = AppColors.danger;
        textColor = Colors.white;
        break;
      case RepairStatus.completed:
        backgroundColor = AppColors.accentSecondary;
        textColor = Colors.black;
        break;
      case RepairStatus.cancelled:
        backgroundColor = AppColors.textSecondary;
        textColor = Colors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
