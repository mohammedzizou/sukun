import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/core/di/dipendency_injection.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/widgets/prayer_toggle_row.dart';
import 'package:prayer_silence_time_app/core/widgets/app_switch.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ScheduleCubit>()..loadInitialSchedule(),
      child: const _ScheduleScreenContent(),
    );
  }
}

class _ScheduleScreenContent extends StatelessWidget {
  const _ScheduleScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            } else if (state is ScheduleLoaded) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Daily Prayers'),
                  const SizedBox(height: 8),
                  _buildGlobalSilenceSettings(context, state),
                  const SizedBox(height: 16),
                  ...state.prayers.asMap().entries.map((entry) {
                    return PrayerToggleRow(
                      prayer: entry.value,
                      onToggle: (val) {
                        context.read<ScheduleCubit>().toggleSilentForPrayer(
                          entry.key,
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                  _buildJumuahSection(context, state),
                  const SizedBox(height: 24),
                  _buildRamadanSection(context, state),
                  const SizedBox(height: 40),
                ],
              );
            } else if (state is ScheduleError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Configure automatic silent mode',
          style: TextStyle(color: AppColors.mint50, fontSize: 14),
        ),
      ],
    );
  }

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

  Widget _buildGlobalSilenceSettings(
    BuildContext context,
    ScheduleLoaded state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildDurationPicker(
            label: 'Minutes Before Prayer',
            value: state.silenceBefore,
            onChanged: (val) =>
                context.read<ScheduleCubit>().setSilenceBefore(val),
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildDurationPicker(
            label: 'Minutes After Prayer',
            value: state.silenceAfter,
            onChanged: (val) =>
                context.read<ScheduleCubit>().setSilenceAfter(val),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPicker({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.mint45,
                size: 20,
              ),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.activeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.mint45,
                size: 20,
              ),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJumuahSection(BuildContext context, ScheduleLoaded state) {
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
                  context.read<ScheduleCubit>().setJumuahEnabled(val),
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
                      context.read<ScheduleCubit>().setJumuahKhutbaTime(
                        timeStr,
                      );
                    }
                  },
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildDurationPicker(
                  label: 'Silence Duration (min)',
                  value: state.jumuahSilenceDuration,
                  onChanged: (val) => context
                      .read<ScheduleCubit>()
                      .setJumuahSilenceDuration(val),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRamadanSection(BuildContext context, ScheduleLoaded state) {
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
                  context.read<ScheduleCubit>().setRamadanEnabled(val),
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
            child: _buildDurationPicker(
              label: 'Tarawih Duration after Isha (min)',
              value: state.tarawihSilenceDuration,
              onChanged: (val) =>
                  context.read<ScheduleCubit>().setTarawihSilenceDuration(val),
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
