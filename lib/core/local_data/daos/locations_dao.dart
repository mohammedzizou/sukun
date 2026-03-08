import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class LocationsDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> insertLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
    String source = 'gps',
    double accuracy = 0.0,
  }) async {
    final db = await dbHelper.database;

    await db.insert('locations', {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'source': source,
      'accuracy': accuracy,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getLastLocation() async {
    final db = await dbHelper.database;

    final maps = await db.query(
      'locations',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
