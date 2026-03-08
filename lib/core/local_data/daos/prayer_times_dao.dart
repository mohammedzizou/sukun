import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class PrayerTimesDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> insertDailyPrayerTimes({
    required DateTime date,
    required String fajr,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required double latitude,
    required double longitude,
    required int calculationMethod,
  }) async {
    final db = await dbHelper.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    await db.insert('prayer_times', {
      'date': dateString,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'latitude': latitude,
      'longitude': longitude,
      'calculation_method': calculationMethod,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getPrayerTimesForDate(DateTime date) async {
    final db = await dbHelper.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final maps = await db.query(
      'prayer_times',
      where: 'date = ?',
      whereArgs: [dateString],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
