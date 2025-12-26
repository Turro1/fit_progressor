import 'package:fit_progressor/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Виджет графика выручки за последние 14 дней
class RevenueChart extends StatelessWidget {
  final RevenueChartData data;

  const RevenueChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.dailyRevenue.isEmpty) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Выручка за месяц',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatMoney(data.totalRevenue)} ₽',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
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

    final step = chartWidth / (data.dailyRevenue.length - 1);

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
