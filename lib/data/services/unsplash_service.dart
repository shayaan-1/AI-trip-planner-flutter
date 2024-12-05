import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _accessKey = ApiConstants.unsplashAccessKey;
  static const String _imageCachePrefix = 'unsplash_image_';
  static const int _cacheDurationDays = 7;

  static Future<String> fetchImage(String query) async {
    final prefs = await SharedPreferences.getInstance();

    // Check for cached image
    final cachedImageUrl = _getCachedImageUrl(prefs, query);
    if (cachedImageUrl != null) {
      return cachedImageUrl;
    }

    try {
      final url = Uri.parse('$_baseUrl/photos/random?query=$query&client_id=$_accessKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['urls']['regular'];

        // Cache the image URL
        await _cacheImageUrl(prefs, query, imageUrl);

        return imageUrl;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error fetching Unsplash image: $e');
      return '';
    }
  }

  static String? _getCachedImageUrl(SharedPreferences prefs, String query) {
    final cachedImageUrl = prefs.getString('$_imageCachePrefix$query');
    final cacheTimestamp = prefs.getInt('${_imageCachePrefix}timestamp_$query');

    if (cachedImageUrl != null && cacheTimestamp != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = currentTime - cacheTimestamp;

      // Check if cache is less than 7 days old
      if (cacheDuration < Duration(days: _cacheDurationDays).inMilliseconds) {
        return cachedImageUrl;
      }
    }

    return null;
  }

  static Future<void> _cacheImageUrl(
      SharedPreferences prefs,
      String query,
      String imageUrl
      ) async {
    await prefs.setString('$_imageCachePrefix$query', imageUrl);
    await prefs.setInt(
        '${_imageCachePrefix}timestamp_$query',
        DateTime.now().millisecondsSinceEpoch
    );
  }

  // Optional: Method to clear old cache entries
  static Future<void> clearOldImageCache() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_imageCachePrefix) && key.contains('timestamp')) {
        final timestamp = prefs.getInt(key);
        if (timestamp != null) {
          final cacheDuration = currentTime - timestamp;

          if (cacheDuration >= const Duration(days: _cacheDurationDays).inMilliseconds) {
            await prefs.remove(key);
            await prefs.remove(key.replaceAll('timestamp_', ''));
          }
        }
      }
    }
  }

  static Future<void> clearImageCacheOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears all data stored in SharedPreferences
  }
}