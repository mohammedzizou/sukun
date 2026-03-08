// ignore_for_file: constant_identifier_names
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sukun/core/constants/linkapi.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';

class DioFactory {
  Dio getDio() {
    final dio = Dio();
    dio.options = BaseOptions(
        // headers: header,
        baseUrl: AppLink.server,
        receiveTimeout: const Duration(minutes: 1),
        connectTimeout: const Duration(minutes: 1));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          AppPreferences appPreferences = getIt<AppPreferences>();
          if (error.response?.statusCode == 401 &&
              appPreferences.getAccessToken().isNotEmpty) {
            log('Received 401. Attempting to refresh access token...');
          }
          return handler.next(error);
        },
      ),
    );
    return dio;
  }
}
