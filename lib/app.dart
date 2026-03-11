import 'package:car_repair_manager/core/theme/theme_cubit.dart';
import 'package:car_repair_manager/core/sync/bloc/sync_bloc.dart';
import 'package:car_repair_manager/core/sync/bloc/sync_event.dart';
import 'package:car_repair_manager/features/cars/presentation/bloc/car_bloc.dart';
import 'package:car_repair_manager/features/cars/presentation/bloc/car_event.dart';
import 'package:car_repair_manager/features/materials/presentation/bloc/material_bloc.dart';
import 'package:car_repair_manager/features/materials/presentation/bloc/material_event.dart';
import 'package:car_repair_manager/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:car_repair_manager/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/clients/presentation/bloc/client_bloc.dart';
import 'features/clients/presentation/bloc/client_event.dart';
import 'injection_container.dart' as di;
import 'navigation/app_router.dart';

class CarRepairManagerApp extends StatefulWidget {
  const CarRepairManagerApp({super.key});

  @override
  State<CarRepairManagerApp> createState() => _CarRepairManagerAppState();
}

class _CarRepairManagerAppState extends State<CarRepairManagerApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<SyncBloc>()..add(const SyncInitialize())),
        BlocProvider(create: (_) => di.sl<ClientBloc>()..add(LoadClients())),
        BlocProvider(create: (_) => di.sl<CarBloc>()..add(const LoadCars())),
        BlocProvider(
          create: (_) => di.sl<MaterialBloc>()..add((const LoadMaterials())),
        ),
        BlocProvider(
          create: (_) => di.sl<DashboardBloc>()..add((LoadDashboard())),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'CarRepairManager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.resolvedThemeMode,
            routerConfig: AppRouter.router,
            locale: const Locale('ru', 'RU'),
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
