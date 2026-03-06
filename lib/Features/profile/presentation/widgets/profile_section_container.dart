import 'package:flutter/material.dart';

class ProfileSectionContainer extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const ProfileSectionContainer({
    super.key,
    this.title,
    this.icon,
    required this.children,
    this.padding = const EdgeInsets.all(18.52),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.52, color: Color(0x16A3F7BF)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && icon != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: const Color(0x11A3F7BF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 14),
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }
}
