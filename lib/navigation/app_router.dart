import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/pages/cars_page.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_bloc.dart';
import 'package:fit_progressor/features/materials/presentation/pages/materials_page.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/pages/repairs_page.dart';
import 'package:fit_progressor/features/repairs/presentation/pages/car_repairs_page.dart'; // Added this import
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
            create: (context) => sl<RepairBloc>(),
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
            routes: [ // Nested route for car repairs
              GoRoute(
                path: ':carId/repairs',
                pageBuilder: (context, state) {
                  final carId = state.pathParameters['carId'];
                  return NoTransitionPage(
                    child: CarRepairsPage(carId: carId!), // CarRepairsPage needs to be created
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/repairs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RepairsPage(),
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
        ],
      ),
    ],
  );
}
