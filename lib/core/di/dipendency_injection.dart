import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sukun/features/home/data/datasources/home_local_calculation_data_source.dart';
import 'package:sukun/features/home/presentation/controller/cubit/home_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sukun/core/services/location_service.dart';
import 'package:sukun/core/services/silence_service.dart';
import 'package:sukun/core/services/background_alarm_service.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/prayer_repository_impl.dart';
import '../../features/home/domain/repositories/prayer_repository.dart';
import '../../features/home/domain/usecases/get_prayer_times_usecase.dart';
import 'package:sukun/core/services/workmanager_service.dart';
import 'package:sukun/core/services/alarm_scheduler_service.dart';
import '../local_data/shared_preferences.dart';
import '../local_data/daos/prayer_times_dao.dart';
import '../local_data/daos/locations_dao.dart';
import '../local_data/daos/user_settings_dao.dart';
import '../networking/base_repository.dart';
import '../networking/network_info.dart';

GetIt getIt = GetIt.instance;

Future initApp() async {
  // Initialize Android Alarm Manager
  await AlarmSchedulerService.init();

  // Initialize WorkManager
  await WorkManagerService.init();

  // Get shared preferences instance
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // Create connection checker instance
  InternetConnectionChecker connectionChecker =
      InternetConnectionChecker.createInstance();

  // Register AppPreferences class as a lazy singleton class
  getIt.registerLazySingleton<AppPreferences>(
    () => AppPreferences(sharedPreferences),
  );

  // Register network info class as a lazy singleton class
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker),
  );

  // Register BaseRepository class as a lazy singleton class
  getIt.registerLazySingleton<BaseRepository>(
    () => BaseRepository(
      networkInfo: getIt<NetworkInfo>(),
      appPreferences: getIt<AppPreferences>()..init(),
    ),
  );

  // DAOs
  getIt.registerLazySingleton<PrayerTimesDao>(() => PrayerTimesDao());
  getIt.registerLazySingleton<LocationsDao>(() => LocationsDao());
  getIt.registerLazySingleton<UserSettingsDao>(() => UserSettingsDao());

  // --- Home Feature ---

  // Data sources
  getIt.registerLazySingleton<HomeLocalCalculationDataSource>(
    () => HomeLocalCalculationDataSourceImpl(),
  );
  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(prayerTimesDao: getIt<PrayerTimesDao>()),
  );

  // Repository
  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(
      calculationDataSource: getIt<HomeLocalCalculationDataSource>(),
      localDataSource: getIt<HomeLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      appPreferences: getIt<AppPreferences>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<SilenceService>(() => SilenceService());
  getIt.registerLazySingleton<BackgroundAlarmService>(
    () => BackgroundAlarmService(),
  );
  getIt.registerLazySingleton<AlarmSchedulerService>(
    () => AlarmSchedulerService(
      prayerTimesDao: getIt<PrayerTimesDao>(),
      appPreferences: getIt<AppPreferences>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton<GetPrayerTimesUseCase>(
    () => GetPrayerTimesUseCase(getIt<PrayerRepository>()),
  );

  // Blocs/Cubits
  getIt.registerFactory(
    () => HomeCubit(
      getPrayerTimesUseCase: getIt<GetPrayerTimesUseCase>(),
      locationService: getIt<LocationService>(),
      silenceService: getIt<SilenceService>(),
      backgroundAlarmService: getIt<BackgroundAlarmService>(),
      appPreferences: getIt<AppPreferences>(),
      locationsDao: getIt<LocationsDao>(),
      userSettingsDao: getIt<UserSettingsDao>(),
    ),
  );
}
