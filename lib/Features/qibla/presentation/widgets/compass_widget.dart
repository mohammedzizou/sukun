import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
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
    // We convert degrees to turns (0.0 to 1.0) for AnimatedRotation
    // Negative because the phone turns right (positive degrees),
    // so the compass dial must rotate left (negative degrees) to stay pointing north.
    final compassRotationTurns = -currentHeading / 360.0;

    // The Qibla needle is offset from North by qiblaDirection degrees.
    // It rotates with the compass dial.
    final qiblaRotationTurns = (qiblaDirection - currentHeading) / 360.0;

    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: isQiblaFound ? AppColors.activeGreen : AppColors.mint07,
            width: isQiblaFound ? 3.0 : 1.0,
          ),
          boxShadow: isQiblaFound
              ? [
                  BoxShadow(
                    color: AppColors.activeGreen.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Dial (North/South/East/West markers)
            AnimatedRotation(
              turns: compassRotationTurns,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _buildDialBase(),
            ),

            // 2. The Qibla Needle pointing to Mecca
            AnimatedRotation(
              turns: qiblaRotationTurns,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _buildQiblaNeedle(),
            ),

            // 3. Center Dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isQiblaFound ? AppColors.activeGreen : AppColors.mint50,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Draws the static ticks and N/S/E/W letters which spin against the phone
  Widget _buildDialBase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Tick marks outer ring
        CustomPaint(size: const Size(280, 280), painter: _DialPainter()),
        // North indicator
        Positioned(
          top: 10,
          child: Column(
            children: [
              const Text(
                'N',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Container(width: 4, height: 10, color: Colors.redAccent),
            ],
          ),
        ),
        // South indicator
        const Positioned(
          bottom: 20,
          child: Text(
            'S',
            style: TextStyle(
              color: AppColors.mint50,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        // East indicator
        const Positioned(
          right: 20,
          child: Text(
            'E',
            style: TextStyle(
              color: AppColors.mint50,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        // West indicator
        const Positioned(
          left: 20,
          child: Text(
            'W',
            style: TextStyle(
              color: AppColors.mint50,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // The custom shape for the Qibla pointer
  Widget _buildQiblaNeedle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Needle head points UP
        SizedBox(
          width: 80,
          height: 140,
          child: CustomPaint(
            painter: _NeedlePainter(
              color: isQiblaFound ? AppColors.activeGreen : AppColors.mint45,
            ),
          ),
        ),
        // Invisible offset to keep the rotation centered purely on the base of the needle
        const SizedBox(height: 140),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.mint15
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 15) {
      if (i % 90 == 0) continue; // Skip N E S W
      final lengthMultiplier = i % 45 == 0
          ? 0.85
          : 0.93; // Major vs minor ticks

      final outerR = radius * 0.98;
      final innerR = radius * lengthMultiplier;

      final angle = i * math.pi / 180;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {
  final Color color;

  _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Drawing a simple kite shape for the needle
    var path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(size.width * 0.8, size.height * 0.7); // Right
    path.lineTo(size.width / 2, size.height); // Bottom (center)
    path.lineTo(size.width * 0.2, size.height * 0.7); // Left
    path.close();

    canvas.drawPath(path, paint);

    // Add a shadow/highlight split to make 3D
    var paintShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    var pathShadow = Path();
    pathShadow.moveTo(size.width / 2, 0);
    pathShadow.lineTo(size.width * 0.8, size.height * 0.7);
    pathShadow.lineTo(size.width / 2, size.height);
    pathShadow.close();

    canvas.drawPath(pathShadow, paintShadow);
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter oldDelegate) =>
      color != oldDelegate.color;
}
