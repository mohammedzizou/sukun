
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local_data/shared_preferences.dart';
import '../networking/base_repository.dart';
import '../networking/network_info.dart';

GetIt getIt = GetIt.instance;

Future initApp() async {

  // Get shared preferences instance
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // Create connection checker instance
  InternetConnectionChecker connectionChecker =
      InternetConnectionChecker.createInstance();

  // Register AppPreferences class as a lazy singleton class
  getIt.registerLazySingleton<AppPreferences>(
      () => AppPreferences(sharedPreferences));

  // Register network info class as a lazy singleton class
  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectionChecker));

  // Register BaseRepository class as a lazy singleton class
  getIt.registerLazySingleton<BaseRepository>(() => BaseRepository(
      networkInfo: getIt<NetworkInfo>(),
      appPreferences: getIt<AppPreferences>()..init()));

 
}
