import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  @override
  List<Object?> get props => [appName, version, buildNumber, packageName];
}
