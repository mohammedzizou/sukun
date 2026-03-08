import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class UserSettingsDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> upsertUserSettings({
    int autoLocation = 1,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    int calculationMethod = 3, // Muslim World League default
    String timezone = '',
    String language = 'en',
  }) async {
    final db = await dbHelper.database;

    await db.insert('user_settings', {
      'id': 1, // Enforce single row
      'auto_location': autoLocation,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'city': ?city,
      'country': ?country,
      'calculation_method': calculationMethod,
      'timezone': timezone,
      'language': language,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    final db = await dbHelper.database;

    final maps = await db.query(
      'user_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
