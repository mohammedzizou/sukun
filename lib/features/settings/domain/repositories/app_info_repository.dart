import 'package:dartz/dartz.dart';
import 'package:sukun/core/networking/faileur.dart';
import '../entities/app_info.dart';

abstract class AppInfoRepository {
  Future<Either<Faileur, AppInfo>> getAppInfo();
}
