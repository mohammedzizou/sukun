// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_silence_time_app/Features/home/presentation/widget/prayer_card.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/core/widgets/app_switch.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  Duration _timeRemaining = const Duration(hours: 2, minutes: 58, seconds: 9);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildNextPrayerCard(),
          const SizedBox(height: 32),
          const Text(
            'TODAY\'S PRAYERS',
            style: TextStyle(
              color: Color(0xFF8B9A93),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildPrayerTimesList(),
          const SizedBox(height: 16),
          _buildAutoSilentToggle(),
          const SizedBox(height: 16),
          _buildPermissionRequired(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Good Night',
          style: TextStyle(color: AppColors.mint60, fontSize: 12),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assalamu Alaikum',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: ShapeDecoration(
                color: AppColors.activeGreen12,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.52, color: AppColors.activeGreen20),
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: Center(
                child: Text(
                  '☪',
                  style: TextStyle(
                    color: const Color(0xFF0A0A0A),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SvgPicture.asset(
              AppIcons.mapPin,
              width: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.textGrey,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Mecca, Saudi Arabia - Wednesday, March 4',
              style: TextStyle(color: AppColors.mint50, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 160,
            height: 160,
            decoration: ShapeDecoration(
              gradient: RadialGradient(
                center: Alignment(0.50, 0.50),
                radius: 0.71,
                colors: [
                  AppColors.activeGreen15,
                  Colors.black.withValues(alpha: 0),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 244.01,
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [AppColors.activeGreen18, AppColors.surfaceGradientDark],
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 0.52, color: AppColors.activeGreen28),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'NEXT PRAYER',
                    style: TextStyle(
                      color: AppColors.mint65,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Prayer time',
                    style: TextStyle(color: AppColors.mint65, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Fajr',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '5:12 AM',
                    style: TextStyle(
                      color: AppColors.mint100,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'الفجر',
                    style: TextStyle(
                      color: AppColors.mint50,
                      fontSize: 15,
                      fontFamily: 'Noto Naskh Arabic',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 93.48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: ShapeDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TIME REMAINING',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(_timeRemaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceDark,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.bellOff,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesList() {
    return Column(
      children: const [
        PrayerCard(
          englishName: 'Fajr',
          time: '5:12 AM',
          iconPath: AppIcons.fajr,
          isSilent: true,
          isNext: true,
        ),
        PrayerCard(
          englishName: 'Dhuhr',
          time: '12:28 PM',
          iconPath: AppIcons.dhuhr,
          isSilent: true,
        ),
        PrayerCard(
          englishName: 'Asr',
          time: '3:45 PM',
          iconPath: AppIcons.asr,
          isSilent: true,
        ),
        PrayerCard(
          englishName: 'Maghrib',
          time: '6:22 PM',
          iconPath: AppIcons.maghrib,
          isSilent: true,
        ),
        PrayerCard(
          englishName: 'Isha',
          time: '7:52 PM',
          iconPath: AppIcons.isha,
          isSilent: true,
        ),
      ],
    );
  }

  Widget _buildAutoSilentToggle() {
    return Container(
      height: 95.02,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.52, color: AppColors.mint10),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              AppIcons.bellOff,
              width: 20,
              height: 20,
              color: AppColors.activeGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Auto Silent Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tap to enable automatic silencing',
                  style: TextStyle(color: AppColors.mint50, fontSize: 12),
                ),
              ],
            ),
          ),
          AppSwitch(value: true, onChanged: (val) {}),
        ],
      ),
    );
  }

  Widget _buildPermissionRequired() {
    return Container(
      height: 90.54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: AppColors.gold05,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.52, color: AppColors.gold18),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(
              color: AppColors.gold12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.gold80, // yellow/gold
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Permission Required',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Grant Do Not Disturb access to enable auto-silent',
                  style: TextStyle(color: AppColors.gold60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64.25,
            height: 31.03,
            decoration: ShapeDecoration(
              color: AppColors.gold15,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.52, color: AppColors.gold25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Center(
              child: const Text(
                'Enable',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
