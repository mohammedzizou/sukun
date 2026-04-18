import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_app_info_use_case.dart';
import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  final GetAppInfoUseCase getAppInfoUseCase;

  AboutCubit({required this.getAppInfoUseCase}) : super(AboutInitial());

  Future<void> loadAppInfo() async {
    emit(AboutLoading());
    final result = await getAppInfoUseCase();
    result.fold(
      (failure) => emit(AboutError(failure.message)),
      (appInfo) => emit(AboutLoaded(appInfo)),
    );
  }
}
