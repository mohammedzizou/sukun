import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sukun/features/home/presentation/controller/cubit/home_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sukun/features/home/presentation/widget/prayer_card.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/constants/theme_data.dart';
import 'package:sukun/core/widgets/app_switch.dart';
import 'package:sukun/core/di/dipendency_injection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..initHome();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLocationLoading || state is HomeLoading) {
              return _buildLoadingState();
            } else if (state is HomeLoaded) {
              return _buildLoadedState(context, state);
            } else if (state is HomeError) {
              return _buildErrorState(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(height: 244, color: Colors.white),
            const SizedBox(height: 32),
            Container(height: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().getPrayerTimes(
              city: 'Mecca',
              country: 'Saudi Arabia',
              latitude: 36.29052158900566,
              longitude: 2.03460751770638,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, HomeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state),
          const SizedBox(height: 24),
          _buildNextPrayerCard(state),
          const SizedBox(height: 32),

          _buildPermissionRequired(context, state),
          const SizedBox(height: 16),
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
          _buildPrayerTimesList(context, state),
          const SizedBox(height: 16),
          _buildAutoSilentToggle(context, state),

          const SizedBox(height: 32),
          _buildSectionTitle('Global Silence Settings'),
          const SizedBox(height: 8),
          _buildGlobalSilenceSettings(context, state),
          const SizedBox(height: 24),
          _buildJumuahSection(context, state),
          const SizedBox(height: 24),
          _buildRamadanSection(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader(HomeLoaded state) {
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
              child: const Center(
                child: Text(
                  '☪',
                  style: TextStyle(
                    color: Color(0xFF0A0A0A),
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
            Text(
              state.location != null
                  ? '${state.location!.city}, ${state.location!.country}'
                  : '${state.prayerTimes.city}, ${state.prayerTimes.country}',
              style: const TextStyle(color: AppColors.mint50, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(HomeLoaded state) {
    final nextPrayer = state.nextPrayer;
    if (nextPrayer == null) return const SizedBox.shrink();

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
                center: const Alignment(0.50, 0.50),
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
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [AppColors.activeGreen18, AppColors.surfaceGradientDark],
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.52,
                color: AppColors.activeGreen28,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                children: [
                  Text(
                    nextPrayer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nextPrayer.time,
                    style: const TextStyle(
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
                    nextPrayer.arabicName,
                    style: const TextStyle(
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
                          _formatDuration(state.timeRemaining),
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

  Widget _buildPrayerTimesList(BuildContext context, HomeLoaded state) {
    return Column(
      children: state.prayerTimes.prayers.map((prayer) {
        final isNext = prayer == state.nextPrayer;
        return PrayerCard(
          englishName: prayer.name,
          time: prayer.time,
          iconPath: prayer.iconPath,
          isSilent: prayer.isSilent,
          isNext: isNext,
          onToggleSilent: () =>
              context.read<HomeCubit>().togglePrayerSilent(prayer.name),
        );
      }).toList(),
    );
  }

  Widget _buildAutoSilentToggle(BuildContext context, HomeLoaded state) {
    return Container(
      height: 95.02,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.52, color: AppColors.mint10),
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
              colorFilter: const ColorFilter.mode(
                AppColors.activeGreen,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
          AppSwitch(
            value: state.isAutoSilentEnabled,
            onChanged: (val) {
              if (Platform.isIOS) {
                _showIOSHelpDialog(context);
              } else {
                context.read<HomeCubit>().toggleAutoSilent(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequired(BuildContext context, HomeLoaded state) {
    if (Platform.isIOS) {
      return const SizedBox.shrink();
    }

    final missingPermissions = <String>[];
    if (!state.hasDndPermission) missingPermissions.add('Do Not Disturb');
    if (!state.hasBatteryOptimizationPermission) {
      missingPermissions.add('Battery Optimization');
    }
    if (!state.hasExactAlarmPermission) missingPermissions.add('Exact Alarms');
    if (!state.hasLocationPermission) missingPermissions.add('Location Access');

    if (missingPermissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: AppColors.gold05,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.52, color: AppColors.gold18),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Permissions Required',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Please grant all for auto-silent mode to work reliably in background',
                      style: TextStyle(color: AppColors.gold60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!state.hasDndPermission)
            _buildPermissionRow(
              context,
              'Do Not Disturb',
              () => context.read<HomeCubit>().requestDndPermission(),
            ),
          if (!state.hasBatteryOptimizationPermission)
            _buildPermissionRow(
              context,
              'Battery Optimization',
              () => context
                  .read<HomeCubit>()
                  .requestBatteryOptimizationPermission(),
            ),
          if (!state.hasExactAlarmPermission)
            _buildPermissionRow(
              context,
              'Exact Alarms',
              () => context.read<HomeCubit>().requestExactAlarmPermission(),
            ),
          if (!state.hasLocationPermission)
            _buildPermissionRow(
              context,
              'Location Access',
              () => context.read<HomeCubit>().requestLocationPermission(),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $title',
            style: const TextStyle(color: AppColors.gold60, fontSize: 13),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: ShapeDecoration(
                color: AppColors.gold15,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 0.52, color: AppColors.gold25),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIOSHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'iOS Auto Silent Limitations',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apple prevents apps from changing the Ring/Silent switch programmatically.\n\n'
            'We recommend creating a "Personal Automation" in the iOS Shortcuts app to turn on Do Not Disturb automatically at prayer times.',
            style: TextStyle(color: AppColors.mint50),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // --- Setting Widgets Migrated From ScheduleScreen ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.activeGreen,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGlobalSilenceSettings(BuildContext context, HomeLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildDurationSlider(
            context,
            label: 'Minutes Before Prayer',
            value: state.silenceBefore,
            max: 60,
            onChanged: (val) => context.read<HomeCubit>().setSilenceBefore(val),
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildDurationSlider(
            context,
            label: 'Minutes After Prayer',
            value: state.silenceAfter,
            max: 60,
            onChanged: (val) => context.read<HomeCubit>().setSilenceAfter(val),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider(
    BuildContext context, {
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '$value min',
              style: const TextStyle(
                color: AppColors.activeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.activeGreen,
            inactiveTrackColor: AppColors.mint10,
            thumbColor: AppColors.activeGreen,
            overlayColor: AppColors.activeGreen.withValues(alpha: 0.2),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: value.toDouble() > max.toDouble()
                ? max.toDouble()
                : value.toDouble(),
            min: 0,
            max: max.toDouble(),
            divisions: max,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildJumuahSection(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Friday (Jumu\'ah)'),
            AppSwitch(
              value: state.jumuahEnabled,
              onChanged: (val) =>
                  context.read<HomeCubit>().setJumuahEnabled(val),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.jumuahEnabled)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  label: 'Khutba Time',
                  value: state.jumuahKhutbaTime,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(state.jumuahKhutbaTime.split(':')[0]),
                        minute: int.parse(state.jumuahKhutbaTime.split(':')[1]),
                      ),
                    );
                    if (time != null) {
                      final timeStr =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      context.read<HomeCubit>().setJumuahKhutbaTime(timeStr);
                    }
                  },
                ),
                const Divider(color: Colors.white10, height: 16),
                _buildDurationSlider(
                  context,
                  label: 'Silence Duration',
                  value: state.jumuahSilenceDuration,
                  max: 120,
                  onChanged: (val) =>
                      context.read<HomeCubit>().setJumuahSilenceDuration(val),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRamadanSection(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Ramadan (Tarawih)'),
            AppSwitch(
              value: state.ramadanEnabled,
              onChanged: (val) =>
                  context.read<HomeCubit>().setRamadanEnabled(val),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.ramadanEnabled)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _buildDurationSlider(
              context,
              label: 'Tarawih Duration after Isha',
              value: state.tarawihSilenceDuration,
              max: 180,
              onChanged: (val) =>
                  context.read<HomeCubit>().setTarawihSilenceDuration(val),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.activeGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mint45),
            ],
          ),
        ],
      ),
    );
  }
}
