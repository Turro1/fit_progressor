import 'package:fit_progressor/features/cars/data/datasources/car_library_local_data_source.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_library_local_data_source_shared_preferences_impl.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source_shared_preferences_impl.dart';
import 'package:fit_progressor/features/cars/data/repositories/car_library_repository_impl.dart';
import 'package:fit_progressor/features/cars/data/repositories/car_repository_impl.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/cars/domain/usecases/add_car.dart';
import 'package:fit_progressor/features/cars/domain/usecases/delete_car.dart';
import 'package:fit_progressor/features/cars/domain/usecases/get_car_makes.dart';
import 'package:fit_progressor/features/cars/domain/usecases/get_car_models.dart';
import 'package:fit_progressor/features/cars/domain/usecases/get_cars.dart';
import 'package:fit_progressor/features/cars/domain/usecases/get_cars_by_client.dart';
import 'package:fit_progressor/features/cars/domain/usecases/search_cars.dart';
import 'package:fit_progressor/features/cars/domain/usecases/update_car.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source_shared_preferences_impl.dart';
import 'package:fit_progressor/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:fit_progressor/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fit_progressor/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:fit_progressor/features/dashboard/presentation/bloc/dashboard_bloc.dart';

// REPAIRS IMPORTS START
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource_shared_preference_impl.dart';
import 'package:fit_progressor/features/repairs/data/repositories/repair_repository_impl.dart';
import 'package:fit_progressor/features/repairs/data/services/repair_image_service.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/add_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/delete_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repair_by_id.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/search_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/update_repair.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
// REPAIRS IMPORTS END

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features - Materials
import 'features/materials/data/datasources/material_local_data_source.dart';
import 'features/materials/data/datasources/material_local_data_source_shared_preferences_impl.dart';
import 'features/materials/data/repositories/material_repository_impl.dart';
import 'features/materials/domain/repositories/material_repository.dart';
import 'features/materials/domain/usecases/add_material.dart';
import 'features/materials/domain/usecases/delete_material.dart';
import 'features/materials/domain/usecases/get_materials.dart';
import 'features/materials/domain/usecases/search_materials.dart';
import 'features/materials/domain/usecases/update_material.dart';
import 'features/materials/presentation/bloc/material_bloc.dart';

// Features - Clients
import 'features/clients/data/repositories/client_repository_impl.dart';
import 'features/clients/domain/repositories/client_repository.dart';
import 'features/clients/domain/usecases/add_client.dart';
import 'features/clients/domain/usecases/delete_client.dart';
import 'features/clients/domain/usecases/get_clients.dart';
import 'features/clients/domain/usecases/search_clients.dart';
import 'features/clients/domain/usecases/update_client.dart';
import 'features/clients/presentation/bloc/client_bloc.dart';

// Features - Cars

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================
  // Features - Dashboard
  // ============================================

  // Bloc
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardStats: sl(),
      getRepairs: sl(),
      getClients: sl(),
      getCars: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardStats(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      repairRepository: sl(),
      materialRepository: sl(),
    ),
  );
  // ============================================
  // Features - Clients
  // ============================================

  // Bloc
  sl.registerFactory(
    () => ClientBloc(
      getClients: sl(),
      addClient: sl(),
      updateClient: sl(),
      deleteClient: sl(),
      searchClients: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetClients(sl(), sl()));
  sl.registerLazySingleton(() => AddClient(sl()));
  sl.registerLazySingleton(() => UpdateClient(sl()));
  sl.registerLazySingleton(() => DeleteClient(sl(), sl(), sl()));
  sl.registerLazySingleton(() => SearchClients(sl()));

  // Repository (with lazy dependency resolution to avoid circular dependency)
  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ClientLocalDataSource>(
    () => ClientLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );

  // ============================================
  // Features - Cars
  // ============================================

  // Bloc
  sl.registerFactory(
    () => CarBloc(
      getCars: sl(),
      addCar: sl(),
      updateCar: sl(),
      deleteCar: sl(),
      searchCars: sl(),
      getCarMakes: sl(),
      getCarModels: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCars(sl(), sl()));
  sl.registerLazySingleton(() => AddCar(sl(), sl()));
  sl.registerLazySingleton(() => UpdateCar(sl(), sl()));
  sl.registerLazySingleton(() => DeleteCar(sl(), sl()));
  sl.registerLazySingleton(() => SearchCars(sl(), sl()));
  sl.registerLazySingleton(() => GetCarMakes(sl()));
  sl.registerLazySingleton(() => GetCarModels(sl()));
  sl.registerLazySingleton(() => GetCarsByClient(sl()));

  // Repository (with lazy dependency resolution to avoid circular dependency)
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CarLibraryRepository>(
    () => CarLibraryRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CarLocalDataSource>(
    () => CarLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<CarLibraryLocalDataSource>(
    () =>
        CarLibraryLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );

  // ============================================
  // Features - Repairs
  // ============================================

  // Bloc
  sl.registerFactory(
    () => RepairsBloc(
      getRepairs: sl(),
      addRepair: sl(),
      updateRepair: sl(),
      deleteRepair: sl(),
      searchRepairs: sl(),
      imageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRepairs(sl()));
  sl.registerLazySingleton(() => GetRepairById(sl()));
  sl.registerLazySingleton(() => AddRepair(repairRepository: sl()));
  sl.registerLazySingleton(() => UpdateRepair(repairRepository: sl()));
  sl.registerLazySingleton(
    () => DeleteRepair(
      repairRepository: sl(),
      getRepairById: sl(),
      imageService: sl(),
    ),
  );
  sl.registerLazySingleton(() => SearchRepairs(sl()));

  // Services
  sl.registerLazySingleton<RepairImageService>(() => RepairImageService());

  // Repository
  sl.registerLazySingleton<RepairRepository>(
    () => RepairRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RepairLocalDataSource>(
    () => RepairLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ============================================
  // Features - Materials
  // ============================================

  // Bloc
  sl.registerFactory(
    () => MaterialBloc(
      getMaterials: sl(),
      addMaterial: sl(),
      updateMaterial: sl(),
      deleteMaterial: sl(),
      searchMaterials: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMaterials(sl()));
  sl.registerLazySingleton(() => AddMaterial(sl()));
  sl.registerLazySingleton(() => UpdateMaterial(sl()));
  sl.registerLazySingleton(() => DeleteMaterial(sl()));
  sl.registerLazySingleton(() => SearchMaterials(sl()));

  // Repository
  sl.registerLazySingleton<MaterialRepository>(
    () => MaterialRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MaterialLocalDataSource>(
    () => MaterialLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );

  // ============================================
  // Core
  // ============================================

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
