import 'package:fit_progressor/features/cars/presentation/pages/cars_page.dart';
import 'package:fit_progressor/features/repairs/presentation/pages/repairs_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/clients/presentation/pages/clients_page.dart';
import 'main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(
                child: Text(
                  'Dashboard Page - TODO',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClientsPage(),
            ),
          ),
          GoRoute(
            path: '/cars',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CarsPage(),
            ),
          ),
          GoRoute(
            path: '/repairs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RepairsPage(),
            ),
          ),
          GoRoute(
            path: '/materials',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(
                child: Text(
                  'Materials Page - TODO',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}