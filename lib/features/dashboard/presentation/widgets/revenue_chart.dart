import 'dart:ui' as ui;

import 'package:fit_progressor/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Период для графика выручки
enum ChartPeriod {
  week,
  month,
  lastMonth;

  String get label {
    switch (this) {
      case ChartPeriod.week:
        return 'Неделя';
      case ChartPeriod.month:
        return 'Месяц';
      case ChartPeriod.lastMonth:
        return 'Пред. месяц';
    }
  }

  int get days {
    switch (this) {
      case ChartPeriod.week:
        return 7;
      case ChartPeriod.month:
        return 30;
      case ChartPeriod.lastMonth:
        return 30;
    }
  }

  /// Смещение в днях от сегодня
  int get daysOffset {
    switch (this) {
      case ChartPeriod.week:
        return 0;
      case ChartPeriod.month:
        return 0;
      case ChartPeriod.lastMonth:
        return 30;
    }
  }
}

/// Виджет графика выручки с выбором периода
class RevenueChart extends StatefulWidget {
  final RevenueChartData data;
  final RevenueChartData? previousPeriodData;

  const RevenueChart({
    Key? key,
    required this.data,
    this.previousPeriodData,
  }) : super(key: key);

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart>
    with SingleTickerProviderStateMixin {
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  int? _selectedPointIndex;
  bool _showComparison = false;

  late AnimationController _animationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changePeriod(ChartPeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
        _selectedPointIndex = null;
      });
      _animationController.forward(from: 0);
    }
  }

  RevenueChartData get _filteredData {
    if (widget.data.dailyRevenue.isEmpty) {
      return widget.data;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<DailyRevenue> filteredRevenue;

    if (_selectedPeriod == ChartPeriod.lastMonth) {
      // Прошлый месяц: 30-60 дней назад
      final startDate = today.subtract(Duration(days: 60));
      final endDate = today.subtract(Duration(days: 30));
      filteredRevenue = widget.data.dailyRevenue.where((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate.isAfter(startDate) && rDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      // Если нет данных в основном списке, пробуем из previousPeriodData
      if (filteredRevenue.isEmpty && widget.previousPeriodData != null) {
        filteredRevenue = widget.previousPeriodData!.dailyRevenue;
      }
    } else {
      // Текущий период (неделя или месяц)
      final cutoffDate = today.subtract(Duration(days: _selectedPeriod.days));
      filteredRevenue = widget.data.dailyRevenue
          .where((r) => r.date.isAfter(cutoffDate))
          .toList();
    }

    if (filteredRevenue.isEmpty) {
      return const RevenueChartData.empty();
    }

    final maxValue =
        filteredRevenue.map((r) => r.revenue).reduce((a, b) => a > b ? a : b);
    final totalRevenue =
        filteredRevenue.map((r) => r.revenue).reduce((a, b) => a + b);

    return RevenueChartData(
      dailyRevenue: filteredRevenue,
      maxValue: maxValue,
      totalRevenue: totalRevenue,
    );
  }

  /// Данные за предыдущий аналогичный период (для сравнения)
  RevenueChartData? get _comparisonData {
    if (widget.previousPeriodData == null ||
        widget.previousPeriodData!.dailyRevenue.isEmpty ||
        _selectedPeriod == ChartPeriod.lastMonth) {
      return null;
    }

    return widget.previousPeriodData;
  }

  /// Процент изменения по сравнению с прошлым периодом
  double? get _percentChange {
    final currentTotal = _filteredData.totalRevenue;
    final previousTotal = _comparisonData?.totalRevenue ?? 0;

    if (previousTotal == 0) return null;

    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _filteredData;
    final comparisonData = _comparisonData;
    final percentChange = _percentChange;

    if (widget.data.dailyRevenue.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.show_chart_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'Нет данных для отображения',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Данные появятся после добавления ремонтов',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
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
            // Header
            _buildHeader(theme, data, percentChange, comparisonData),
            const SizedBox(height: 12),

            // Период selector
            _buildPeriodSelector(theme),
            const SizedBox(height: 16),

            // График с поддержкой свайпа
            GestureDetector(
              onHorizontalDragEnd: (details) => _handleSwipe(details),
              child: SizedBox(
                height: 140,
                child: data.dailyRevenue.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildChart(theme, data, comparisonData),
              ),
            ),
            const SizedBox(height: 8),

            // Легенда с датами
            if (data.dailyRevenue.isNotEmpty) _buildLegend(theme, data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    RevenueChartData data,
    double? percentChange,
    RevenueChartData? comparisonData,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Выручка',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedPeriod == ChartPeriod.lastMonth)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'пред. месяц',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatMoney(data.totalRevenue)} \u20bd',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Показываем изменение
                  if (percentChange != null &&
                      _selectedPeriod != ChartPeriod.lastMonth)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: _buildPercentBadge(theme, percentChange),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Toggle сравнения (только для текущих периодов)
        if (comparisonData != null && _selectedPeriod != ChartPeriod.lastMonth)
          _buildComparisonToggle(theme),
      ],
    );
  }

  Widget _buildPercentBadge(ThemeData theme, double percent) {
    final isPositive = percent >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? '+' : ''}${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonToggle(ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => _showComparison = !_showComparison),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _showComparison
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 16,
              color: _showComparison
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Сравнить',
              style: theme.textTheme.labelSmall?.copyWith(
                color: _showComparison
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight:
                    _showComparison ? FontWeight.w600 : FontWeight.normal,
              ),
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
              onTap: () => _changePeriod(period),
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Нет данных за выбранный период',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    ThemeData theme,
    RevenueChartData data,
    RevenueChartData? comparisonData,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) =>
              _handleTap(details, constraints.maxWidth, data),
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, 120),
                    painter: _ChartPainter(
                      data: data,
                      previousData: _showComparison ? comparisonData : null,
                      lineColor: theme.colorScheme.primary,
                      fillColors: [
                        theme.colorScheme.primary.withValues(alpha: 0.25),
                        theme.colorScheme.primary.withValues(alpha: 0.02),
                      ],
                      gridColor: theme.colorScheme.outlineVariant,
                      textColor: theme.colorScheme.onSurfaceVariant,
                      previousLineColor:
                          theme.colorScheme.outline.withValues(alpha: 0.4),
                      selectedIndex: _selectedPointIndex,
                      selectedColor: theme.colorScheme.primary,
                      animationValue: _chartAnimation.value,
                    ),
                  ),
                  // Tooltip
                  if (_selectedPointIndex != null &&
                      _selectedPointIndex! < data.dailyRevenue.length)
                    _buildTooltip(
                      context,
                      data,
                      constraints.maxWidth,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTooltip(
      BuildContext context, RevenueChartData data, double chartWidth) {
    final theme = Theme.of(context);
    final index = _selectedPointIndex!;
    final point = data.dailyRevenue[index];

    final step = data.dailyRevenue.length > 1
        ? chartWidth / (data.dailyRevenue.length - 1)
        : chartWidth;

    final pointX = step * index;
    const tooltipWidth = 120.0;

    // Вычисляем позицию tooltip
    double tooltipLeft = pointX - tooltipWidth / 2;
    if (tooltipLeft < 0) tooltipLeft = 0;
    if (tooltipLeft + tooltipWidth > chartWidth) {
      tooltipLeft = chartWidth - tooltipWidth;
    }

    return Positioned(
      left: tooltipLeft,
      top: -50,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 5 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMMM', 'ru').format(point.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatMoney(point.revenue)} \u20bd',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (point.repairsCount > 0)
                Text(
                  '${point.repairsCount} ${_pluralizeRepairs(point.repairsCount)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, RevenueChartData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatShortDate(data.dailyRevenue.first.date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_showComparison && _comparisonData != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Пред. период',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        Text(
          _formatShortDate(data.dailyRevenue.last.date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _handleTap(
      TapDownDetails details, double chartWidth, RevenueChartData data) {
    if (data.dailyRevenue.isEmpty) return;

    final step = data.dailyRevenue.length > 1
        ? chartWidth / (data.dailyRevenue.length - 1)
        : chartWidth;

    final tapX = details.localPosition.dx;
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < data.dailyRevenue.length; i++) {
      final pointX = step * i;
      final distance = (tapX - pointX).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (minDistance < 30) {
      setState(() {
        if (_selectedPointIndex == closestIndex) {
          _selectedPointIndex = null;
        } else {
          _selectedPointIndex = closestIndex;
        }
      });
    } else {
      setState(() => _selectedPointIndex = null);
    }
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 200) return;

    final periods = ChartPeriod.values;
    final currentIndex = periods.indexOf(_selectedPeriod);

    if (velocity > 0 && currentIndex > 0) {
      // Свайп вправо - предыдущий период
      _changePeriod(periods[currentIndex - 1]);
    } else if (velocity < 0 && currentIndex < periods.length - 1) {
      // Свайп влево - следующий период
      _changePeriod(periods[currentIndex + 1]);
    }
  }

  String _pluralizeRepairs(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'ремонт';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'ремонта';
    }
    return 'ремонтов';
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
  final RevenueChartData? previousData;
  final Color lineColor;
  final List<Color> fillColors;
  final Color gridColor;
  final Color textColor;
  final Color previousLineColor;
  final int? selectedIndex;
  final Color selectedColor;
  final double animationValue;

  _ChartPainter({
    required this.data,
    this.previousData,
    required this.lineColor,
    required this.fillColors,
    required this.gridColor,
    required this.textColor,
    required this.previousLineColor,
    this.selectedIndex,
    required this.selectedColor,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dailyRevenue.isEmpty || data.maxValue == 0) {
      _drawEmptyLine(canvas, size);
      return;
    }

    const paddingTop = 10.0;
    const paddingBottom = 5.0;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final chartWidth = size.width;

    // Определяем максимальное значение для масштаба
    double maxValue = data.maxValue;
    if (previousData != null && previousData!.maxValue > maxValue) {
      maxValue = previousData!.maxValue;
    }

    // Рисуем сетку
    _drawGrid(canvas, size, chartHeight, chartWidth, paddingTop);

    // Рисуем линию предыдущего периода
    if (previousData != null && previousData!.dailyRevenue.isNotEmpty) {
      _drawLine(
        canvas: canvas,
        size: size,
        data: previousData!,
        maxValue: maxValue,
        chartHeight: chartHeight,
        chartWidth: chartWidth,
        paddingTop: paddingTop,
        lineColor: previousLineColor,
        fillColors: null,
        drawDots: false,
        isDashed: true,
      );
    }

    // Рисуем основной график
    final points = _drawLine(
      canvas: canvas,
      size: size,
      data: data,
      maxValue: maxValue,
      chartHeight: chartHeight,
      chartWidth: chartWidth,
      paddingTop: paddingTop,
      lineColor: lineColor,
      fillColors: fillColors,
      drawDots: true,
      isDashed: false,
    );

    // Рисуем выделенную точку
    if (selectedIndex != null && selectedIndex! < points.length) {
      _drawSelectedPoint(canvas, points[selectedIndex!], paddingTop,
          size.height - paddingBottom);
    }
  }

  void _drawEmptyLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size, double chartHeight, double chartWidth,
      double paddingTop) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }
  }

  List<Offset> _drawLine({
    required Canvas canvas,
    required Size size,
    required RevenueChartData data,
    required double maxValue,
    required double chartHeight,
    required double chartWidth,
    required double paddingTop,
    required Color lineColor,
    List<Color>? fillColors,
    required bool drawDots,
    required bool isDashed,
  }) {
    final points = <Offset>[];
    final step = data.dailyRevenue.length > 1
        ? chartWidth / (data.dailyRevenue.length - 1)
        : chartWidth;

    // Вычисляем точки
    for (int i = 0; i < data.dailyRevenue.length; i++) {
      final revenue = data.dailyRevenue[i].revenue;
      final x = step * i;
      final normalizedY = maxValue > 0 ? revenue / maxValue : 0;
      // Применяем анимацию к Y
      final animatedY = normalizedY * animationValue;
      final y = paddingTop + chartHeight * (1 - animatedY);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return points;

    // Строим path с кривыми Безье
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;

      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    // Рисуем заливку с градиентом
    if (fillColors != null && fillColors.length >= 2) {
      final fillPath = Path.from(path);
      fillPath.lineTo(chartWidth, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final gradient = ui.Gradient.linear(
        Offset(0, paddingTop),
        Offset(0, size.height),
        fillColors,
      );

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill,
      );
    }

    // Рисуем линию
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = isDashed ? 1.5 : 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isDashed) {
      _drawDashedPath(canvas, path, linePaint);
    } else {
      canvas.drawPath(path, linePaint);
    }

    // Рисуем точки
    if (drawDots) {
      for (int i = 0; i < points.length; i++) {
        if (data.dailyRevenue[i].revenue > 0) {
          // Внешний круг
          canvas.drawCircle(
            points[i],
            4,
            Paint()..color = lineColor,
          );
          // Внутренний круг
          canvas.drawCircle(
            points[i],
            2,
            Paint()..color = Colors.white,
          );
        }
      }
    }

    return points;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawSelectedPoint(
      Canvas canvas, Offset point, double top, double bottom) {
    // Вертикальная линия
    canvas.drawLine(
      Offset(point.dx, top),
      Offset(point.dx, bottom),
      Paint()
        ..color = selectedColor.withValues(alpha: 0.2)
        ..strokeWidth = 1.5,
    );

    // Пульсирующий круг
    canvas.drawCircle(
      point,
      10,
      Paint()..color = selectedColor.withValues(alpha: 0.15),
    );

    // Основной круг
    canvas.drawCircle(
      point,
      6,
      Paint()..color = selectedColor,
    );

    // Внутренний белый круг
    canvas.drawCircle(
      point,
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.previousData != previousData ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationValue != animationValue;
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
