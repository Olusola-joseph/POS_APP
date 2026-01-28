import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request necessary permissions for the app
  static Future<Map<Permission, PermissionStatus>> requestAppPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.phone,
    ].request();

    return permissions;
  }

  // Check if all required permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    // Check location permission
    PermissionStatus locationStatus = await Permission.location.status;
    if (locationStatus != PermissionStatus.granted) {
      return false;
    }

    // Check camera permission
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (cameraStatus != PermissionStatus.granted) {
      return false;
    }

    // Check storage permission
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      return false;
    }

    return true;
  }

  // Request a specific permission
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  // Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    PermissionStatus status = await permission.status;
    return status == PermissionStatus.granted;
  }

  // Open app settings to allow user to manually grant permissions
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}