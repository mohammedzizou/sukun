import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/profile/presentation/widgets/profile_action_row.dart';
import 'package:prayer_silence_time_app/features/profile/presentation/widgets/profile_appearance_selector.dart';
import 'package:prayer_silence_time_app/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:prayer_silence_time_app/features/profile/presentation/widgets/profile_section_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = true;

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
                'Profile',
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
                'Your preferences and app information',
                style: TextStyle(
                  color: Color(0x7FA3F7BF),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 28),

              const ProfileHeaderCard(),
              const SizedBox(height: 20),

              ProfileSectionContainer(
                padding: const EdgeInsets.only(
                  top: 6.51,
                  bottom: 0.52,
                  left: 18.52,
                  right: 18.52,
                ),
                children: [
                  ProfileActionRow(
                    icon: SvgPicture.asset(
                      AppIcons.mapPin,
                      width: 17,
                      colorFilter: const ColorFilter.mode(
                        AppColors.activeGreen,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: 'Location',
                    subtitle: 'Mecca, Saudi Arabia',
                    onTap: () {},
                  ),
                  ProfileActionRow(
                    icon: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.activeGreen,
                      size: 17,
                    ),
                    title: 'Calculation Method',
                    subtitle: 'Umm Al-Qura, Makkah',
                    showDivider: false,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ProfileSectionContainer(
                title: 'Appearance',
                icon: const Icon(
                  Icons.palette_outlined,
                  color: AppColors.activeGreen,
                  size: 17,
                ),
                children: [
                  ProfileAppearanceSelector(
                    isDarkMode: _isDarkMode,
                    onModeChanged: (isDark) {
                      setState(() {
                        _isDarkMode = isDark;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ProfileSectionContainer(
                padding: const EdgeInsets.only(
                  top: 6.51,
                  bottom: 0.52,
                  left: 18.52,
                  right: 18.52,
                ),
                children: [
                  ProfileActionRow(
                    icon: const Icon(
                      Icons.info_outline,
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
              const SizedBox(height: 24),

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

              const SizedBox(height: 48), // Padding for bottom navbar
            ],
          ),
        ),
      ),
    );
  }
}
