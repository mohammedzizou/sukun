import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'dart:math' as math;

class CompassWidget extends StatelessWidget {
  final double currentHeading;
  final double qiblaDirection;
  final bool isQiblaFound;

  const CompassWidget({
    super.key,
    required this.currentHeading,
    required this.qiblaDirection,
    required this.isQiblaFound,
  });

  @override
  Widget build(BuildContext context) {
    // Rotation turns (0.0 to 1.0) for AnimatedRotation
    final compassRotationTurns = -currentHeading / 360.0;
    final qiblaRotationTurns = (qiblaDirection - currentHeading) / 360.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Interactive Outer Glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isQiblaFound
                  ? [
                      BoxShadow(
                        color: AppColors.activeGreen.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: AppColors.activeGreen.withValues(alpha: 0.15),
                        blurRadius: 50,
                        spreadRadius: 30,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
            ),
          ),

          // 2. Glassmorphic Base
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: isQiblaFound
                        ? AppColors.activeGreen.withValues(alpha: 0.6)
                        : AppColors.mint35.withValues(alpha: 0.2),
                    width: isQiblaFound ? 2.5 : 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 3. The Compass Dial
                    AnimatedRotation(
                      turns: compassRotationTurns,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuart,
                      child: _buildDialBase(),
                    ),

                    // 4. The Qibla Needle
                    AnimatedRotation(
                      turns: qiblaRotationTurns,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      child: _buildQiblaNeedle(),
                    ),

                    // 5. Center Hub
                    _buildCenterHub(),
                  ],
                ),
              ),
            ),
          ),

          // 6. Static Top Marker (Always North relative to phone screen)
          Positioned(
            top: 20,
            child: Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: isQiblaFound ? AppColors.activeGreen : Colors.white24,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isQiblaFound
                    ? [
                        BoxShadow(
                          color: AppColors.activeGreen.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialBase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(280, 280),
          painter: _ModernDialPainter(isFound: isQiblaFound),
        ),
        // Markers
        _buildDirectionMarker('N', 0, Colors.redAccent),
        _buildDirectionMarker('E', 90, AppColors.mint50),
        _buildDirectionMarker('S', 180, AppColors.mint50),
        _buildDirectionMarker('W', 270, AppColors.mint50),
      ],
    );
  }

  Widget _buildDirectionMarker(String label, double angle, Color color) {
    final double rad = angle * math.pi / 180;
    const double offset = 116;
    return Transform.translate(
      offset: Offset(offset * math.sin(rad), -offset * math.cos(rad)),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: SvgPicture.asset(
              'assest/icons/motion_div.svg',
              width: 200,
              height: 200,
              colorFilter: ColorFilter.mode(
                isQiblaFound ? AppColors.activeGreen : AppColors.mint100,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          child: SvgPicture.asset(
            'assest/icons/4.svg',
            width: 160,
            height: 160,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterHub() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            isQiblaFound ? AppColors.activeGreen : AppColors.mint100,
            isQiblaFound
                ? AppColors.activeGreen.withValues(alpha: 0.6)
                : AppColors.mint50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ModernDialPainter extends CustomPainter {
  final bool isFound;

  _ModernDialPainter({required this.isFound});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final majorTickPaint = Paint()
      ..color = isFound
          ? AppColors.activeGreen.withValues(alpha: 0.8)
          : AppColors.mint35.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = isFound
          ? AppColors.activeGreen.withValues(alpha: 0.3)
          : AppColors.mint35.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Outer Circle Ring
    final ringPaint = Paint()
      ..color = isFound
          ? AppColors.activeGreen.withValues(alpha: 0.2)
          : AppColors.mint35.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.95, ringPaint);

    for (int i = 0; i < 360; i += 5) {
      if (i % 90 == 0) continue; // Skip N E S W spots for labels

      final bool isMajor = i % 30 == 0;
      final paint = isMajor ? majorTickPaint : minorTickPaint;

      final length = isMajor ? 12.0 : 6.0;
      final outerR = radius * 0.92;
      final innerR = outerR - length;

      final angle = (i - 90) * math.pi / 180;
      final p1 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernDialPainter oldDelegate) =>
      isFound != oldDelegate.isFound;
}
