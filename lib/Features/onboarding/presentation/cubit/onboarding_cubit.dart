import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void nextPage() {
    if (state < 2) emit(state + 1);
  }

  void goToPage(int index) {
    if (index >= 0 && index <= 2) emit(index);
  }
}
