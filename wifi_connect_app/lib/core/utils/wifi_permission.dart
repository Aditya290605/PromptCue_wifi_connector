import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    var status = await Permission.location.status;
    return status.isGranted;
  }
}
