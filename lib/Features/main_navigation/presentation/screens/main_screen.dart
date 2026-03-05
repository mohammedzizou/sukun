import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prayer_silence_time_app/core/widgets/app_background.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/main_navigation/presentation/cubit/main_navigation_cubit.dart';
import 'package:prayer_silence_time_app/features/main_navigation/presentation/cubit/main_navigation_state.dart';
import 'package:prayer_silence_time_app/features/home/presentation/screens/home_screen.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:prayer_silence_time_app/features/settings/presentation/screens/settings_screen.dart';

// Placeholder screens for now
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainNavigationCubit(),
      child: BlocBuilder<MainNavigationCubit, MainNavigationState>(
        builder: (context, state) {
          final List<Widget> pages = [
            const HomeScreen(),
            const ScheduleScreen(),
            const QiblaScreen(),
            const SettingsScreen(),
            const PlaceholderScreen(title: 'Profile'),
          ];
          return Scaffold(
            body: AppBackground(
              child: IndexedStack(index: state.selectedIndex, children: pages),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.selectedIndex,
              onTap: (index) =>
                  context.read<MainNavigationCubit>().changeIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.backgroundBottom,
              selectedItemColor: AppColors.primaryGreen,
              unselectedItemColor: AppColors.mint35,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcons.home,
                    colorFilter: const ColorFilter.mode(
                      AppColors.mint35,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    AppIcons.homeActive,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcons.schedule,
                    colorFilter: const ColorFilter.mode(
                      AppColors.mint35,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    AppIcons.scheduleActive,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcons.qibla,
                    colorFilter: const ColorFilter.mode(
                      AppColors.mint35,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    AppIcons.qiblaActive,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  label: 'Qibla',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcons.settings,
                    colorFilter: const ColorFilter.mode(
                      AppColors.mint35,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    AppIcons.settingsActive,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  label: 'Settings',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AppIcons.profile,
                    colorFilter: const ColorFilter.mode(
                      AppColors.mint35,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    AppIcons.profileActive,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
