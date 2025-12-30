import 'package:fit_progressor/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:fit_progressor/shared/widgets/animated_counter.dart';
import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final TrendData? trend;
  final bool invertTrendColors;
  final double? numericValue; // Числовое значение для анимации
  final VoidCallback? onTap; // Callback при нажатии

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor = Colors.black,
    this.trend,
    this.invertTrendColors = false,
    this.numericValue,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClickable = widget.onTap != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Ripple overlay for clickable cards
              if (isClickable)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    // Иконка в правом верхнем углу
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    // Контент карточки
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Лейбл с ограничением по ширине (не заходит под иконку)
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Text(
                            widget.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        // Значение и тренд
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: widget.numericValue != null
                                    ? AnimatedCounter(
                                        value: widget.numericValue!,
                                        suffix: _extractSuffix(widget.value),
                                        formatAsCompact: true,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: widget.valueColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        widget.value,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: widget.valueColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            if (widget.trend != null &&
                                widget.trend!.direction != TrendDirection.neutral)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: _TrendIndicator(
                                  trend: widget.trend!,
                                  invertColors: widget.invertTrendColors,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _extractSuffix(String value) {
    // Извлекаем суффикс из строки (например " ₽" из "150,000 ₽")
    final match = RegExp(r'[^\d\s,\.МК]+$').firstMatch(value.trim());
    if (match != null) {
      return ' ${match.group(0)}';
    }
    return null;
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
