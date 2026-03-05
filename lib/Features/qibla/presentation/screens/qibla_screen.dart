import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:prayer_silence_time_app/features/qibla/presentation/widgets/compass_widget.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaCubit()..initializeCompass(),
      child: const _QiblaScreenContent(),
    );
  }
}

class _QiblaScreenContent extends StatelessWidget {
  const _QiblaScreenContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const Spacer(flex: 2),
          _buildCompassArea(),
          const Spacer(flex: 3),
          _buildRecalibrateButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.qiblaActive,
                width: 28,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Qibla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassArea() {
    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) {
        if (state is QiblaLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.activeGreen),
          );
        }

        if (state is QiblaPermissionDenied) {
          return _buildErrorState('Location permission required for Qibla.');
        }

        if (state is QiblaNeedsCalibration) {
          return Column(
            children: [
              const Icon(Icons.sync, color: AppColors.activeGreen, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Calibrating...',
                style: TextStyle(color: AppColors.mint50, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please move your phone in a figure 8 motion.',
                style: TextStyle(color: AppColors.mint50, fontSize: 14),
              ),
            ],
          );
        }

        if (state is QiblaActive) {
          return Column(
            children: [
              CompassWidget(
                currentHeading: state.heading,
                qiblaDirection: state.qiblaDirection,
                isQiblaFound: state.isQiblaFound,
              ),
              const SizedBox(height: 48),
              Text(
                state.isQiblaFound
                    ? 'You are facing the Qibla'
                    : 'Point needle to Qibla',
                style: TextStyle(
                  color: state.isQiblaFound
                      ? AppColors.activeGreen
                      : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.heading.toStringAsFixed(0)}° / ${state.qiblaDirection.toStringAsFixed(0)}° NE',
                style: const TextStyle(color: AppColors.mint50, fontSize: 14),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        const Icon(Icons.location_off, color: Colors.redAccent, size: 64),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRecalibrateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: OutlinedButton(
        onPressed: () {
          context.read<QiblaCubit>().requestRecalibration();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.mint15, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cached, color: AppColors.mint45, size: 20),
            SizedBox(width: 8),
            Text(
              'Recalibrate Compass',
              style: TextStyle(
                color: AppColors.mint50,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
