import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sukun/features/home/domain/usecases/get_prayer_times_usecase.dart';
import '../cubit/prayer_adjustments/prayer_adjustments_cubit.dart';
import '../cubit/prayer_adjustments/prayer_adjustments_state.dart';
import '../../../../core/local_data/daos/prayer_adjustments_dao.dart';
import '../../../../core/local_data/daos/locations_dao.dart';

class PrayerAdjustmentsScreen extends StatelessWidget {
  const PrayerAdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrayerAdjustmentsCubit(
        adjustmentsDao: GetIt.instance<PrayerAdjustmentsDao>(),
        getPrayerTimesUseCase: GetIt.instance<GetPrayerTimesUseCase>(),
        locationsDao: GetIt.instance<LocationsDao>(),
      ),
      child: const _PrayerAdjustmentsView(),
    );
  }
}

class _PrayerAdjustmentsView extends StatelessWidget {
  const _PrayerAdjustmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Prayer Adjustments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFF081C15), Color(0xFF0B2E22)],
          ),
        ),
        child: BlocBuilder<PrayerAdjustmentsCubit, PrayerAdjustmentsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
              );
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.prayers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final prayer = state.prayers[index];
                final adjustment = state.adjustments[prayer.name] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.5,
                        color: Color(0x16A3F7BF),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Current: ${prayer.time}',
                              style: const TextStyle(
                                color: Color(0xB2A3F7BF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _AdjustmentButton(
                            icon: Icons.remove,
                            onTap: () => context
                                .read<PrayerAdjustmentsCubit>()
                                .updateAdjustment(prayer.name, -1),
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '${adjustment >= 0 ? '+' : ''}$adjustment min',
                              style: TextStyle(
                                color: adjustment == 0
                                    ? Colors.white70
                                    : const Color(0xFF2ECC71),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _AdjustmentButton(
                            icon: Icons.add,
                            onTap: () => context
                                .read<PrayerAdjustmentsCubit>()
                                .updateAdjustment(prayer.name, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdjustmentButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdjustmentButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0x232ECC71),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2ECC71), size: 18),
      ),
    );
  }
}
