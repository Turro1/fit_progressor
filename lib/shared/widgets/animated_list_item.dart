import 'package:flutter/material.dart';

/// Виджет для каскадной анимации элементов списка (staggered animation).
///
/// Каждый элемент появляется с небольшой задержкой относительно предыдущего,
/// создавая эффект "волны" при загрузке списка.
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final Curve curve;
  /// Включить/выключить анимацию. Если false - элемент показывается сразу.
  final bool animate;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Запускаем анимацию с задержкой в зависимости от индекса
    Future.delayed(widget.delay * widget.index, () {
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
    // Если анимация отключена - показываем элемент сразу
    if (!widget.animate) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Контроллер для управления анимациями списка.
/// Полезен когда нужно перезапустить анимации при обновлении данных.
class AnimatedListController extends ChangeNotifier {
  int _animationKey = 0;

  int get animationKey => _animationKey;

  /// Сбрасывает анимации, заставляя все элементы перезапустить анимацию
  void reset() {
    _animationKey++;
    notifyListeners();
  }
}

/// Обёртка для ListView с автоматической каскадной анимацией элементов.
class AnimatedListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Duration itemDelay;
  final Duration itemDuration;
  final bool shrinkWrap;

  const AnimatedListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.physics,
    this.itemDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  State<AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<AnimatedListView> {
  // Ключ для сброса анимаций при изменении данных
  int _listKey = 0;

  @override
  void didUpdateWidget(AnimatedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Перезапускаем анимации если количество элементов изменилось
    if (oldWidget.itemCount != widget.itemCount) {
      setState(() {
        _listKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: ValueKey(_listKey),
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          key: ValueKey('$_listKey-$index'),
          index: index,
          delay: widget.itemDelay,
          duration: widget.itemDuration,
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}
