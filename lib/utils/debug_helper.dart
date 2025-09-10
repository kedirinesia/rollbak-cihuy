import 'package:flutter/foundation.dart';

/// Debug helper utility for consistent debug printing across the app
/// This ensures debug prints are only shown in debug builds
class DebugHelper {
  /// Print debug message only in debug mode
  static void debugPrint(String message) {
    if (kDebugMode) {
      print('$message');
    }
  }

  /// Print debug message with tag only in debug mode
  static void debugPrintWithTag(String tag, String message) {
    if (kDebugMode) {
      print('[DEBUG-$tag] $message');
    }
  }

  /// Print debug message with emoji only in debug mode
  static void debugPrintWithEmoji(String emoji, String message) {
    if (kDebugMode) {
      print('$emoji [DEBUG] $message');
    }
  }

  /// Print API debug info only in debug mode
  static void debugApi(String endpoint, String message) {
    if (kDebugMode) {
      print('[DEBUG-API-$endpoint] $message');
    }
  }

  /// Print transaction debug info only in debug mode
  static void debugTransaction(String transactionId, String message) {
    if (kDebugMode) {
      print('[DEBUG-TRX-$transactionId] $message');
    }
  }

  /// Print error debug info only in debug mode
  static void debugError(String context, String error) {
    if (kDebugMode) {
      print('[DEBUG-ERROR-$context] $error');
    }
  }

  /// Print form debug info only in debug mode
  static void debugForm(String formName, String message) {
    if (kDebugMode) {
      print('[DEBUG-FORM-$formName] $message');
    }
  }

  /// Print bluetooth debug info only in debug mode
  static void debugBluetooth(String message) {
    if (kDebugMode) {
      print('[DEBUG-BLUETOOTH] $message');
    }
  }

  /// Print network debug info only in debug mode
  static void debugNetwork(String message) {
    if (kDebugMode) {
      print('[DEBUG-NETWORK] $message');
    }
  }
}


