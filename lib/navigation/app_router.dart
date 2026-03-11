import 'package:car_repair_manager/features/cars/presentation/bloc/car_bloc.dart';
import 'package:car_repair_manager/features/cars/presentation/pages/cars_page.dart';
import 'package:car_repair_manager/features/clients/presentation/bloc/client_bloc.dart';
import 'package:car_repair_manager/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:car_repair_manager/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:car_repair_manager/features/materials/presentation/bloc/material_bloc.dart';
import 'package:car_repair_manager/features/materials/presentation/pages/materials_page.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:car_repair_manager/features/repairs/presentation/pages/repairs_page.dart';
import 'package:car_repair_manager/features/settings/presentation/pages/settings_page.dart';
import 'package:car_repair_manager/features/settings/presentation/pages/sync_settings_page.dart';
import 'package:car_repair_manager/injection_container.dart';
import 'package:car_repair_manager/navigation/page_transitions.dart';
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
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => sl<DashboardBloc>(),
                child: const DashboardPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => sl<ClientBloc>(),
                child: const ClientsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/cars',
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => sl<CarBloc>(),
                child: const CarsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/repairs',
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => sl<RepairsBloc>(),
                child: const RepairsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/materials',
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => sl<MaterialBloc>(),
                child: const MaterialsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => FadeThroughPage(
              key: state.pageKey,
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
                pageBuilder: (context, state) => SharedAxisPage(
                  key: state.pageKey,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: const SyncSettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
