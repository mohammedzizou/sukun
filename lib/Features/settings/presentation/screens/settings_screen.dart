import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_dropdown_row.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_section.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_slider_row.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_status_row.dart';
import 'package:sukun/features/settings/presentation/widgets/settings_switch_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _totalDuration = 30;
  double _startBefore = 5;
  double _continueAfter = 10;
  bool _restoreSound = true;
  bool _vibrateInstead = false;
  bool _autoDetectLocation = true;
  String _calculationMethod = 'Umm Al-Qura, Makkah';

  final List<String> _calculationMethods = [
    'Muslim World League',
    'Islamic Society of North America',
    'Egyptian General Authority',
    'Umm Al-Qura, Makkah',
    'University of Islamic Sciences, Karachi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Background handled by parent AppBackground
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silence Settings',
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
                'Customize how and when your phone silences',
                style: TextStyle(
                  color: Color(0x7FA3F7BF),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 32),

              // 1. Silence Duration Section
              SettingsSection(
                title: 'SILENCE DURATION',
                icon: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.activeGreen,
                  size: 14,
                ),
                children: [
                  SettingsSliderRow(
                    title: 'Total silent duration',
                    value: _totalDuration,
                    max: 120,
                    onChanged: (val) => setState(() => _totalDuration = val),
                  ),
                  SettingsSliderRow(
                    title: 'Start before prayer',
                    value: _startBefore,
                    max: 30,
                    onChanged: (val) => setState(() => _startBefore = val),
                  ),
                  SettingsSliderRow(
                    title: 'Continue after prayer',
                    value: _continueAfter,
                    max: 60,
                    showDivider: false,
                    onChanged: (val) => setState(() => _continueAfter = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Sound Behavior Section
              SettingsSection(
                title: 'SOUND BEHAVIOR',
                icon: const Icon(
                  Icons.volume_up_outlined,
                  color: AppColors.activeGreen,
                  size: 14,
                ),
                children: [
                  SettingsSwitchRow(
                    title: 'Restore previous sound mode',
                    subtitle:
                        'Automatically return to your ringtone level after prayer',
                    value: _restoreSound,
                    onChanged: (val) => setState(() => _restoreSound = val),
                  ),
                  SettingsSwitchRow(
                    title: 'Vibrate instead of full silent',
                    subtitle:
                        'Phone will vibrate during prayer instead of complete silence',
                    value: _vibrateInstead,
                    showDivider: false,
                    onChanged: (val) => setState(() => _vibrateInstead = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Silent Mode Section
              SettingsSection(
                title: 'SILENT MODE',
                icon: SvgPicture.asset(
                  AppIcons.bellOff,
                  width: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.activeGreen,
                    BlendMode.srcIn,
                  ),
                ),
                children: [
                  SettingsStatusRow(
                    title: 'Silence all sounds',
                    subtitle:
                        'Complete silence including media, alarms and notifications',
                    statusText: 'Active',
                    isActive: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Location & Calculation Section
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
                  SettingsSwitchRow(
                    title: 'Auto-detect location',
                    subtitle: 'Mecca, Saudi Arabia (GPS)',
                    value: _autoDetectLocation,
                    onChanged: (val) =>
                        setState(() => _autoDetectLocation = val),
                  ),
                  SettingsDropdownRow(
                    title: 'Calculation method',
                    subtitle: 'Used to determine prayer times',
                    value: _calculationMethod,
                    options: _calculationMethods,
                    onChanged: (val) =>
                        setState(() => _calculationMethod = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  // Save settings logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 48,
              ), // Bottom padding for navigation bar spacing
            ],
          ),
        ),
      ),
    );
  }
}
