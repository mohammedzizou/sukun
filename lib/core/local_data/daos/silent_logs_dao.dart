import 'package:intl/intl.dart';
import '../local_db.dart';

class SilentLogsDao {
  final DBHelper dbHelper = DBHelper.instance;

  Future<void> logSilentEvent({
    required DateTime date,
    required String prayerName,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    required DateTime actualStart,
    DateTime? actualEnd,
    required String triggerType, // 'scheduled' or 'mosque'
    required String status,
  }) async {
    final db = await dbHelper.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    await db.insert('silent_logs', {
      'date': dateString,
      'prayer_name': prayerName,
      'scheduled_start': scheduledStart?.toIso8601String(),
      'scheduled_end': scheduledEnd?.toIso8601String(),
      'actual_start': actualStart.toIso8601String(),
      'actual_end': actualEnd?.toIso8601String(),
      'trigger_type': triggerType,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
