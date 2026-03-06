import 'dart:io';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class SilenceService {
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

  /// Sets the device to Do Not Disturb / Silent Mode.
  Future<void> setSilentMode() async {
    if (Platform.isAndroid) {
      final hasPermission = await hasDndPermission();
      if (hasPermission) {
        await SoundMode.setSoundMode(RingerModeStatus.silent);
      }
    }
  }

  /// Restores the device to standard Ringing/Normal Mode.
  Future<void> restoreNormalMode() async {
    if (Platform.isAndroid) {
      final hasPermission = await hasDndPermission();
      if (hasPermission) {
        await SoundMode.setSoundMode(RingerModeStatus.normal);
      }
    }
  }
}
