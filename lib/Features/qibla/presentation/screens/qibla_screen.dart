import 'dart:math' show pi;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/widgets/location_error_widget.dart';

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
          return _buildShimmerLoading();
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final qiblahDirection = snapshot.data!;
        // Exact logic from example:
        var angle = ((qiblahDirection.qiblah) * (pi / 180) * -1);

        // Calculate if aligned (threshold like the example or standard 5 deg)
        // Note: qiblahDirection.qiblah is already the offset from device north to Mecca.
        bool isFound = qiblahDirection.qiblah.abs() <= 5.0;

        return Column(
          children: [
            const Spacer(flex: 1),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Transform.rotate(
                  angle: angle,
                  child: SvgPicture.asset(
                    'assest/icons/5.svg', // Compass dial
                    width: 280,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assest/icons/4.svg', // Kaaba logo
                  width: 250,
                ),
                SvgPicture.asset(
                  'assest/icons/3.svg', // Needle pointer (static top)
                  width: 290,
                  colorFilter: ColorFilter.mode(
                    isFound ? AppColors.activeGreen : Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            _buildStatusCard(isFound, qiblahDirection.direction),
            const SizedBox(height: 24),
            _buildInstructions(),
            const Spacer(flex: 1),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SvgPicture.asset('assest/icons/5.svg', width: 280),
          SvgPicture.asset('assest/icons/4.svg', width: 80),
          SvgPicture.asset('assest/icons/3.svg', width: 35),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isFound, double heading) {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.near_me,
                size: 18,
                color: isFound ? AppColors.activeGreen : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isFound ? 'Qibla Found' : 'Finding Qibla...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${heading.toStringAsFixed(0)}° / Align both arrow heads',
            style: const TextStyle(
              color: AppColors.activeGreen12,
              fontSize: 14,
              fontWeight: FontWeight.w400,
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
