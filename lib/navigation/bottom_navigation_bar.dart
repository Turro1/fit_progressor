import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';

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
          // Ремонты с badge
          BlocBuilder<RepairsBloc, RepairsState>(
            builder: (context, state) {
              int inProgressCount = 0;
              if (state is RepairsLoaded) {
                inProgressCount = state.allRepairs
                    .where((r) => r.status == RepairStatus.inProgress)
                    .length;
              }

              return _NavButton(
                icon: Icons.build_circle_rounded,
                label: 'Ремонты',
                isActive: currentPath == '/repairs',
                onTap: () => _navigateTo(context, '/repairs'),
                badgeCount: inProgressCount,
              );
            },
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
  final int badgeCount;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: iconColor),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : badgeCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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
