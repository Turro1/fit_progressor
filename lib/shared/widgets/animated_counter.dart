import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Виджет для анимированного отображения числовых значений.
///
/// При изменении значения число плавно "отсчитывается" от старого к новому,
/// создавая эффект счётчика.
class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;
  final bool formatAsCompact;
  final String locale;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
    this.formatAsCompact = false,
    this.locale = 'ru',
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _oldValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.formatAsCompact) {
      return _formatCompact(value);
    }

    if (widget.decimalPlaces > 0) {
      return NumberFormat.decimalPattern(widget.locale)
          .format(double.parse(value.toStringAsFixed(widget.decimalPlaces)));
    }

    return NumberFormat('#,##0', widget.locale).format(value.round());
  }

  String _formatCompact(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}М';
    } else if (value.abs() >= 1000) {
      return NumberFormat('#,##0', widget.locale).format(value.round());
    }
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formattedValue = _formatValue(_animation.value);
        return Text(
          '${widget.prefix ?? ''}$formattedValue${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Виджет для анимированного отображения целых чисел.
class AnimatedIntCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;

  const AnimatedIntCounter({
    Key? key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  State<AnimatedIntCounter> createState() => _AnimatedIntCounterState();
}

class _AnimatedIntCounterState extends State<AnimatedIntCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedIntCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = IntTween(
        begin: _oldValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}
