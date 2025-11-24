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
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_data_source_shared_preference_impl.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/repositories/repair_repository_impl.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/add_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/delete_repair.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/filter_repairs_by_status.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/get_repairs_by_car.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/search_repairs.dart';
import 'package:fit_progressor/features/repairs/domain/usecases/update_repair.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  sl.registerLazySingleton(() => GetClients(sl()));
  sl.registerLazySingleton(() => AddClient(sl()));
  sl.registerLazySingleton(() => UpdateClient(sl()));
  sl.registerLazySingleton(() => DeleteClient(sl()));
  sl.registerLazySingleton(() => SearchClients(sl()));

  // Repository
  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(localDataSource: sl()),
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
  sl.registerLazySingleton(() => GetCars(sl()));
  sl.registerLazySingleton(() => AddCar(sl(), sl()));
  sl.registerLazySingleton(() => UpdateCar(sl(), sl()));
  sl.registerLazySingleton(() => DeleteCar(sl()));
  sl.registerLazySingleton(() => SearchCars(sl()));
  sl.registerLazySingleton(() => GetCarMakes(sl()));
  sl.registerLazySingleton(() => GetCarModels(sl()));
  sl.registerLazySingleton(() => GetCarsByClient(sl()));

  // Repository
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CarLibraryRepository>(
    () => CarLibraryRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CarLocalDataSource>(
    () => CarLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );
   sl.registerLazySingleton<CarLibraryLocalDataSource>(
    () => CarLibraryLocalDataSourceSharedPreferencesImpl(sharedPreferences: sl()),
  );

  // ============================================
  // Features - Repairs
  // ============================================

  // Bloc
  sl.registerFactory(
    () => RepairBloc(
      getRepairs: sl(), 
      addRepair: sl(), 
      updateRepair: sl(), 
      deleteRepair: sl(), 
      searchRepairs: sl(), 
      filterRepairsByStatus: sl()
 
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRepairs(sl()));
  sl.registerLazySingleton(() => AddRepair(sl()));
  sl.registerLazySingleton(() => UpdateRepair(sl()));
  sl.registerLazySingleton(() => DeleteRepair(sl()));
  sl.registerLazySingleton(() => SearchRepairs(sl()));
  sl.registerLazySingleton(() => GetRepairsByCar(sl()));
  sl.registerLazySingleton(() => FilterRepairsByStatus(sl()));

  // Repository
  sl.registerLazySingleton<RepairRepository>(
    () => RepairRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RepairLocalDataSource>(
    () => RepairLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // ============================================
  // Core
  // ============================================
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}