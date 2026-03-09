import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/local_data/daos/prayer_adjustments_dao.dart';
import 'package:sukun/core/local_data/daos/locations_dao.dart';
import '../../../../home/domain/usecases/get_prayer_times_usecase.dart';
import '../../../../home/presentation/controller/cubit/home_cubit.dart';
import 'prayer_adjustments_state.dart';

class PrayerAdjustmentsCubit extends Cubit<PrayerAdjustmentsState> {
  final PrayerAdjustmentsDao _adjustmentsDao;
  final GetPrayerTimesUseCase _getPrayerTimesUseCase;
  final LocationsDao _locationsDao;

  PrayerAdjustmentsCubit({
    required PrayerAdjustmentsDao adjustmentsDao,
    required GetPrayerTimesUseCase getPrayerTimesUseCase,
    required LocationsDao locationsDao,
  }) : _adjustmentsDao = adjustmentsDao,
       _getPrayerTimesUseCase = getPrayerTimesUseCase,
       _locationsDao = locationsDao,
       super(const PrayerAdjustmentsState()) {
    loadAdjustments();
  }

  Future<void> loadAdjustments() async {
    emit(state.copyWith(isLoading: true));
    try {
      final adjustments = await _adjustmentsDao.getAllAdjustments();

      // Fetch location
      final locationMap = await _locationsDao.getLastLocation();
      final city = locationMap?['city'] ?? 'Mecca';
      final country = locationMap?['country'] ?? 'Saudi Arabia';
      final latitude = locationMap?['latitude'] ?? 21.422487;
      final longitude = locationMap?['longitude'] ?? 39.826206;

      // Fetch prayer times for today to show current times
      final result = await _getPrayerTimesUseCase(
        GetPrayerTimesParams(
          city: city,
          country: country,
          latitude: latitude,
          longitude: longitude,
          date: DateTime.now(),
        ),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Failed to load prayer times',
            ),
          );
        },
        (prayerTimes) {
          emit(
            state.copyWith(
              isLoading: false,
              prayers: prayerTimes.prayers,
              adjustments: adjustments,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateAdjustment(String prayerName, int delta) async {
    final currentOffset = state.adjustments[prayerName] ?? 0;
    final newOffset = currentOffset + delta;
    await _adjustmentsDao.upsertAdjustment(prayerName, newOffset);
    final newAdjustments = Map<String, int>.from(state.adjustments);
    newAdjustments[prayerName] = newOffset;
    emit(state.copyWith(adjustments: newAdjustments));

    // Trigger home refresh in background
    if (getIt.isRegistered<HomeCubit>()) {
      getIt<HomeCubit>().refreshHome();
    }

    // Instead of loadAdjustments (which shows spinner), silently reload
    _silentReload();
  }

  Future<void> _silentReload() async {
    try {
      final locationMap = await _locationsDao.getLastLocation();
      final city = locationMap?['city'] ?? 'Mecca';
      final country = locationMap?['country'] ?? 'Saudi Arabia';
      final latitude = locationMap?['latitude'] ?? 21.422487;
      final longitude = locationMap?['longitude'] ?? 39.826206;

      final result = await _getPrayerTimesUseCase(
        GetPrayerTimesParams(
          city: city,
          country: country,
          latitude: latitude,
          longitude: longitude,
          date: DateTime.now(),
        ),
      );

      result.fold((failure) {}, (prayerTimes) {
        emit(state.copyWith(prayers: prayerTimes.prayers));
      });
    } catch (_) {}
  }
}
