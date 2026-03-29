import 'dart:io';
import 'package:sound_mode/sound_mode.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class SilenceService {
  /// Gets the current ringer mode of the device
  Future<RingerModeStatus> getCurrentRingerMode() async {
    if (Platform.isAndroid) {
      try {
        return await SoundMode.ringerModeStatus;
      } catch (e) {
        return RingerModeStatus.unknown;
      }
    }
    return RingerModeStatus.unknown;
  }
  /// Checks if the app has permission to manage Do Not Disturb mode.
  /// On iOS, this always returns false currently as we cannot programmatically
  /// change DND/Focus modes without user intervention.
  Future<bool> hasDndPermission() async {
    if (Platform.isAndroid) {
      bool? isGranted = await PermissionHandler.permissionsGranted;
      return isGranted ?? false;
    }
    return false; // iOS does not allow programmatical DND toggles easily
  }

  /// Redirects the user to the device settings to grant DND permission.
  Future<void> requestDndPermission() async {
    if (Platform.isAndroid) {
      await PermissionHandler.openDoNotDisturbSetting();
    }
    // For iOS, we typically show instructions to set up a Focus mode automation.
  }

  Future<bool> hasBatteryOptimizationPermission() async {
    if (Platform.isAndroid) {
      return await ph.Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true; // Not applicable for iOS in this context
  }

  Future<void> requestBatteryOptimizationPermission() async {
    if (Platform.isAndroid) {
      await ph.Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<bool> hasExactAlarmPermission() async {
    if (Platform.isAndroid) {
      return await ph.Permission.scheduleExactAlarm.isGranted;
    }
    return true; // Not applicable for iOS
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      // Directs the user to the exact alarm settings page for the app
      await ph.Permission.scheduleExactAlarm.request();
    }
  }

  /// Sets the device to Do Not Disturb / Silent Mode or Vibrate.
  Future<void> setSilentMode({bool vibrate = false}) async {
    if (Platform.isAndroid) {
      final hasPermission = await hasDndPermission();
      if (hasPermission) {
        await SoundMode.setSoundMode(
          vibrate ? RingerModeStatus.vibrate : RingerModeStatus.silent,
        );
      }
    }
  }

  /// Alias for setSilentMode
  Future<void> enableSilentMode({bool vibrate = false}) =>
      setSilentMode(vibrate: vibrate);

  /// Restores the device to standard Ringing/Normal Mode.
  Future<void> restoreNormalMode() async {
    if (Platform.isAndroid) {
      final hasPermission = await hasDndPermission();
      if (hasPermission) {
        await SoundMode.setSoundMode(RingerModeStatus.normal);
      }
    }
  }

  /// Alias for restoreNormalMode as requested
  Future<void> disableSilentMode() => restoreNormalMode();
}
