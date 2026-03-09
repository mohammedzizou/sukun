import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class PrayerAdjustmentsDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> upsertAdjustment(String prayerName, int offsetMinutes) async {
    final db = await dbHelper.database;
    await db.insert('prayer_adjustments', {
      'prayer_name': prayerName,
      'offset_minutes': offsetMinutes,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, int>> getAllAdjustments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prayer_adjustments',
    );

    return {
      for (var map in maps)
        map['prayer_name'] as String: map['offset_minutes'] as int,
    };
  }

  Future<int> getAdjustmentForPrayer(String prayerName) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prayer_adjustments',
      where: 'prayer_name = ?',
      whereArgs: [prayerName],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['offset_minutes'] as int;
    }
    return 0;
  }
}
