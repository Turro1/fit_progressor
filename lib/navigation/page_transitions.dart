import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fade Through transition из Material Motion Guidelines.
/// Используется при переключении между несвязанными экранами (табы).
class FadeThroughPage<T> extends CustomTransitionPage<T> {
  FadeThroughPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Виджет для Fade Through анимации
class FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const FadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Shared Axis transition из Material Motion Guidelines.
/// Используется при навигации внутри иерархии (push/pop).
class SharedAxisPage<T> extends CustomTransitionPage<T> {
  SharedAxisPage({
    required super.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  final SharedAxisTransitionType transitionType;
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }

/// Виджет для Shared Axis анимации
class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-0.1, 0),
                ).animate(CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInCubic,
                )),
                child: child,
              ),
            ),
          ),
        );

      case SharedAxisTransitionType.vertical:
        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -0.1),
                ).animate(CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInCubic,
                )),
                child: child,
              ),
            ),
          ),
        );

      case SharedAxisTransitionType.scaled:
        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                  CurvedAnimation(
                    parent: secondaryAnimation,
                    curve: Curves.easeInCubic,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
    }
  }
}

/// Container Transform transition из Material Motion Guidelines.
/// Используется для hero-like анимаций между карточкой и детальным экраном.
class ContainerTransformPage<T> extends CustomTransitionPage<T> {
  ContainerTransformPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}
