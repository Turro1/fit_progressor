import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Анимированный FAB, который скрывается при скролле вниз
/// и появляется при скролле вверх.
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final ScrollController scrollController;
  final Duration animationDuration;
  final double hideThreshold;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.child,
    required this.scrollController,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hideThreshold = 10.0,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isVisible = true;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final direction = widget.scrollController.position.userScrollDirection;

    if (direction == _lastScrollDirection) return;
    _lastScrollDirection = direction;

    if (direction == ScrollDirection.reverse) {
      // Скролл вниз - скрыть FAB
      if (_isVisible) {
        _isVisible = false;
        _controller.forward();
      }
    } else if (direction == ScrollDirection.forward) {
      // Скролл вверх - показать FAB
      if (!_isVisible) {
        _isVisible = true;
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 3.14159,
            child: FloatingActionButton(
              onPressed: _isVisible ? widget.onPressed : null,
              backgroundColor:
                  widget.backgroundColor ?? theme.colorScheme.primary,
              foregroundColor:
                  widget.foregroundColor ?? theme.colorScheme.onPrimary,
              tooltip: widget.tooltip,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Extended FAB с анимацией скрытия при скролле
class AnimatedExtendedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ScrollController scrollController;
  final Duration animationDuration;

  const AnimatedExtendedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.scrollController,
    this.backgroundColor,
    this.foregroundColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedExtendedFAB> createState() => _AnimatedExtendedFABState();
}

class _AnimatedExtendedFABState extends State<AnimatedExtendedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExtended = true;
  bool _isVisible = true;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final direction = widget.scrollController.position.userScrollDirection;
    final offset = widget.scrollController.offset;

    // Сжимаем FAB при скролле вниз
    if (offset > 100 && _isExtended) {
      setState(() => _isExtended = false);
    } else if (offset <= 100 && !_isExtended) {
      setState(() => _isExtended = true);
    }

    if (direction == _lastScrollDirection) return;
    _lastScrollDirection = direction;

    if (direction == ScrollDirection.reverse) {
      if (_isVisible) {
        _isVisible = false;
        _controller.forward();
      }
    } else if (direction == ScrollDirection.forward) {
      if (!_isVisible) {
        _isVisible = true;
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _isVisible ? widget.onPressed : null,
            backgroundColor:
                widget.backgroundColor ?? theme.colorScheme.secondary,
            foregroundColor:
                widget.foregroundColor ?? theme.colorScheme.onSecondary,
            isExtended: _isExtended,
            icon: widget.icon,
            label: widget.label,
          ),
        );
      },
    );
  }
}

/// Контроллер для управления видимостью FAB извне
class FABVisibilityController extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}

/// Простой FAB с анимацией появления (без привязки к скроллу)
class AnimatedAppearFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final Duration delay;
  final Duration duration;

  const AnimatedAppearFAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.delay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedAppearFAB> createState() => _AnimatedAppearFABState();
}

class _AnimatedAppearFABState extends State<AnimatedAppearFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 3.14159,
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor:
                  widget.backgroundColor ?? theme.colorScheme.primary,
              foregroundColor:
                  widget.foregroundColor ?? theme.colorScheme.onPrimary,
              tooltip: widget.tooltip,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
