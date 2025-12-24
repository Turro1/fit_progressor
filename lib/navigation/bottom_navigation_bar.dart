import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../core/theme/app_colors.dart'; // Removed direct import

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentPath;

  const CustomBottomNavigationBar({Key? key, required this.currentPath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Changed from AppColors.bgHeader
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ), // Changed from AppColors.borderColor
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000), // Using a standard subtle shadow color
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
            onTap: () => context.go('/dashboard'),
          ),
          _NavButton(
            icon: Icons.groups_rounded,
            label: 'Клиенты',
            isActive: currentPath == '/clients',
            onTap: () => context.go('/clients'),
          ),
          _NavButton(
            icon: Icons.directions_car_rounded,
            label: 'Авто',
            isActive: currentPath == '/cars',
            onTap: () => context.go('/cars'),
          ),
          _NavButton(
            icon: Icons.build_circle_rounded,
            label: 'Ремонты',
            isActive: currentPath == '/repairs',
            onTap: () => context.go('/repairs'),
          ),
          _NavButton(
            icon: Icons.inventory_2,
            label: 'Склад',
            isActive: currentPath == '/materials',
            onTap: () => context.go('/materials'),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Use theme colors
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? theme
                        .colorScheme
                        .secondary // Use theme colors
                  : theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ), // Use theme colors
            ),
          ),
        ],
      ),
    );
  }
}
