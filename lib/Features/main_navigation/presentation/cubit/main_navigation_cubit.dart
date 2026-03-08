import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukun/features/main_navigation/presentation/cubit/main_navigation_state.dart';

class MainNavigationCubit extends Cubit<MainNavigationState> {
  MainNavigationCubit() : super(const MainNavigationState(selectedIndex: 0));

  void changeIndex(int index) {
    emit(MainNavigationState(selectedIndex: index));
  }
}
