import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final loc.Location location = loc.Location();

  // Check if location services are enabled
  static Future<bool> isLocationEnabled() async {
    bool _enabled = await location.serviceEnabled();
    return _enabled;
  }

  // Check if the app has location permissions
  static Future<bool> hasLocationPermissions() async {
    ph.PermissionStatus status = await ph.Permission.location.status;
    return status.isGranted;
  }

  // Request location permissions if not granted
  static Future<void> requestPermissions() async {
    ph.PermissionStatus status = await ph.Permission.location.request();

    if (status.isGranted) {
      print("Location permission granted");
    } else if (status.isDenied) {
      print("Location permission denied");
      // Handle denied permission (prompt user, navigate to settings, etc.)
    } else if (status.isPermanentlyDenied) {
      print("Location permission permanently denied");
      // Open settings to manually enable permission
      // openAppSettings();
    }
  }

  // Open location settings if location services are off
  static Future<void> openLocationSettings() async {
    await location.requestService();
    // Alternatively, use the URL launcher to open location settings on Android
    await openLocationSettingsPage();
  }

  static Future<void> openLocationSettingsPage() async {
    // Open app settings to allow the user to enable the location services
    final Uri settingsUrl = Uri.parse('app-settings:');
    if (await canLaunchUrl(settingsUrl)) {
      await launchUrl(settingsUrl);
    } else {
      print('Could not open location settings');
    }
  }
}
