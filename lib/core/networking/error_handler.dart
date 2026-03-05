// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'faileur.dart';

class ErrorHandler implements Exception {
  late Faileur faileur;
  ErrorHandler.handle(dynamic error, {bool requestOptions = true}) {
    if (error is DioException) {
      faileur = _getFaileurError(error);
    } else {
      faileur = DataSource.DEFAULT.getFaileur();
    }
  }
}

Faileur _getFaileurError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.RECIEVE_TIMEOUT.getFaileur();
    case DioExceptionType.sendTimeout:
      return DataSource.SEND_TIMEOUT.getFaileur();
    case DioExceptionType.receiveTimeout:
      return DataSource.RECIEVE_TIMEOUT.getFaileur();
    case DioExceptionType.badResponse:
      return _decodeError(error);
    case DioExceptionType.cancel:
      return DataSource.CANCELED.getFaileur();
    case DioExceptionType.unknown:
      return DataSource.DEFAULT.getFaileur();
    case DioExceptionType.badCertificate:
      return DataSource.BAD_REQUEST.getFaileur();
    case DioExceptionType.connectionError:
      return DataSource.NO_CONNECTION_INTERNET.getFaileur();
  }
}

Faileur _decodeError(DioException error) {
  if (error.response != null &&
      error.response?.statusMessage != null &&
      error.response?.statusCode != null) {
    log("${error.response?.data}");
    return Faileur(
      error.response!.statusCode!,
      error.response?.data["error"] ?? ResponseMessage.DEFAULT,
    );
  } else {
    return DataSource.DEFAULT.getFaileur();
  }
}

enum DataSource {
  NO_CONTENT,
  BAD_REQUEST,
  UNAUTHORIZED,
  FORBIDDEN,
  INTERNAL_SERVER_ERROR,
  RECIEVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHED_ERROR,
  CANCELED,
  NO_CONNECTION_INTERNET,
  DEFAULT,
}

class ResponseMessage {
  static String NO_CONTENT = "450".tr;
  static String BAD_REQUEST = "440".tr;
  static String UNAUTHORIZED = "441".tr;
  static String FORBIDDEN = "442".tr;
  static String INTERNAL_SERVER_ERROR = "443".tr;
  static String RECIEVE_TIMEOUT = "444".tr;
  static String SEND_TIMEOUT = "445".tr;
  static String CACHED_ERROR = "446".tr;
  static String CANCELED = "447".tr;
  static String NO_CONNECTION_INTERNET = "448".tr;
  static String DEFAULT = "449".tr;
}

class ResponseCode {
  static const int NO_CONTENT = 201;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 405;
  static const int FORBIDDEN = 406;
  static const int INTERNAL_SERVER_ERROR = 500;
  static const int RECIEVE_TIMEOUT = -1;
  static const int SEND_TIMEOUT = -2;
  static const int CACHED_ERROR = -3;
  static const int CANCELED = -4;
  static const int NO_CONNECTION_INTERNET = -5;
  static const int DEFAULT = -6;
}

extension DataSourceExtention on DataSource {
  Faileur getFaileur() {
    switch (this) {
      case DataSource.NO_CONTENT:
        return Faileur(ResponseCode.NO_CONTENT, ResponseMessage.NO_CONTENT);
      case DataSource.BAD_REQUEST:
        return Faileur(ResponseCode.BAD_REQUEST, ResponseMessage.BAD_REQUEST);
      case DataSource.UNAUTHORIZED:
        return Faileur(ResponseCode.UNAUTHORIZED, ResponseMessage.UNAUTHORIZED);
      case DataSource.FORBIDDEN:
        return Faileur(ResponseCode.FORBIDDEN, ResponseMessage.FORBIDDEN);
      case DataSource.INTERNAL_SERVER_ERROR:
        return Faileur(
          ResponseCode.INTERNAL_SERVER_ERROR,
          ResponseMessage.INTERNAL_SERVER_ERROR,
        );
      case DataSource.RECIEVE_TIMEOUT:
        return Faileur(
          ResponseCode.RECIEVE_TIMEOUT,
          ResponseMessage.RECIEVE_TIMEOUT,
        );
      case DataSource.SEND_TIMEOUT:
        return Faileur(ResponseCode.SEND_TIMEOUT, ResponseMessage.SEND_TIMEOUT);
      case DataSource.CACHED_ERROR:
        return Faileur(ResponseCode.CACHED_ERROR, ResponseMessage.CACHED_ERROR);
      case DataSource.CANCELED:
        return Faileur(ResponseCode.CANCELED, ResponseMessage.CANCELED);
      case DataSource.NO_CONNECTION_INTERNET:
        return Faileur(
          ResponseCode.NO_CONNECTION_INTERNET,
          ResponseMessage.NO_CONNECTION_INTERNET,
        );
      case DataSource.DEFAULT:
        return Faileur(ResponseCode.DEFAULT, ResponseMessage.DEFAULT);
    }
  }
}
