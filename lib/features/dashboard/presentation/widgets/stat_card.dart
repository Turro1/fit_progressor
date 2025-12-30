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
  final double? numericValue;
  final bool isHighlighted;

  /// Контент для всплывающей подсказки
  final Widget? tooltipContent;

  /// Текстовая подсказка (если не нужен кастомный контент)
  final String? tooltipText;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor = Colors.black,
    this.trend,
    this.invertTrendColors = false,
    this.numericValue,
    this.isHighlighted = false,
    this.tooltipContent,
    this.tooltipText,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  OverlayEntry? _overlayEntry;
  final GlobalKey _cardKey = GlobalKey();

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
    _hideTooltip();
    _scaleController.dispose();
    super.dispose();
  }

  bool get _hasTooltip => widget.tooltipContent != null || widget.tooltipText != null;

  void _showTooltip() {
    if (!_hasTooltip) return;

    _hideTooltip();

    final RenderBox? renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        position: position,
        cardSize: size,
        content: widget.tooltipContent ?? _buildTextTooltip(context),
        onDismiss: _hideTooltip,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildTextTooltip(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      widget.tooltipText ?? '',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onInverseSurface,
      ),
    );
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        key: _cardKey,
        clipBehavior: Clip.antiAlias,
        elevation: widget.isHighlighted ? 4 : null,
        shape: widget.isHighlighted
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              )
            : null,
        child: Container(
          decoration: widget.isHighlighted
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      theme.colorScheme.surface,
                    ],
                  ),
                )
              : null,
          child: InkWell(
            onTap: _hasTooltip ? _showTooltip : null,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Индикатор что есть подсказка
                if (_hasTooltip)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
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
                          // Лейбл
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
      ),
    );
  }

  String? _extractSuffix(String value) {
    final match = RegExp(r'[^\d\s,\.МК]+$').firstMatch(value.trim());
    if (match != null) {
      return ' ${match.group(0)}';
    }
    return null;
  }
}

/// Overlay для показа tooltip
class _TooltipOverlay extends StatefulWidget {
  final Offset position;
  final Size cardSize;
  final Widget content;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.position,
    required this.cardSize,
    required this.content,
    required this.onDismiss,
  });

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Автоматически скрываем через 4 секунды
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Вычисляем позицию tooltip
    const tooltipMaxWidth = 280.0;
    const padding = 8.0;

    // Позиционируем tooltip над карточкой по центру
    double left = widget.position.dx + (widget.cardSize.width / 2) - (tooltipMaxWidth / 2);

    // Корректируем если выходит за границы экрана
    if (left < padding) left = padding;
    if (left + tooltipMaxWidth > screenSize.width - padding) {
      left = screenSize.width - tooltipMaxWidth - padding;
    }

    // Tooltip появляется над карточкой
    double top = widget.position.dy - padding;
    bool showAbove = true;

    // Если не помещается сверху, показываем снизу
    if (top < 100) {
      top = widget.position.dy + widget.cardSize.height + padding;
      showAbove = false;
    }

    return Stack(
      children: [
        // Затемнение фона для закрытия
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Tooltip
        Positioned(
          left: left,
          top: showAbove ? null : top,
          bottom: showAbove ? screenSize.height - top : null,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: tooltipMaxWidth),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.content,
                ),
              ),
            ),
          ),
        ),
      ],
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

/// Виджет для отображения списка материалов с низким остатком в tooltip
class LowStockTooltipContent extends StatelessWidget {
  final List<LowStockItem> items;
  final VoidCallback? onViewAll;

  const LowStockTooltipContent({
    Key? key,
    required this.items,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onInverseSurface;

    if (items.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade300),
          const SizedBox(width: 8),
          Text(
            'Все материалы в достатке',
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Требуют пополнения:',
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...items.take(4).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.isOutOfStock ? Colors.red.shade300 : Colors.orange.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(color: textColor, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.quantity} ${item.unit}',
                style: TextStyle(
                  color: item.isOutOfStock ? Colors.red.shade300 : Colors.orange.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )),
        if (items.length > 4) ...[
          const SizedBox(height: 4),
          Text(
            'и ещё ${items.length - 4}...',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// Модель для элемента с низким остатком
class LowStockItem {
  final String name;
  final String quantity;
  final String unit;
  final bool isOutOfStock;

  const LowStockItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.isOutOfStock = false,
  });
}

/// Виджет для отображения информации о тренде в tooltip
class TrendTooltipContent extends StatelessWidget {
  final String currentValue;
  final String previousValue;
  final String periodLabel;
  final bool isPositive;

  const TrendTooltipContent({
    Key? key,
    required this.currentValue,
    required this.previousValue,
    required this.periodLabel,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onInverseSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сейчас: ',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              currentValue,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$periodLabel: ',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              previousValue,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
