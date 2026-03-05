import 'dart:math' show pi;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/widgets/location_error_widget.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/widgets/compass_widget.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaCubit()..initializeCompass(),
      child: const _QiblahCompassContent(),
    );
  }
}

class _QiblahCompassContent extends StatefulWidget {
  const _QiblahCompassContent();

  @override
  State<_QiblahCompassContent> createState() => _QiblahCompassContentState();
}

class _QiblahCompassContentState extends State<_QiblahCompassContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by main layout
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            Expanded(
              child: BlocBuilder<QiblaCubit, QiblaState>(
                builder: (context, state) {
                  if (state is QiblaLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (state is QiblaUnsupported) {
                    return const Center(
                      child: Text(
                        "Device sensor not supported",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (state is QiblaLocationDisabled) {
                    return LocationErrorWidget(
                      error: "Please enable Location service",
                      callback: () =>
                          context.read<QiblaCubit>().checkLocationStatus(),
                    );
                  }

                  if (state is QiblaPermissionDenied) {
                    return LocationErrorWidget(
                      error: "Location service permission denied",
                      callback: () =>
                          context.read<QiblaCubit>().checkLocationStatus(),
                    );
                  }

                  if (state is QiblaPermissionDeniedForever) {
                    return const LocationErrorWidget(
                      error: "Location service Denied Forever !",
                    );
                  }

                  return const QiblahCompassWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qibla Direction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.activeGreen12,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Mecca, Saudi Arabia',
                style: TextStyle(
                  color: AppColors.activeGreen12,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QiblahCompassWidget extends StatelessWidget {
  const QiblahCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final qiblahDirection = snapshot.data!;

        // Normalize the angle to [-180, 180] for accurate distance check
        double relativeAngle = qiblahDirection.qiblah;
        while (relativeAngle > 180) relativeAngle -= 360;
        while (relativeAngle < -180) relativeAngle += 360;

        // Threshold set to 14.0 as requested
        final bool isFound = relativeAngle.abs() <= 14.0;

        return Column(
          children: [
            const Spacer(flex: 1),
            CompassWidget(
              currentHeading: qiblahDirection.direction,
              qiblaDirection: qiblahDirection.offset,
              isQiblaFound: isFound,
            ),
            const Spacer(flex: 2),
            _buildStatusCard(qiblahDirection, isFound),
            const SizedBox(height: 24),
            _buildInstructions(),
            const Spacer(flex: 1),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(QiblahDirection qiblahDirection, bool isFound) {
    double relativeAngle = qiblahDirection.qiblah;
    // Normalize to [-180, 180]
    while (relativeAngle > 180) relativeAngle -= 360;
    while (relativeAngle < -180) relativeAngle += 360;

    String text;
    IconData icon;
    if (isFound) {
      text = "You are now facing Mecca";
      icon = Icons.check_circle;
    } else if (relativeAngle > 0) {
      text =
          "Rotate the phone ${relativeAngle.abs().toStringAsFixed(0)}° to the right";
      icon = Icons.screen_rotation;
    } else {
      text =
          "Rotate the phone ${relativeAngle.abs().toStringAsFixed(0)}° to the left";
      icon = Icons.screen_rotation;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: ShapeDecoration(
        color: isFound
            ? AppColors.activeGreen12
            : Colors.white.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.5,
            color: isFound
                ? AppColors.activeGreen20
                : AppColors.activeGreen12.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isFound ? AppColors.activeGreen : Colors.white,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        "Align both arrow head\nDo not put device close to metal object.\nCalibrate the compass everytime you use it.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.activeGreen12,
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}
