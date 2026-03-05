import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';

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
            ? Color(0x1E2ECC71)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !isNext ? Color(0x11A3F7BF) : const Color(0x4C2ECC71),
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
                  ? Color(0x332ECC71)
                  : const Color(0xFF153B2D), // Slightly lighter green box
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isNext ? Color(0xff2ECC71) : Color(0x72A3F7BF), // Emerald Green
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
                  englishName,
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
                    color: Color(0x72A3F7BF), // Grey/Green text
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
                color: const Color(0x262ECC71),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
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
                isSilent ? AppIcons.bellOff : AppIcons.bell,
                width: 15,
                height: 15,
                colorFilter: ColorFilter.mode(
                  isSilent
                      ? isNext
                            ? Color(0xFF2ECC71)
                            : const Color(0x72A3F7BF)
                      : const Color(0xFF4CAF50),
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
