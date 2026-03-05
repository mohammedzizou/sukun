import 'package:equatable/equatable.dart';

class MainNavigationState extends Equatable {
  final int selectedIndex;

  const MainNavigationState({required this.selectedIndex});

  @override
  List<Object> get props => [selectedIndex];
}
