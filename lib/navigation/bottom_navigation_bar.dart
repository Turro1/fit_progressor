import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentPath;

  const CustomBottomNavigationBar({Key? key, required this.currentPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavButton(
            icon: Icons.dashboard,
            label: 'Сводка',
            isActive: currentPath == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          _NavButton(
            icon: Icons.groups,
            label: 'Клиенты',
            isActive: currentPath == '/clients',
            onTap: () => context.go('/clients'),
          ),
          _NavButton(
            icon: Icons.directions_car,
            label: 'Авто',
            isActive: currentPath == '/cars',
            onTap: () => context.go('/cars'),
          ),
          _NavButton(
            icon: Icons.build,
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
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}