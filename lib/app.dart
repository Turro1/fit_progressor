import 'package:fit_progressor/core/theme/theme_cubit.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_bloc.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_event.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/clients/presentation/bloc/client_bloc.dart';
import 'features/clients/presentation/bloc/client_event.dart';
import 'injection_container.dart' as di;
import 'navigation/app_router.dart';

class FitProgressorApp extends StatefulWidget {
  const FitProgressorApp({super.key});

  @override
  State<FitProgressorApp> createState() => _FitProgressorAppState();
}

class _FitProgressorAppState extends State<FitProgressorApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<ClientBloc>()..add(LoadClients())),
        BlocProvider(create: (_) => di.sl<CarBloc>()..add(LoadCars())),
        BlocProvider(
          create: (_) => di.sl<MaterialBloc>()..add((LoadMaterials())),
        ),
        BlocProvider(
          create: (_) => di.sl<DashboardBloc>()..add((LoadDashboard())),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'FitProgressor',
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
