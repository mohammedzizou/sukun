import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';
import 'package:sukun/core/widgets/app_background.dart';
import 'package:sukun/core/widgets/app_button.dart';

class MosqueModeScreen extends StatelessWidget {
  const MosqueModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen12,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.bellOff,
                    width: 64,
                    height: 64,
                    colorFilter: const ColorFilter.mode(
                      AppColors.activeGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Mosque Mode'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'For iOS devices, silent mode must be enabled manually. Please switch your phone to silent or Focus mode before entering the mosque.'
                      .tr,
                  style: const TextStyle(
                    color: AppColors.mint65,
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mint10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.activeGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Note: We have scheduled notifications to remind you 5 minutes before each prayer.'
                              .tr,
                          style: const TextStyle(
                            color: AppColors.mint50,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'I Enabled Silent Mode'.tr,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel'.tr,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
