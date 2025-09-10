import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/debug_helper.dart';

class BluetoothHelper {
  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  
  // Connection state tracking
  static BluetoothDevice? _currentDevice;
  static bool _isConnecting = false;
  static DateTime? _lastConnectionAttempt;
  
  /// Check if device is Android 11
  static Future<bool> _isAndroid11Device() async {
    try {
      // Simple check for Android 11 (API 30)
      // In production, you might want to use device_info_plus package
      return true; // Assume Android 11 for now, can be enhanced later
    } catch (e) {
      return false;
    }
  }
  
  /// Get current connection status
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    try {
      bool? isConnected = await _bluetooth.isConnected;
      bool? isOn = await _bluetooth.isOn;
      
      return {
        'isConnected': isConnected ?? false,
        'isBluetoothOn': isOn ?? false,
        'currentDevice': _currentDevice,
        'isConnecting': _isConnecting,
        'lastConnectionAttempt': _lastConnectionAttempt,
      };
    } catch (e) {
      return {
        'isConnected': false,
        'isBluetoothOn': false,
        'currentDevice': null,
        'isConnecting': false,
        'lastConnectionAttempt': null,
        'error': e.toString(),
      };
    }
  }
  
  /// Advanced connection with multiple strategies
  static Future<bool> connectWithAdvancedRetry(
    BluetoothDevice device, {
    int maxRetries = 5,
    int timeoutSeconds = 20,
    int retryDelaySeconds = 3,
    bool useAlternativeMethod = true,
  }) async {
    // Check if device is physical Android 11
    bool isAndroid11 = await _isAndroid11Device();
    if (isAndroid11) {
      DebugHelper.debugPrint('BluetoothHelper: Detected Android 11 device, using optimized settings');
      timeoutSeconds = 25; // Longer timeout for Android 11
      retryDelaySeconds = 4; // Longer delay for Android 11
    }
    if (_isConnecting) {
      DebugHelper.debugPrint('BluetoothHelper: Connection already in progress');
      return false;
    }
    
    _isConnecting = true;
    _currentDevice = device;
    _lastConnectionAttempt = DateTime.now();
    
    try {
      DebugHelper.debugPrint('BluetoothHelper: Starting advanced connection to ${device.name}');
      
      // Strategy 1: Standard connection with extended timeout
      bool connected = await _tryStandardConnection(
        device, 
        timeoutSeconds: timeoutSeconds,
        maxRetries: maxRetries,
        retryDelaySeconds: retryDelaySeconds,
      );
      
      if (connected) {
        DebugHelper.debugPrint('BluetoothHelper: Standard connection successful');
        return true;
      }
      
      // Strategy 2: Alternative connection method (if enabled)
      if (useAlternativeMethod) {
        DebugHelper.debugPrint('BluetoothHelper: Trying alternative connection method');
        connected = await _tryAlternativeConnection(device, timeoutSeconds);
        
        if (connected) {
          DebugHelper.debugPrint('BluetoothHelper: Alternative connection successful');
          return true;
        }
      }
      
      // Strategy 3: Force disconnect and reconnect
      DebugHelper.debugPrint('BluetoothHelper: Trying force disconnect and reconnect');
      connected = await _tryForceReconnect(device, timeoutSeconds);
      
      return connected;
      
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Advanced connection failed: $e');
      return false;
    } finally {
      _isConnecting = false;
    }
  }
  
  /// Standard connection method with retry
  static Future<bool> _tryStandardConnection(
    BluetoothDevice device, {
    int timeoutSeconds = 20,
    int maxRetries = 5,
    int retryDelaySeconds = 3,
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        retryCount++;
        DebugHelper.debugPrint('BluetoothHelper: Standard connection attempt $retryCount/$maxRetries');
        
        // Disconnect if already connected
        await _forceDisconnect();
        
        // Wait before retry
        if (retryCount > 1) {
          await Future.delayed(Duration(seconds: retryDelaySeconds));
        }
        
        // Attempt connection with extended timeout
        await _bluetooth.connect(device).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw TimeoutException('Connection timeout after $timeoutSeconds seconds');
          },
        );
        
        // Verify connection
        bool? connectionStatus = await _bluetooth.isConnected;
        if (connectionStatus == true) {
          DebugHelper.debugPrint('BluetoothHelper: Standard connection verified');
          return true;
        } else {
          throw Exception('Connection verification failed');
        }
        
      } catch (e) {
        DebugHelper.debugPrint('BluetoothHelper: Standard connection attempt $retryCount failed: $e');
        
        if (retryCount >= maxRetries) {
          DebugHelper.debugPrint('BluetoothHelper: Standard connection failed after $maxRetries attempts');
          return false;
        }
        
        // Force disconnect before retry
        await _forceDisconnect();
      }
    }
    
    return false;
  }
  
  /// Alternative connection method (different approach)
  static Future<bool> _tryAlternativeConnection(
    BluetoothDevice device, 
    int timeoutSeconds,
  ) async {
    try {
      DebugHelper.debugPrint('BluetoothHelper: Alternative connection method');
      
      // Force disconnect completely
      await _forceDisconnect();
      
      // Wait longer before alternative attempt
      await Future.delayed(Duration(seconds: 5));
      
      // Try connection with different timeout strategy
      Completer<bool> connectionCompleter = Completer<bool>();
      
      // Start connection
      _bluetooth.connect(device).then((_) {
        connectionCompleter.complete(true);
      }).catchError((e) {
        connectionCompleter.complete(false);
      });
      
      // Wait for connection with timeout
      bool connected = await connectionCompleter.future.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          DebugHelper.debugPrint('BluetoothHelper: Alternative connection timeout');
          return false;
        },
      );
      
      if (connected) {
        // Verify connection
        bool? status = await _bluetooth.isConnected;
        return status == true;
      }
      
      return false;
      
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Alternative connection failed: $e');
      return false;
    }
  }
  
  /// Physical device optimized connection (especially for Android 11)
  static Future<bool> connectForPhysicalDevice(
    BluetoothDevice device, {
    int maxRetries = 7,
    int timeoutSeconds = 30,
  }) async {
    DebugHelper.debugPrint('BluetoothHelper: Using physical device optimized connection');
    
    try {
      // Force disconnect first
      await _forceDisconnect();
      
      // Wait longer for physical device Bluetooth stack reset
      await Future.delayed(Duration(seconds: 3));
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          DebugHelper.debugPrint('BluetoothHelper: Physical device attempt $attempt/$maxRetries');
          
          // Use longer timeout for physical devices
          bool connected = await _tryPhysicalDeviceConnection(
            device, 
            timeoutSeconds: timeoutSeconds,
          );
          
          if (connected) {
            DebugHelper.debugPrint('BluetoothHelper: Physical device connection successful');
            return true;
          }
          
          // Longer delay between attempts for physical devices
          await Future.delayed(Duration(seconds: 5));
          
        } catch (e) {
          DebugHelper.debugPrint('BluetoothHelper: Physical device attempt $attempt failed: $e');
          if (attempt == maxRetries) rethrow;
          
          // Force disconnect before retry
          await _forceDisconnect();
          await Future.delayed(Duration(seconds: 3));
        }
      }
      
      return false;
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Physical device connection failed: $e');
      return false;
    }
  }
  
  /// Physical device specific connection
  static Future<bool> _tryPhysicalDeviceConnection(
    BluetoothDevice device, {
    int timeoutSeconds = 30,
  }) async {
    try {
      // Check if already connected
      if (await _bluetooth.isConnected == true) {
        await _bluetooth.disconnect();
        await Future.delayed(Duration(milliseconds: 1500));
      }
      
      // Use longer timeout for physical devices
      await _bluetooth.connect(device).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('Physical device connection timeout after $timeoutSeconds seconds');
        },
      );
      
      // Verify connection with delay
      await Future.delayed(Duration(milliseconds: 1000));
      bool? status = await _bluetooth.isConnected;
      
      return status == true;
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Physical device connection error: $e');
      return false;
    }
  }
  
  /// Force disconnect and reconnect method
  static Future<bool> _tryForceReconnect(
    BluetoothDevice device,
    int timeoutSeconds,
  ) async {
    try {
      DebugHelper.debugPrint('BluetoothHelper: Force reconnect method');
      
      // Force disconnect multiple times
      for (int i = 0; i < 3; i++) {
        try {
          await _bluetooth.disconnect();
        } catch (e) {
          DebugHelper.debugPrint('BluetoothHelper: Disconnect attempt $i failed: $e');
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      // Wait longer before final attempt
      await Future.delayed(Duration(seconds: 3));
      
      // Final connection attempt
      await _bluetooth.connect(device).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('Final connection timeout');
        },
      );
      
      // Verify connection
      bool? status = await _bluetooth.isConnected;
      return status == true;
      
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Force reconnect failed: $e');
      return false;
    }
  }
  
  /// Force disconnect with error handling
  static Future<void> _forceDisconnect() async {
    try {
      bool? isConnected = await _bluetooth.isConnected;
      if (isConnected == true) {
        await _bluetooth.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Force disconnect error: $e');
    }
  }
  
  /// Connect to a Bluetooth device with retry logic and timeout
  static Future<bool> connectWithRetry(
    BluetoothDevice device, {
    int maxRetries = 3,
    int timeoutSeconds = 15,
    int retryDelaySeconds = 2,
  }) async {
    // Use advanced connection for better reliability
    return await connectWithAdvancedRetry(
      device,
      maxRetries: maxRetries,
      timeoutSeconds: timeoutSeconds,
      retryDelaySeconds: retryDelaySeconds,
      useAlternativeMethod: true,
    );
  }
  
  /// Disconnect from current Bluetooth connection
  static Future<void> disconnect() async {
    try {
      await _forceDisconnect();
      _currentDevice = null;
      DebugHelper.debugPrint('BluetoothHelper: Disconnected successfully');
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Error during disconnect: $e');
    }
  }
  
  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    try {
      bool? isOn = await _bluetooth.isOn;
      return isOn ?? false;
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Error checking Bluetooth status: $e');
      return false;
    }
  }
  
  /// Get bonded devices with filtering
  static Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      
      // Filter out invalid devices
      devices = devices.where((device) => 
        device.name != null && 
        device.name!.isNotEmpty && 
        device.address != null && 
        device.address!.isNotEmpty
      ).toList();
      
      DebugHelper.debugPrint('BluetoothHelper: Found ${devices.length} valid bonded devices');
      return devices;
      
    } catch (e) {
      DebugHelper.debugPrint('BluetoothHelper: Error getting bonded devices: $e');
      throw e;
    }
  }
  
  /// Get device compatibility info
  static Map<String, dynamic> getDeviceCompatibility(BluetoothDevice device) {
    String name = device.name ?? 'Unknown';
    String address = device.address ?? 'Unknown';
    
    // Check for known printer models
    bool isKnownPrinter = name.toLowerCase().contains('printer') ||
                         name.toLowerCase().contains('thermal') ||
                         name.toLowerCase().contains('rpp') ||
                         name.toLowerCase().contains('zj') ||
                         name.toLowerCase().contains('bt link') ||
                         name.toLowerCase().contains('air2') ||
                         name.toLowerCase().contains('sqrs');
    
    return {
      'name': name,
      'address': address,
      'isKnownPrinter': isKnownPrinter,
      'recommendedTimeout': isKnownPrinter ? 25 : 15,
      'recommendedRetries': isKnownPrinter ? 5 : 3,
    };
  }
  
  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    String errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout')) {
      return 'Koneksi printer timeout. Coba:\n• Restart printer dan device\n• Pastikan printer tidak sedang digunakan\n• Cek jarak (maksimal 10 meter)';
    } else if (errorStr.contains('socket')) {
      return 'Koneksi Bluetooth gagal. Coba:\n• Restart Bluetooth di device\n• Re-pair printer dengan device\n• Cek firmware printer';
    } else if (errorStr.contains('permission')) {
      return 'Izin Bluetooth diperlukan. Coba:\n• Buka Settings > Apps > [App] > Permissions\n• Aktifkan Bluetooth permission\n• Restart app';
    } else if (errorStr.contains('bluetooth tidak aktif')) {
      return 'Bluetooth tidak aktif. Coba:\n• Aktifkan Bluetooth di device\n• Restart Bluetooth\n• Cek device compatibility';
    } else if (errorStr.contains('not found')) {
      return 'Printer tidak ditemukan. Coba:\n• Pastikan printer sudah paired\n• Restart printer\n• Re-pair dengan device';
    } else {
      return 'Gagal menghubungkan ke printer:\n${error.toString()}\n\nCoba restart printer dan device';
    }
  }
  
  /// Show connection progress dialog
  static void showConnectionProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menghubungkan ke printer...'),
                    SizedBox(height: 8),
                    Text(
                      'Ini mungkin memakan waktu beberapa saat',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Show error dialog with retry option
  static void showErrorDialog(
    BuildContext context, 
    String title, 
    String message, 
    VoidCallback? onRetry,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text('Coba Lagi'),
              ),
          ],
        );
      },
    );
  }
  
  /// Show advanced troubleshooting dialog
  static void showTroubleshootingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Troubleshooting Bluetooth'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Langkah-langkah yang bisa dicoba:'),
                SizedBox(height: 8),
                Text('1. Restart printer (power cycle)'),
                Text('2. Restart Bluetooth di device'),
                Text('3. Re-pair printer dengan device'),
                Text('4. Cek jarak (maksimal 10 meter)'),
                Text('5. Pastikan printer tidak sedang digunakan'),
                Text('6. Cek firmware printer'),
                Text('7. Coba device lain untuk testing'),
                SizedBox(height: 16),
                Text(
                  'Jika masih bermasalah, kemungkinan ada masalah hardware compatibility.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
} 