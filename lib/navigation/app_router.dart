import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/pages/cars_page.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_bloc.dart';
import 'package:fit_progressor/features/materials/presentation/pages/materials_page.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/pages/repairs_page.dart';
import 'package:fit_progressor/features/settings/presentation/pages/settings_page.dart';
import 'package:fit_progressor/features/settings/presentation/pages/sync_settings_page.dart';
import 'package:fit_progressor/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/clients/presentation/pages/clients_page.dart';
import 'main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => sl<RepairsBloc>(),
            child: MainScaffold(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => sl<DashboardBloc>(),
                child: const DashboardPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => sl<ClientBloc>(),
                child: const ClientsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/cars',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => sl<CarBloc>(),
                child: const CarsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/repairs',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => sl<RepairsBloc>(),
                child: const RepairsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/materials',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => sl<MaterialBloc>(),
                child: const MaterialsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => sl<ClientBloc>()),
                  BlocProvider(create: (context) => sl<CarBloc>()),
                ],
                child: const SettingsPage(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'sync',
                builder: (context, state) => const SyncSettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
