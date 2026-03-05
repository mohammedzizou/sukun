import 'dart:io';

/// Checks if the device has an active internet connection by attempting to lookup the IP address of "google.com".
/// Returns `true` if the device is connected to the internet, otherwise returns `false`.
Future checkInternet() async {
  try {
    var result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}
