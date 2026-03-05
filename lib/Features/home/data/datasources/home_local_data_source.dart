import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';

abstract class HomeLocalDataSource {
  Future<void> cachePrayerTimes(DailyPrayerTimesModel prayerTimes);
  Future<DailyPrayerTimesModel?> getLastPrayerTimes();
}

const String cachedPrayerTimesKey = "CACHED_PRAYER_TIMES";

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences sharedPreferences;

  HomeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cachePrayerTimes(DailyPrayerTimesModel prayerTimes) async {
    await sharedPreferences.setString(
      cachedPrayerTimesKey,
      json.encode(prayerTimes.toJson()),
    );
  }

  @override
  Future<DailyPrayerTimesModel?> getLastPrayerTimes() async {
    final jsonString = sharedPreferences.getString(cachedPrayerTimesKey);
    if (jsonString != null) {
      return DailyPrayerTimesModel.fromLocalJson(json.decode(jsonString));
    }
    return null;
  }
}
