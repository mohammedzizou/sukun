// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/core/constants/images.dart';

/// Data model for a single onboarding page.
class OnboardingPageData {
  final String tag;
  final String title;
  final String subtitle;
  final String iconAsset;
  final bool
  useMosqueLayout; // page 1 uses big mosk.svg, pages 2&3 use circle icon

  const OnboardingPageData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.useMosqueLayout = false,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right radial glow
        Positioned(
          left: 173,
          top: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.71,
                colors: [
                  const Color(0x0F2ECC71),
                  Colors.black.withValues(alpha: 0),
                ],
              ),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
        ),
        // Bottom-left radial glow
        Positioned(
          left: -60,
          top: 532,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.71,
                colors: [
                  const Color(0x0A2ECC71),
                  Colors.black.withValues(alpha: 0),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        // Main content
        Column(
          children: [
            const SizedBox(height: 88),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Illustration area
                  SizedBox(
                    width: 329,
                    child: data.useMosqueLayout
                        ? _buildMosqueIllustration()
                        : _buildCircleIconIllustration(),
                  ),
                  const SizedBox(height: 20),
                  // Tag pill
                  _buildTag(),
                  const SizedBox(height: 20),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      data.title.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 46),
                    child: Text(
                      data.subtitle.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xA5A3F7BF),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: ShapeDecoration(
        color: const Color(0x1E2ECC71),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.65, color: Color(0x332ECC71)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        data.tag.tr,
        style: const TextStyle(
          color: Color(0xFF2ECC71),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.50,
          letterSpacing: 0.50,
        ),
      ),
    );
  }

  /// Page 1: big mosque SVG image with subtle radial glow behind it
  Widget _buildMosqueIllustration() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow behind mosque
          Container(
            width: 260,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.75,
                colors: [
                  const Color(0x142ECC71),
                  Colors.black.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          SvgPicture.asset(
            AppIcons.mosque,
            width: 260,
            height: 180,
            colorFilter: const ColorFilter.mode(
              Color(0xFF2ECC71),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  /// Pages 2 & 3: concentric circle container with SVG icon inside
  Widget _buildCircleIconIllustration() {
    return SizedBox(
      height: 220,
      child: Center(
        child: SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost faint ring
              Container(
                width: 220,
                height: 220,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.65,
                      color: Color(0x0F2ECC71),
                    ),
                    borderRadius: BorderRadius.circular(110),
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 190,
                height: 190,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.65,
                      color: Color(0x192ECC71),
                    ),
                    borderRadius: BorderRadius.circular(95),
                  ),
                ),
              ),
              // Main circle (filled)
              Container(
                width: 160,
                height: 160,
                decoration: ShapeDecoration(
                  color: const Color(0x142ECC71),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.65,
                      color: Color(0x262ECC71),
                    ),
                    borderRadius: BorderRadius.circular(80),
                  ),
                ),
              ),
              // Inner circle
              Container(
                width: 110,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0x192ECC71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(55),
                  ),
                ),
              ),
              // Icon
              SvgPicture.asset(
                data.iconAsset,
                width: 52,
                height: 52,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF2ECC71),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
