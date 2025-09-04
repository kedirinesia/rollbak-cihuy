import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class BluetoothModernHelper {
  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  
  /// Modern connection approach for Android 11+
  static Future<bool> connectWithModernApproach(
    BluetoothDevice device, {
    int maxRetries = 3,
    int timeoutSeconds = 45,
  }) async {
    print('BluetoothModernHelper: Using modern approach for Android 11+');
    
    try {
      // Step 1: Complete cleanup
      await _completeCleanup();
      
      // Step 2: Wait for system to stabilize
      await Future.delayed(Duration(seconds: 2));
      
      // Step 3: Try modern connection method
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print('BluetoothModernHelper: Modern attempt $attempt/$maxRetries');
          
          bool connected = await _modernConnectionMethod(
            device, 
            timeoutSeconds: timeoutSeconds,
          );
          
          if (connected) {
            print('BluetoothModernHelper: Modern connection successful');
            return true;
          }
          
          // Wait between attempts
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 3));
            await _completeCleanup();
          }
          
        } catch (e) {
          print('BluetoothModernHelper: Modern attempt $attempt failed: $e');
          if (attempt == maxRetries) rethrow;
        }
      }
      
      return false;
    } catch (e) {
      print('BluetoothModernHelper: Modern connection failed: $e');
      return false;
    }
  }
  
  /// Modern connection method
  static Future<bool> _modernConnectionMethod(
    BluetoothDevice device, {
    int timeoutSeconds = 45,
  }) async {
    try {
      // Use Completer for better control
      Completer<bool> connectionCompleter = Completer<bool>();
      
      // Start connection
      _bluetooth.connect(device).then((_) {
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.complete(true);
        }
      }).catchError((e) {
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.completeError(e);
        }
      });
      
      // Wait for connection with extended timeout
      bool connected = await connectionCompleter.future.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          print('BluetoothModernHelper: Connection timeout');
          return false;
        },
      );
      
      if (connected) {
        // Verify connection with multiple checks
        await Future.delayed(Duration(milliseconds: 2000));
        
        bool? status1 = await _bluetooth.isConnected;
        await Future.delayed(Duration(milliseconds: 500));
        bool? status2 = await _bluetooth.isConnected;
        
        // Both checks must be true
        return (status1 == true && status2 == true);
      }
      
      return false;
    } catch (e) {
      print('BluetoothModernHelper: Modern connection error: $e');
      return false;
    }
  }
  
  /// Complete cleanup method
  static Future<void> _completeCleanup() async {
    try {
      // Check if connected
      bool? isConnected = await _bluetooth.isConnected;
      
      if (isConnected == true) {
        print('BluetoothModernHelper: Disconnecting existing connection');
        await _bluetooth.disconnect();
        await Future.delayed(Duration(milliseconds: 2000));
      }
      
      // Additional cleanup for Android 11+
      await Future.delayed(Duration(milliseconds: 1000));
      
    } catch (e) {
      print('BluetoothModernHelper: Cleanup error: $e');
    }
  }
  
  /// Get detailed connection info
  static Future<Map<String, dynamic>> getDetailedConnectionInfo() async {
    try {
      bool? isConnected = await _bluetooth.isConnected;
      bool? isOn = await _bluetooth.isOn;
      
      return {
        'isConnected': isConnected ?? false,
        'isBluetoothOn': isOn ?? false,
        'timestamp': DateTime.now().toIso8601String(),
        'androidVersion': 'Android 11+ (API 30+)',
        'pluginVersion': 'blue_thermal_printer: ^1.2.3',
        'flutterVersion': 'Flutter 3.7.11',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Show modern troubleshooting dialog
  static void showModernTroubleshooting(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modern Bluetooth Troubleshooting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masalah: Plugin blue_thermal_printer mungkin tidak compatible dengan Android 11+'),
            SizedBox(height: 16),
            Text('Solusi yang bisa dicoba:'),
            Text('• Restart aplikasi'),
            Text('• Restart Bluetooth'),
            Text('• Update plugin ke versi terbaru'),
            Text('• Gunakan plugin alternatif'),
            SizedBox(height: 16),
            Text('Info:'),
            Text('• Plugin: blue_thermal_printer ^1.2.3'),
            Text('• Flutter: 3.7.11'),
            Text('• Android: 11+ (API 30+)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
} 