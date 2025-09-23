// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/utils/debug_helper.dart';

class Api {
  final String host = apiUrl;

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<dynamic> get(String path,
      {bool cache = false,
      bool auth = true,
      Duration expired = const Duration(hours: 1),
      bool forceRefresh = false}) async {
    String url = '$host$path';
    DebugHelper.debugPrint('Making GET request to: $url (forceRefresh: $forceRefresh)');

    // Check network connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      throw FormatException('No internet connection available');
    }

    if (cache && !forceRefresh) {
      FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        DebugHelper.debugPrint('Using cached data for: $url');
        return json.decode(fileInfo.file.readAsStringSync());
      }
    }
    
    // If force refresh, clear cache for this URL
    if (forceRefresh) {
      try {
        await DefaultCacheManager().removeFile(url);
        DebugHelper.debugPrint('Cache cleared for: $url');
      } catch (e) {
        DebugHelper.debugPrint('Error clearing cache: $e');
      }
    }

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': auth ? bloc.token.valueWrapper?.value : null,
          'merchantcode': sigVendor,
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw FormatException('Request timeout - server took too long to respond');
        },
      );

      DebugHelper.debugPrint('Response status code: ${response.statusCode}');
      DebugHelper.debugPrint('Response headers: ${response.headers}');
      DebugHelper.debugPrint('Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') == true || 
            response.body.trim().startsWith('{') || 
            response.body.trim().startsWith('[')) {
          try {
            dynamic data = json.decode(response.body)['data'];
            DefaultCacheManager().putFile(
              '$url',
              toBytes(json.encode(data)),
              maxAge: Duration(hours: 1),
            );
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
    String url = '$host$path';
    DebugHelper.debugPrint('Making POST request to: $url');

    // Check network connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      throw FormatException('No internet connection available');
    }

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': auth ? bloc.token.valueWrapper?.value : null,
          'merchantcode': sigVendor,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw FormatException('Request timeout - server took too long to respond');
        },
      );

      DebugHelper.debugPrint('Response status code: ${response.statusCode}');
      DebugHelper.debugPrint('Response headers: ${response.headers}');
      DebugHelper.debugPrint('Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') == true || 
            response.body.trim().startsWith('{') || 
            response.body.trim().startsWith('[')) {
          try {
            dynamic data = json.decode(response.body);
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
      if (e is Map<String, dynamic>) {
        rethrow; // Re-throw JSON error responses
      }
      DebugHelper.debugPrint('Network error: $e');
      throw FormatException('Network error: $e');
    }
  }
}

Api api = Api();
