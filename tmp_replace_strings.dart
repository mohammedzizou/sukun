import 'dart:io';

void main() async {
  final files = [
    'lib/features/home/presentation/screens/home_screen.dart',
    'lib/features/settings/presentation/screens/settings_screen.dart',
    'lib/features/settings/presentation/screens/prayer_adjustments_screen.dart',
  ];

  final keys = [
    "Good Night",
    "Assalamu Alaikum",
    "NEXT PRAYER",
    "Prayer time",
    "TIME REMAINING",
    "TODAY'S PRAYERS",
    "Auto Silent Mode",
    "Tap to enable automatic silencing",
    "Permissions Required",
    "Please grant all for auto-silent mode to work reliably in background",
    "Do Not Disturb",
    "Battery Optimization",
    "Exact Alarms",
    "Location Access",
    "Enable",
    "iOS Auto Silent Limitations",
    "Got it",
    "Global Silence Settings",
    "Minutes Before Prayer",
    "Minutes After Prayer",
    "Friday (Jumu\\'ah)",
    "Khutba Time",
    "Silence Duration",
    "Retry",
    "Settings",
    "Manage your profile and application preferences",
    "APPEARANCE",
    "GENERAL",
    "Language",
    "Application display language",
    "English",
    "Arabic",
    "French",
    "PRAYER SILENCE BEHAVIOR",
    "Restore previous sound mode",
    "Return to your ringtone level after prayer",
    "Vibrate instead of silent",
    "Phone will vibrate during prayer",
    "LOCATION & CALCULATION",
    "Prayer Time Adjustments",
    "Manually add or subtract minutes",
    "Calculation method",
    "Used to determine prayer times",
    "Muslim World League",
    "Islamic Society of North America",
    "Egyptian General Authority",
    "Umm Al-Qura, Makkah",
    "University of Islamic Sciences, Karachi",
    "ABOUT",
    "About Salah Silent",
    "Version 1.0.0",
    "Privacy Policy",
    "Prayer Adjustments",
    "Current: ",
    " min",
  ];

  for (final file in files) {
    var content = await File(file).readAsString();

    bool changed = false;

    // Check if get is imported
    if (!content.contains("import 'package:get/get.dart';")) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:get/get.dart';",
      );
      changed = true;
    }

    for (final key in keys) {
      // Replace 'Key' with 'Key'.tr
      // Escape special regex characters in the key
      final escapedKey = RegExp.escape(key.replaceAll("\\'", "'"));

      // Look for strings in single or double quotes
      final regex1 = RegExp("'$escapedKey'(?!.tr)");
      final regex2 = RegExp("\"$escapedKey\"(?!.tr)");

      if (regex1.hasMatch(content) || regex2.hasMatch(content)) {
        content = content.replaceAllMapped(regex1, (match) => "'$key'.tr");
        content = content.replaceAllMapped(regex2, (match) => "\"$key\".tr");
        changed = true;
      }
    }

    // Handle "Salah Silent v1.0.0 · Made with ☪ for the Ummah" separately due to unicode
    if (content.contains("'Salah Silent v1.0.0 · Made with ☪ for the Ummah'")) {
      content = content.replaceAll(
        "'Salah Silent v1.0.0 · Made with ☪ for the Ummah'",
        "'Salah Silent v1.0.0 · Made with ☪ for the Ummah'.tr",
      );
      changed = true;
    }

    // Handle the long Apple message separately
    final appleMsg =
        "Apple prevents apps from changing the Ring/Silent switch programmatically.\\n\\n"
        "We recommend creating a \\\"Personal Automation\\\" in the iOS Shortcuts app to turn on Do Not Disturb automatically at prayer times.";
    if (content.contains(appleMsg)) {
      content = content.replaceAll(
        appleMsg,
        "$appleMsg'.tr",
      ); // Wait, this might be split across lines. It's written as one string in dart.
    }

    if (changed) {
      await File(file).writeAsString(content);
      print('Updated \$file');
    }
  }
}
