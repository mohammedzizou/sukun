import 'package:dio/dio.dart';
import '../local_data/shared_preferences.dart';
import 'dio_factory.dart';
import 'network_info.dart';

/// A utility class that provides essential dependencies required by all repositories.
///
/// This class [BaseRepository] centralizes the common dependencies that are needed across
/// multiple repositories, promoting reusability and simplifying dependency management.
/// By using this class, you can easily inject the necessary services into any
/// repository, ensuring consistency and reducing boilerplate code.
///
/// ### Dependencies:
/// - `Dio client`: A Dio instance used for making HTTP requests.
/// - `NetworkInfo networkInfo`: A utility that checks the current network status
/// - `AppPreferences appPreferences`: A class that handles app-specific preferences
///   and settings, often used for storing and retrieving persistent data.
///
/// ### Example Usage:
/// i add this class into Dependency Injection file [dependency_injection.dart] as a lazy singleton class
/// use it like this in any repository class:
/// final BaseRepository _baseRepository =  getIt<BaseRepository>();

class BaseRepository {
  final Dio client = DioFactory().getDio();
  final NetworkInfo networkInfo;
  final AppPreferences appPreferences;

  BaseRepository({required this.networkInfo, required this.appPreferences});
}
