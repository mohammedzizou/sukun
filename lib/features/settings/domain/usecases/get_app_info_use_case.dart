import 'package:dartz/dartz.dart';
import '../../../../core/networking/faileur.dart';
import '../entities/app_info.dart';
import '../repositories/app_info_repository.dart';

class GetAppInfoUseCase {
  final AppInfoRepository repository;

  GetAppInfoUseCase(this.repository);

  Future<Either<Faileur, AppInfo>> call() async {
    return await repository.getAppInfo();
  }
}
