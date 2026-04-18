import 'package:equatable/equatable.dart';
import '../../domain/entities/app_info.dart';

abstract class AboutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AboutInitial extends AboutState {}

class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  final AppInfo appInfo;
  AboutLoaded(this.appInfo);

  @override
  List<Object?> get props => [appInfo];
}

class AboutError extends AboutState {
  final String message;
  AboutError(this.message);

  @override
  List<Object?> get props => [message];
}
