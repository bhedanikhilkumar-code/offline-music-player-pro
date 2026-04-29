import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all required permissions for the music player
  static Future<bool> requestStoragePermission() async {
    // Android 13+ uses granular media permissions
    if (Platform.isAndroid) {
      // Try READ_MEDIA_AUDIO first (Android 13+)
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;

      // Fallback to storage permission (Android < 13)
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;

      // If both denied, check if we can request again
      if (audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
        return false;
      }

      return false;
    }
    return true;
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check if storage/audio permission is granted
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final audioGranted = await Permission.audio.isGranted;
      if (audioGranted) return true;
      final storageGranted = await Permission.storage.isGranted;
      return storageGranted;
    }
    return true;
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
