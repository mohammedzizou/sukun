import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sukun/features/settings/presentation/cubit/settings_state.dart';
import 'package:sukun/features/settings/presentation/screens/prayer_adjustments_screen.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_dropdown_row.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_section.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_switch_row.dart';
import 'package:sukun/features/settings/presentation/widgets/profile_header_card.dart';
import 'package:sukun/features/settings/presentation/widgets/profile_action_row.dart';
import 'package:sukun/features/settings/presentation/screens/about_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sukun/features/settings/presentation/cubit/about_cubit.dart';

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
                    Text(
                      'Settings'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your profile and application preferences'.tr,
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
                    // SettingsSection(
                    //   title: 'APPEARANCE'.tr,
                    //   icon: const Icon(
                    //     Icons.palette_outlined,
                    //     color: AppColors.activeGreen,
                    //     size: 14,
                    //   ),
                    //   children: [
                    //     const SizedBox(height: 8),
                    //     ProfileAppearanceSelector(
                    //       isDarkMode: state.themeMode == 'Dark',
                    //       onModeChanged: (isDark) {
                    //         _cubit.setThemeMode(isDark ? 'Dark' : 'Light');
                    //       },
                    //     ),
                    //   ],
                    // ),
                    //const SizedBox(height: 24),

                    // 3. General Settings Section
                    SettingsSection(
                      title: 'GENERAL'.tr,
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.activeGreen,
                        size: 14,
                      ),
                      children: [
                        SettingsDropdownRow(
                          title: 'Language'.tr,
                          subtitle: 'Application display language'.tr,
                          value: state.languageCode == 'ar'
                              ? 'Arabic'.tr
                              : 'English'.tr,
                          options: ['English'.tr, 'Arabic'.tr],
                          onChanged: (val) => _cubit.setLanguage(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. Prayer Silence Behavior Section
                    if (Platform.isAndroid)
                      SettingsSection(
                        title: 'PRAYER SILENCE BEHAVIOR'.tr,
                        icon: const Icon(
                          Icons.volume_up_outlined,
                          color: AppColors.activeGreen,
                          size: 14,
                        ),
                        children: [
                          SettingsSwitchRow(
                            title: 'Restore previous sound mode'.tr,
                            subtitle:
                                'Return to your ringtone level after prayer'.tr,
                            value: state.restoreSound,
                            onChanged: (val) => _cubit.setRestoreSound(val),
                          ),
                          SettingsSwitchRow(
                            title: 'Vibrate instead of silent'.tr,
                            subtitle: 'Phone will vibrate during prayer'.tr,
                            value: state.vibrateInstead,
                            onChanged: (val) => _cubit.setVibrateInstead(val),
                          ),
                        ],
                      ),
                    if (Platform.isAndroid) const SizedBox(height: 24),

                    // 5. Calculation Section
                    SettingsSection(
                      title: 'LOCATION & CALCULATION'.tr,
                      icon: SvgPicture.asset(
                        AppIcons.mapPin,
                        width: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.activeGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                      children: [
                        ProfileActionRow(
                          title: 'Prayer Time Adjustments'.tr,
                          subtitle: 'Manually add or subtract minutes'.tr,
                          icon: const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFF2ECC71),
                            size: 20,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrayerAdjustmentsScreen(),
                              ),
                            );
                          },
                        ),
                        SettingsDropdownRow(
                          title: 'Calculation method'.tr,
                          subtitle: 'Used to determine prayer times'.tr,
                          value: state.calculationMethod,
                          options: [
                            'Muslim World League'.tr,
                            'Islamic Society of North America'.tr,
                            'Egyptian General Authority'.tr,
                            'Umm Al-Qura, Makkah'.tr,
                            'University of Islamic Sciences, Karachi'.tr,
                          ],
                          onChanged: (val) => _cubit.setCalculationMethod(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6. About Section
                    SettingsSection(
                      title: 'ABOUT'.tr,
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
                          title: 'About Sukun'.tr,
                          subtitle: 'Learn more about the project'.tr,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      getIt<AboutCubit>()..loadAppInfo(),
                                  child: const AboutScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileActionRow(
                          icon: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.activeGreen,
                            size: 17,
                          ),
                          title: 'Privacy Policy'.tr,
                          showDivider: false,
                          onTap: () async {
                            final uri = Uri.parse(
                                'https://github.com/mohammedzizou/sukun/blob/main/PRIVACY_POLICY.md');
                            if (!await launchUrl(uri,
                                mode: LaunchMode.externalApplication)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open link'.tr)),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Sukun v1.0.0 · Made with ☪ for the Ummah'.tr,
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
