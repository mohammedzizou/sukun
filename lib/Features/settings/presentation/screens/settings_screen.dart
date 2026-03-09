import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sukun/features/settings/presentation/cubit/settings_state.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_dropdown_row.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_section.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_switch_row.dart';
import 'package:sukun/features/settings/presentation/widgets/profile_header_card.dart';
import 'package:sukun/features/settings/presentation/widgets/profile_action_row.dart';
import 'package:sukun/features/settings/presentation/widgets/profile_appearance_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your profile and application preferences',
                      style: TextStyle(
                        color: Color(0x7FA3F7BF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 1. Profile Header Section
                    ProfileHeaderCard(
                      city: state.city,
                      country: state.country,
                      isAutoLocation: state.autoDetectLocation,
                    ),
                    const SizedBox(height: 24),

                    // 2. Appearance Section
                    SettingsSection(
                      title: 'APPEARANCE',
                      icon: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.activeGreen,
                        size: 14,
                      ),
                      children: [
                        const SizedBox(height: 8),
                        ProfileAppearanceSelector(
                          isDarkMode: state.themeMode == 'Dark',
                          onModeChanged: (isDark) {
                            _cubit.setThemeMode(isDark ? 'Dark' : 'Light');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. General Settings Section
                    SettingsSection(
                      title: 'GENERAL',
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.activeGreen,
                        size: 14,
                      ),
                      children: [
                        SettingsDropdownRow(
                          title: 'Language',
                          subtitle: 'Application display language',
                          value: state.language,
                          options: const ['English', 'Arabic', 'French'],
                          onChanged: (val) => _cubit.setLanguage(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. Prayer Silence Behavior Section
                    SettingsSection(
                      title: 'PRAYER SILENCE BEHAVIOR',
                      icon: const Icon(
                        Icons.volume_up_outlined,
                        color: AppColors.activeGreen,
                        size: 14,
                      ),
                      children: [
                        SettingsSwitchRow(
                          title: 'Restore previous sound mode',
                          subtitle:
                              'Return to your ringtone level after prayer',
                          value: state.restoreSound,
                          onChanged: (val) => _cubit.setRestoreSound(val),
                        ),
                        SettingsSwitchRow(
                          title: 'Vibrate instead of silent',
                          subtitle: 'Phone will vibrate during prayer',
                          value: state.vibrateInstead,
                          onChanged: (val) => _cubit.setVibrateInstead(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 5. Calculation Section
                    SettingsSection(
                      title: 'LOCATION & CALCULATION',
                      icon: SvgPicture.asset(
                        AppIcons.mapPin,
                        width: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.activeGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                      children: [
                        SettingsDropdownRow(
                          title: 'Calculation method',
                          subtitle: 'Used to determine prayer times',
                          value: state.calculationMethod,
                          options: const [
                            'Muslim World League',
                            'Islamic Society of North America',
                            'Egyptian General Authority',
                            'Umm Al-Qura, Makkah',
                            'University of Islamic Sciences, Karachi',
                          ],
                          onChanged: (val) => _cubit.setCalculationMethod(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6. About Section
                    SettingsSection(
                      title: 'ABOUT',
                      icon: const Icon(
                        Icons.info_outline,
                        color: AppColors.activeGreen,
                        size: 14,
                      ),
                      children: [
                        ProfileActionRow(
                          icon: const Icon(
                            Icons.help_outline,
                            color: AppColors.activeGreen,
                            size: 17,
                          ),
                          title: 'About Salah Silent',
                          subtitle: 'Version 1.0.0',
                          onTap: () {},
                        ),
                        ProfileActionRow(
                          icon: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.activeGreen,
                            size: 17,
                          ),
                          title: 'Privacy Policy',
                          showDivider: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Center(
                      child: Text(
                        'Salah Silent v1.0.0 · Made with ☪ for the Ummah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0x33A3F7BF),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64), // Extra bottom padding
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
