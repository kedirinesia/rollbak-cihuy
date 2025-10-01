
import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/debug_helper.dart';

class Api {
  final String host = apiUrl;

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      DebugHelper.debugPrint('Connectivity check error: $e');
      return false;
    }
  }

  Future<dynamic> get(String path,
      {bool cache = false,
      bool auth = true,
      Duration expired = const Duration(hours: 1),
      bool forceRefresh = false}) async {
    if (host.isEmpty) {
      throw FormatException('API host is not configured');
    }

    String url = '$host$path';
    DebugHelper.debugPrint('Making GET request to: $url (forceRefresh: $forceRefresh)');

    // Check network connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      throw FormatException('No internet connection available');
    }

    if (cache && !forceRefresh) {
      try {
        FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(url);
        if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
          DebugHelper.debugPrint('Using cached data for: $url');
          if (fileInfo.file.existsSync()) {
            return json.decode(fileInfo.file.readAsStringSync());
          }
        }
      } catch (e) {
        DebugHelper.debugPrint('Cache read error: $e');
        // Continue with network request if cache fails
      }
    }
    
    // If force refresh, clear cache for this URL
    if (forceRefresh) {
      try {
        await DefaultCacheManager().removeFile(url);
        DebugHelper.debugPrint('Cache cleared for: $url');
      } catch (e) {
        DebugHelper.debugPrint('Error clearing cache for $url: $e');
        // Continue with request even if cache clearing fails
      }
    }

    try {
      Map<String, String> headers = {
        'merchantcode': sigVendor,
      };

      if (auth && bloc.token.valueWrapper?.value != null) {
        headers['Authorization'] = bloc.token.valueWrapper!.value;
      }

      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw FormatException('Request timeout - server took too long to respond');
        },
      );

      DebugHelper.debugPrint('Response status code: ${response.statusCode}');
      DebugHelper.debugPrint('Response headers: ${response.headers}');
      String bodyPreview = response.body;
      if (bodyPreview.length > 200) {
        bodyPreview = bodyPreview.substring(0, 200) + '...';
      }
      DebugHelper.debugPrint('Response body preview: $bodyPreview');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') == true || 
            response.body.trim().startsWith('{') || 
            response.body.trim().startsWith('[')) {
          try {
            final decoded = json.decode(response.body);
            dynamic data;
            if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
              data = decoded['data'];
            } else {
              // Fallback: some endpoints return payload at the root
              data = decoded;
            }
            // Cache the response
            try {
              await DefaultCacheManager().putFile(
                url,
                utf8.encode(json.encode(data)),
                maxAge: Duration(hours: 1),
              );
              DebugHelper.debugPrint('Response cached for: $url');
            } catch (e) {
              DebugHelper.debugPrint('Failed to cache response: $e');
              // Continue without caching
            }
            return data;
          } catch (e) {
            DebugHelper.debugPrint('JSON parsing error: $e');
            DebugHelper.debugPrint('Response body: ${response.body}');
            throw FormatException('Invalid JSON response from server: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
        } else {
          DebugHelper.debugPrint('Server returned non-JSON response');
          DebugHelper.debugPrint('DEBUG: Content-Type: ${response.headers['content-type']}');
          DebugHelper.debugPrint('Response body: ${response.body}');
          throw FormatException('Server returned HTML instead of JSON. This usually indicates a server error or maintenance.');
        }
      } else {
        // Try to parse error response as JSON
        try {
          dynamic errorData = json.decode(response.body);
          throw errorData;
        } catch (e) {
          DebugHelper.debugPrint('Error response is not JSON: ${response.body}');
          throw FormatException('Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        }
      }
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      DebugHelper.debugPrint('Network error: $e');
      throw FormatException('Network error: $e');
    }
  }

  Future<dynamic> post(
    String path, {
    bool auth = true,
    Map<String, dynamic> data = const {},
  }) async {
    if (host.isEmpty) {
      throw FormatException('API host is not configured');
    }

    String url = '$host$path';
    DebugHelper.debugPrint('Making POST request to: $url');

    // Check network connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      throw FormatException('No internet connection available');
    }

    try {
      Map<String, String> headers = {
        'merchantcode': sigVendor,
        'Content-Type': 'application/json',
      };

      if (auth && bloc.token.valueWrapper?.value != null) {
        headers['Authorization'] = bloc.token.valueWrapper!.value;
      }

      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw FormatException('Request timeout - server took too long to respond');
        },
      );

      DebugHelper.debugPrint('Response status code: ${response.statusCode}');
      DebugHelper.debugPrint('Response headers: ${response.headers}');
      String bodyPreview = response.body;
      if (bodyPreview.length > 200) {
        bodyPreview = bodyPreview.substring(0, 200) + '...';
      }
      DebugHelper.debugPrint('Response body preview: $bodyPreview');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') == true ||
            response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          try {
            final decoded = json.decode(response.body);
            dynamic data;
            if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
              data = decoded['data'];
            } else {
              // Fallback: some endpoints return payload at the root
              data = decoded;
            }
            return data;
          } catch (e) {
            DebugHelper.debugPrint('JSON parsing error: $e');
            DebugHelper.debugPrint('Response body: ${response.body}');
            throw FormatException('Invalid JSON response from server: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
        } else {
          DebugHelper.debugPrint('Server returned non-JSON response');
          DebugHelper.debugPrint('DEBUG: Content-Type: ${response.headers['content-type']}');
          DebugHelper.debugPrint('Response body: ${response.body}');
          throw FormatException('Server returned HTML instead of JSON. This usually indicates a server error or maintenance.');
        }
      } else {
        // Try to parse error response as JSON
        try {
          dynamic errorData = json.decode(response.body);
          throw errorData;
        } catch (e) {
          DebugHelper.debugPrint('Error response is not JSON: ${response.body}');
          throw FormatException('Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        }
      }
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      DebugHelper.debugPrint('Network error: $e');
      throw FormatException('Network error: $e');
    }
  }
}

Api api = Api();
