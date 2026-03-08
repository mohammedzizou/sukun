import 'package:flutter/material.dart';
import 'package:sukun/core/constants/theme_data.dart';

class SettingsSliderRow extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String labelSuffix;
  final bool showDivider;

  const SettingsSliderRow({
    super.key,
    required this.title,
    required this.value,
    this.min = 0,
    this.max = 60,
    required this.onChanged,
    this.labelSuffix = 'min',
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xCCA3F7BF),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: ShapeDecoration(
                color: const Color(0x1E2ECC71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '${value.toInt()} $labelSuffix',
                style: const TextStyle(
                  color: AppColors.activeGreen,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: AppColors.activeGreen,
            inactiveTrackColor: const Color(0x19A3F7BF),
            thumbColor: Colors.white,
            overlayColor: AppColors.activeGreen.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 9,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0x11A3F7BF)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
