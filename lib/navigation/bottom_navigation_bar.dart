import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentPath;

  const CustomBottomNavigationBar({super.key, required this.currentPath});

  void _navigateTo(BuildContext context, String path) {
    // Close any open modal bottom sheets before navigating
    final navigator = Navigator.of(context);
    // Pop all modal routes (bottom sheets, dialogs, etc.)
    while (navigator.canPop()) {
      navigator.pop();
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavButton(
            icon: Icons.query_stats,
            label: 'Сводка',
            isActive: currentPath == '/dashboard',
            onTap: () => _navigateTo(context, '/dashboard'),
          ),
          _NavButton(
            icon: Icons.groups_rounded,
            label: 'Клиенты',
            isActive: currentPath == '/clients',
            onTap: () => _navigateTo(context, '/clients'),
          ),
          _NavButton(
            icon: Icons.directions_car_rounded,
            label: 'Авто',
            isActive: currentPath == '/cars',
            onTap: () => _navigateTo(context, '/cars'),
          ),
          _NavButton(
            icon: Icons.build_circle_rounded,
            label: 'Ремонты',
            isActive: currentPath == '/repairs',
            onTap: () => _navigateTo(context, '/repairs'),
          ),
          _NavButton(
            icon: Icons.inventory_2,
            label: 'Склад',
            isActive: currentPath == '/materials',
            onTap: () => _navigateTo(context, '/materials'),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
