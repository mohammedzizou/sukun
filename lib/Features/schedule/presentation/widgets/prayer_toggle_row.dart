import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/core/widgets/app_switch.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_time_item.dart';

class PrayerToggleRow extends StatelessWidget {
  final PrayerTimeItem prayer;
  final ValueChanged<bool> onToggle;

  const PrayerToggleRow({
    super.key,
    required this.prayer,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73.47,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0x192ECC71),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          // SVG Icon Holder
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              prayer.iconPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.mint45,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Prayer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prayer.name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      prayer.time,
                      style: const TextStyle(
                        color: AppColors.mint45,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      prayer.isSilent ? AppIcons.bellOff : AppIcons.bell,
                      width: 12,
                      height: 12,
                      colorFilter: ColorFilter.mode(
                        prayer.isSilent
                            ? AppColors.activeGreen
                            : AppColors.mint45,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prayer.isSilent ? 'Silent' : 'Sound',
                      style: TextStyle(
                        color: prayer.isSilent
                            ? AppColors.activeGreen
                            : AppColors.mint45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Shared AppSwitch
          AppSwitch(value: prayer.isSilent, onChanged: onToggle),
        ],
      ),
    );
  }
}
