import 'package:geolocator/geolocator.dart';
import '../local_data/daos/mosques_cache_dao.dart';
import '../local_data/daos/silent_logs_dao.dart';
import 'silence_service.dart';

class MosqueDetectionService {
  final MosquesCacheDao mosquesCacheDao;
  final SilentLogsDao silentLogsDao;
  final SilenceService silenceService;

  MosqueDetectionService({
    required this.mosquesCacheDao,
    required this.silentLogsDao,
    required this.silenceService,
  });

  /// This should be called periodically by a background isolate (e.g. Workmanager)
  /// checks if device is near a mosque.
  Future<void> checkNearMosque(Position currentPosition) async {
    final cachedMosques = await mosquesCacheDao.getCachedMosques();

    if (cachedMosques.isEmpty) return;

    for (var mosque in cachedMosques) {
      final double mLat = mosque['latitude'];
      final double mLng = mosque['longitude'];

      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        mLat,
        mLng,
      );

      // Within 50 meters
      if (distance <= 50) {
        // Activate silence mode
        await silenceService.setSilentMode();

        // Log the event
        await silentLogsDao.logSilentEvent(
          date: DateTime.now(),
          prayerName: 'Mosque detection near ${mosque['name']}',
          actualStart: DateTime.now(),
          triggerType: 'mosque',
          status: 'success',
        );

        // Break early since we found a mosque and silenced the device
        break;
      }
    }
  }
}
