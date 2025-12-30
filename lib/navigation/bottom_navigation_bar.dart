import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentPath;

  const CustomBottomNavigationBar({super.key, required this.currentPath});

  static const _items = [
    _NavItem('/dashboard', Icons.query_stats, Icons.query_stats_outlined, 'Сводка'),
    _NavItem('/clients', Icons.groups_rounded, Icons.groups_outlined, 'Клиенты'),
    _NavItem('/cars', Icons.directions_car_rounded, Icons.directions_car_outlined, 'Авто'),
    _NavItem('/repairs', Icons.build_circle_rounded, Icons.build_circle_outlined, 'Ремонты'),
    _NavItem('/materials', Icons.inventory_2, Icons.inventory_2_outlined, 'Склад'),
  ];

  void _navigateTo(BuildContext context, String path) {
    if (currentPath == path) return;

    HapticFeedback.lightImpact();

    // Close any open modal bottom sheets before navigating
    final navigator = Navigator.of(context);
    while (navigator.canPop()) {
      navigator.pop();
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _items.indexWhere((item) => item.path == currentPath);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: currentIndex >= 0
                ? (MediaQuery.of(context).size.width / _items.length) * currentIndex +
                    (MediaQuery.of(context).size.width / _items.length - 40) / 2
                : 0,
            top: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: currentIndex >= 0 ? 1.0 : 0.0,
              child: Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          // Navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.map((item) {
              final isActive = currentPath == item.path;
              return _AnimatedNavButton(
                icon: isActive ? item.activeIcon : item.icon,
                label: item.label,
                isActive: isActive,
                onTap: () => _navigateTo(context, item.path),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _NavItem(this.path, this.activeIcon, this.icon, this.label);
}

class _AnimatedNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AnimatedNavButton> createState() => _AnimatedNavButtonState();
}

class _AnimatedNavButtonState extends State<_AnimatedNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );


    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        height: 70,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = widget.isActive ? _bounceAnimation.value : 1.0;

            return Transform.scale(
              scale: scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animated container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(widget.isActive ? 8 : 6),
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        widget.icon,
                        key: ValueKey(widget.isActive),
                        size: widget.isActive ? 26 : 24,
                        color: widget.isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: widget.isActive ? 11 : 10,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                      color: widget.isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
