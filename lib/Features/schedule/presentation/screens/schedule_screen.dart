import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/usecases/get_schedule_by_date.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/widgets/horizontal_date_selector.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/widgets/prayer_toggle_row.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScheduleCubit(getScheduleUseCase: GetScheduleByDate())
            ..loadInitialSchedule(),
      child: const _ScheduleScreenContent(),
    );
  }
}

class _ScheduleScreenContent extends StatelessWidget {
  const _ScheduleScreenContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildDateSelector(context),
          const SizedBox(height: 24),
          _buildScheduleList(),
          _buildFooterText(),
        ],
      ),
    );
  }

  Widget _buildFooterText() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Center(
        child: Text(
          'Toggle silent mode individually per prayer. Settings apply to all future days.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mint45, fontSize: 12, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          final dateStr = DateFormat(
            'EEEE, MMMM d, yyyy',
          ).format(state.selectedDate);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppColors
                      .mint50, // Matches Map Pin Subtitle text in Figma
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      buildWhen: (previous, current) =>
          previous.selectedDate != current.selectedDate,
      builder: (context, state) {
        return HorizontalDateSelector(
          selectedDate: state.selectedDate,
          onDateSelected: (newDate) {
            context.read<ScheduleCubit>().selectDate(newDate);
          },
        );
      },
    );
  }

  Widget _buildScheduleList() {
    return Expanded(
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          } else if (state is ScheduleLoaded) {
            if (state.schedule.prayers.isEmpty) {
              return const Center(
                child: Text(
                  'No prayers found.',
                  style: TextStyle(color: AppColors.mint50),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: state.schedule.prayers.length,
              itemBuilder: (context, index) {
                final prayer = state.schedule.prayers[index];
                return PrayerToggleRow(
                  prayer: prayer,
                  onToggle: (val) {
                    context.read<ScheduleCubit>().toggleSilentForPrayer(index);
                  },
                );
              },
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
    );
  }
}
