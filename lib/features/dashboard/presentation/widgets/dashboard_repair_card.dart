import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/status_tag.dart';
import 'package:flutter/material.dart';

class DashboardRepairCard extends StatelessWidget {
  final Repair repair;

  const DashboardRepairCard({Key? key, required this.repair}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.directions_car, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${repair.carMake ?? ''} ${repair.carModel ?? ''}',
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    repair.description,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusTag(status: repair.status),
          ],
        ),
      ),
    );
  }
}
