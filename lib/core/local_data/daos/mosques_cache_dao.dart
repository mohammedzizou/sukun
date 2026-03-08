import 'package:sqflite/sqflite.dart';
import '../local_db.dart';

class MosquesCacheDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> cacheMosques(List<Map<String, dynamic>> mosques) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    // Clear old cache optionally before adding new near ones
    batch.delete('mosques_cache');

    for (var mosque in mosques) {
      batch.insert('mosques_cache', {
        'place_id': mosque['place_id'],
        'name': mosque['name'],
        'address': mosque['address'],
        'latitude': mosque['latitude'],
        'longitude': mosque['longitude'],
        'distance': mosque['distance'],
        'cached_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedMosques() async {
    final db = await dbHelper.database;
    return await db.query('mosques_cache');
  }
}
