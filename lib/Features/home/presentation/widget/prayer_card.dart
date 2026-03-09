import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';

class PrayerCard extends StatelessWidget {
  final String englishName;
  final String time;
  final String iconPath;
  final bool isSilent;
  final bool isNext;
  final VoidCallback? onToggleSilent;

  const PrayerCard({
    super.key,
    required this.englishName,
    required this.time,
    required this.iconPath,
    required this.isSilent,
    this.isNext = false,
    this.onToggleSilent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73.21,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.activeGreen12
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !isNext ? AppColors.mint07 : AppColors.activeGreen30,
          width: 0.52,
        ),
      ),
      child: Row(
        children: [
          // Left Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.activeGreen20
                  : AppColors.surfaceDark, // Slightly lighter green box
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isNext
                    ? AppColors.activeGreen
                    : AppColors.mint45, // Emerald Green
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  englishName.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.mint45, // Grey/Green text
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // "NEXT" Pill Badge
          if (isNext)
            Container(
              width: 43.04,
              height: 18.99,

              decoration: BoxDecoration(
                color: AppColors.activeGreen15,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'NEXT'.tr,
                  style: const TextStyle(
                    color: AppColors.activeGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          // Bell Icon Button
          GestureDetector(
            onTap: onToggleSilent,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.transparent,
              child: SvgPicture.asset(
                Platform.isIOS
                    ? (isSilent ? AppIcons.bell : AppIcons.bellOff)
                    : (isSilent ? AppIcons.bellOff : AppIcons.bell),
                width: 17,
                height: 17,
                colorFilter: ColorFilter.mode(
                  isSilent ? AppColors.activeGreen : AppColors.primaryGreen,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
