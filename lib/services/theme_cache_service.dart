import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service that downloads and caches theme images locally for offline use.
class ThemeCacheService {
  static ThemeCacheService? _instance;
  late Directory _cacheDir;
  final Map<String, String> _urlToLocalPath = {};
  bool _initialized = false;

  ThemeCacheService._();

  static ThemeCacheService get instance {
    _instance ??= ThemeCacheService._();
    return _instance!;
  }

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/theme_cache');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
    await _loadExistingCache();
    _initialized = true;
  }

  Future<void> _loadExistingCache() async {
    try {
      final files = _cacheDir.listSync();
      for (final file in files) {
        if (file is File && file.path.endsWith('.meta')) {
          final url = await file.readAsString();
          final imgPath = file.path.replaceAll('.meta', '');
          if (File(imgPath).existsSync()) {
            _urlToLocalPath[url] = imgPath;
          }
        }
      }
    } catch (e) {
      debugPrint('ThemeCacheService: Error loading cache: $e');
    }
  }

  String _getFileName(String url) {
    final hash = url.hashCode.toUnsigned(32).toRadixString(16);
    return 'theme_$hash.jpg';
  }

  bool isCached(String url) {
    if (!_initialized) return false;
    final p = _urlToLocalPath[url];
    return p != null && File(p).existsSync();
  }

  String? getCachedPath(String url) {
    if (!_initialized) return null;
    final p = _urlToLocalPath[url];
    if (p != null && File(p).existsSync()) return p;
    return null;
  }

  Future<String?> cacheImage(String url) async {
    if (!_initialized) await init();
    final existing = getCachedPath(url);
    if (existing != null) return existing;

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final file = File('${_cacheDir.path}/${_getFileName(url)}');
        await file.writeAsBytes(bytes);
        await File('${file.path}.meta').writeAsString(url);
        _urlToLocalPath[url] = file.path;
        client.close();
        return file.path;
      }
      client.close();
    } catch (e) {
      debugPrint('ThemeCacheService: Failed to cache $url: $e');
    }
    return null;
  }

  Future<Map<String, String>> cacheImages(List<String> urls, {
    void Function(int cached, int total)? onProgress,
  }) async {
    if (!_initialized) await init();
    final results = <String, String>{};
    for (int i = 0; i < urls.length; i++) {
      final path = await cacheImage(urls[i]);
      if (path != null) results[urls[i]] = path;
      onProgress?.call(i + 1, urls.length);
    }
    return results;
  }

  Future<void> clearCache() async {
    if (!_initialized) await init();
    try {
      for (final file in _cacheDir.listSync()) {
        if (file is File) await file.delete();
      }
      _urlToLocalPath.clear();
    } catch (e) {
      debugPrint('ThemeCacheService: Error clearing cache: $e');
    }
  }
}
