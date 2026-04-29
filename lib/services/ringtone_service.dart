import 'package:ringtone_set/ringtone_set.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class RingtoneService {
  static Future<bool> setAsRingtone(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // Note: On Android 6.0+, you need to manually grant WRITE_SETTINGS permission.
      // This is a special permission that usually requires an intent to Settings.ACTION_MANAGE_WRITE_SETTINGS.
      // For now, we attempt to set it, which may fail if permission is missing.
      
      final result = await RingtoneSet.setRingtone(filePath);
      return result == "Success";
    } catch (e) {
      if (e.toString().contains("permission")) {
        print("WRITE_SETTINGS permission missing: $e");
      } else {
        print("Error setting ringtone: $e");
      }
      return false;
    }
  }
}
