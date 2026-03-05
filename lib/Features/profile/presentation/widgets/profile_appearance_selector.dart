import 'package:flutter/material.dart';

class ProfileAppearanceSelector extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onModeChanged;

  const ProfileAppearanceSelector({
    super.key,
    required this.isDarkMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onModeChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: ShapeDecoration(
                color: isDarkMode
                    ? const Color(0x262ECC71)
                    : Colors.white.withOpacity(0.03),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.52,
                    color: isDarkMode
                        ? const Color(0x592ECC71)
                        : const Color(0x19A3F7BF),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.white.withOpacity(0.55),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dark Emerald',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Peaceful night mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0x59A3F7BF),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isDarkMode)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6), // spacing
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onModeChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: ShapeDecoration(
                color: !isDarkMode
                    ? const Color(0x262ECC71)
                    : Colors.white.withOpacity(0.03),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.52,
                    color: !isDarkMode
                        ? const Color(0x592ECC71)
                        : const Color(0x19A3F7BF),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: !isDarkMode
                        ? Colors.white
                        : Colors.white.withOpacity(0.55),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Light Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: !isDarkMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bright and airy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0x59A3F7BF),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!isDarkMode)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
