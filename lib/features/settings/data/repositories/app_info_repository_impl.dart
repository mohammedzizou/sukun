import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sukun/core/networking/faileur.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_info_repository.dart';

class AppInfoRepositoryImpl implements AppInfoRepository {
  @override
  Future<Either<Faileur, AppInfo>> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return Right(
        AppInfo(
          appName: packageInfo.appName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          packageName: packageInfo.packageName,
        ),
      );
    } catch (e) {
      return Left(Faileur(500, e.toString()));
    }
  }
}
