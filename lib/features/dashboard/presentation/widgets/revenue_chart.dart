import 'package:fit_progressor/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Период для графика выручки
enum ChartPeriod {
  week,
  month,
  quarter;

  String get label {
    switch (this) {
      case ChartPeriod.week:
        return 'Неделя';
      case ChartPeriod.month:
        return 'Месяц';
      case ChartPeriod.quarter:
        return 'Квартал';
    }
  }

  int get days {
    switch (this) {
      case ChartPeriod.week:
        return 7;
      case ChartPeriod.month:
        return 30;
      case ChartPeriod.quarter:
        return 90;
    }
  }
}

/// Виджет графика выручки с выбором периода
class RevenueChart extends StatefulWidget {
  final RevenueChartData data;

  const RevenueChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  RevenueChartData get _filteredData {
    if (widget.data.dailyRevenue.isEmpty) {
      return widget.data;
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedPeriod.days));

    final filteredRevenue = widget.data.dailyRevenue
        .where((r) => r.date.isAfter(cutoffDate))
        .toList();

    if (filteredRevenue.isEmpty) {
      return const RevenueChartData.empty();
    }

    final maxValue = filteredRevenue.map((r) => r.revenue).reduce((a, b) => a > b ? a : b);
    final totalRevenue = filteredRevenue.map((r) => r.revenue).reduce((a, b) => a + b);

    return RevenueChartData(
      dailyRevenue: filteredRevenue,
      maxValue: maxValue,
      totalRevenue: totalRevenue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _filteredData;

    if (widget.data.dailyRevenue.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Нет данных для отображения',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header с выбором периода
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выручка',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatMoney(data.totalRevenue)} ₽',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Период selector
            _buildPeriodSelector(theme),
            const SizedBox(height: 16),

            // График
            SizedBox(
              height: 120,
              child: data.dailyRevenue.isEmpty
                  ? Center(
                      child: Text(
                        'Нет данных за выбранный период',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: _ChartPainter(
                        data: data,
                        lineColor: theme.colorScheme.primary,
                        fillColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        gridColor: theme.colorScheme.outlineVariant,
                        textColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 8),

            // Легенда с датами
            if (data.dailyRevenue.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatShortDate(data.dailyRevenue.first.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatShortDate(data.dailyRevenue.last.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}М';
    } else if (value >= 1000) {
      return NumberFormat('#,##0', 'ru').format(value.round());
    }
    return value.toStringAsFixed(0);
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('d MMM', 'ru').format(date);
  }
}

/// CustomPainter для отрисовки графика
class _ChartPainter extends CustomPainter {
  final RevenueChartData data;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color textColor;

  _ChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dailyRevenue.isEmpty || data.maxValue == 0) {
      // Рисуем плоскую линию если нет данных
      final paint = Paint()
        ..color = gridColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Отступы
    const paddingTop = 10.0;
    const paddingBottom = 5.0;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final chartWidth = size.width;

    // Горизонтальные линии сетки
    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint..color = gridColor.withValues(alpha: 0.3),
      );
    }

    // Построение пути графика
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    final step = data.dailyRevenue.length > 1
        ? chartWidth / (data.dailyRevenue.length - 1)
        : chartWidth;

    for (int i = 0; i < data.dailyRevenue.length; i++) {
      final revenue = data.dailyRevenue[i].revenue;
      final x = step * i;
      final normalizedY = data.maxValue > 0 ? revenue / data.maxValue : 0;
      final y = paddingTop + chartHeight * (1 - normalizedY);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Используем квадратичную кривую Безье для сглаживания
        final prevPoint = points[i - 1];
        final midX = (prevPoint.dx + x) / 2;
        path.quadraticBezierTo(midX, prevPoint.dy, midX, (prevPoint.dy + y) / 2);
        path.quadraticBezierTo(midX, y, x, y);

        fillPath.quadraticBezierTo(midX, prevPoint.dy, midX, (prevPoint.dy + y) / 2);
        fillPath.quadraticBezierTo(midX, y, x, y);
      }
    }

    // Завершаем путь заливки
    fillPath.lineTo(chartWidth, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Рисуем заливку
    canvas.drawPath(fillPath, fillPaint);

    // Рисуем линию
    canvas.drawPath(path, linePaint);

    // Рисуем точки для дней с выручкой
    for (int i = 0; i < points.length; i++) {
      if (data.dailyRevenue[i].revenue > 0) {
        canvas.drawCircle(points[i], 4, dotPaint);
        canvas.drawCircle(
          points[i],
          2,
          Paint()..color = fillColor.withValues(alpha: 1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

/// Компактная версия графика для карточки
class MiniRevenueChart extends StatelessWidget {
  final RevenueChartData data;
  final double height;

  const MiniRevenueChart({
    Key? key,
    required this.data,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _MiniChartPainter(
          data: data,
          lineColor: theme.colorScheme.primary,
          fillColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final RevenueChartData data;
  final Color lineColor;
  final Color fillColor;

  _MiniChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dailyRevenue.isEmpty || data.maxValue == 0) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final step = size.width / (data.dailyRevenue.length - 1);

    for (int i = 0; i < data.dailyRevenue.length; i++) {
      final revenue = data.dailyRevenue[i].revenue;
      final x = step * i;
      final normalizedY = data.maxValue > 0 ? revenue / data.maxValue : 0;
      final y = size.height * (1 - normalizedY * 0.9) + 2;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
