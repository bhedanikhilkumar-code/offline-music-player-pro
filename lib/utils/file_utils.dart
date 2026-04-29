import 'dart:io';

class FileUtils {
  static String getFileName(String path) {
    return path.split('/').last;
  }

  static String getFileNameWithoutExtension(String path) {
    final name = getFileName(path);
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(0, dotIndex) : name;
  }

  static String getFileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    return dotIndex > 0 ? path.substring(dotIndex + 1) : '';
  }

  static String getFolderPath(String filePath) {
    final lastSlash = filePath.lastIndexOf('/');
    return lastSlash > 0 ? filePath.substring(0, lastSlash) : '/';
  }

  static String getFolderName(String filePath) {
    final folder = getFolderPath(filePath);
    return folder.split('/').last;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
