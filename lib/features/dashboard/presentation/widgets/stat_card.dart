import 'package:fit_progressor/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final TrendData? trend;
  final bool invertTrendColors; // Для показателей где рост = плохо (напр. просрочено)

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor = Colors.black,
    this.trend,
    this.invertTrendColors = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: theme.colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (trend != null && trend!.direction != TrendDirection.neutral)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _TrendIndicator(
                      trend: trend!,
                      invertColors: invertTrendColors,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Индикатор тренда (стрелка + процент)
class _TrendIndicator extends StatelessWidget {
  final TrendData trend;
  final bool invertColors;

  const _TrendIndicator({
    required this.trend,
    this.invertColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = trend.direction == TrendDirection.up;
    final isPositive = invertColors ? !isUp : isUp;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${trend.percentChange.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
