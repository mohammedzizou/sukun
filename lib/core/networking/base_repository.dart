import 'package:dio/dio.dart';
import '../local_data/shared_preferences.dart';
import 'dio_factory.dart';
import 'network_info.dart';

class BaseRepository {
  final Dio client = DioFactory().getDio();
  final NetworkInfo networkInfo;
  final AppPreferences appPreferences;

  BaseRepository({required this.networkInfo, required this.appPreferences});
}
