import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Виджет-обёртка для добавления микровзаимодействий при нажатии.
///
/// При нажатии элемент слегка уменьшается (scale effect), создавая
/// тактильный feedback и визуальное подтверждение нажатия.
class TapScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final Curve curve;
  final bool enableHapticFeedback;
  final HitTestBehavior behavior;

  const TapScaleWrapper({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.enableHapticFeedback = true,
    this.behavior = HitTestBehavior.opaque,
  }) : super(key: key);

  @override
  State<TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<TapScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  void _onTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  void _onLongPress() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap != null ? _onTap : null,
      onLongPress: widget.onLongPress != null ? _onLongPress : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Виджет-обёртка для карточек с микровзаимодействиями и эффектом наведения.
///
/// Расширенная версия TapScaleWrapper с дополнительными эффектами:
/// - Scale при нажатии
/// - Изменение elevation при наведении (для десктопа)
/// - Haptic feedback
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final bool enableHapticFeedback;
  final double elevation;
  final double hoverElevation;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const InteractiveCard({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.enableHapticFeedback = true,
    this.elevation = 2.0,
    this.hoverElevation = 4.0,
    this.borderRadius,
    this.color,
    this.margin,
  }) : super(key: key);

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  void _onTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  void _onLongPress() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveElevation = _isHovered || _isPressed
        ? widget.hoverElevation
        : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        onTap: widget.onTap != null ? _onTap : null,
        onLongPress: widget.onLongPress != null ? _onLongPress : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: widget.duration,
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.color ?? theme.cardColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: effectiveElevation * 2,
                  offset: Offset(0, effectiveElevation),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Простая обёртка с bounce-эффектом при нажатии.
class BounceWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const BounceWrapper({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<BounceWrapper> createState() => _BounceWrapperState();
}

class _BounceWrapperState extends State<BounceWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
