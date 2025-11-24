import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/clients/presentation/bloc/client_bloc.dart';
import 'features/clients/presentation/bloc/client_event.dart';
import 'injection_container.dart' as di;
import 'navigation/app_router.dart';

class RepairManagerApp extends StatelessWidget {
  const RepairManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<ClientBloc>()..add(LoadClients()),
        ),
        BlocProvider(
          create: (_) => di.sl<CarBloc>()..add(LoadCars()),
        ),
         BlocProvider(
          create: (_) => di.sl<RepairBloc>()..add((LoadRepairs())),
        ),
        
        // TODO: Add other BLoCs here when ready
        // BlocProvider(create: (_) => di.sl<RepairBloc>()..add(LoadRepairs())),
        // BlocProvider(create: (_) => di.sl<MaterialBloc>()..add(LoadMaterials())),
        // BlocProvider(create: (_) => di.sl<DashboardBloc>()..add(LoadDashboard())),
      ],
      child: MaterialApp.router(
        title: 'RepairManager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}