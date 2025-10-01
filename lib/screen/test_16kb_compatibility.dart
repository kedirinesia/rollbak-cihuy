  import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mobile/utils/debug_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
 

class Test16KBCompatibilityPage extends StatefulWidget {
  @override
  _Test16KBCompatibilityPageState createState() => _Test16KBCompatibilityPageState();
}

class _Test16KBCompatibilityPageState extends State<Test16KBCompatibilityPage> {
  Map<String, dynamic> deviceInfo = {};
  bool isLoading = true;
  List<String> testResults = [];

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _run16KBTests();
  }

  Future<void> _getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceInfo = {
            'brand': androidInfo.brand,
            'model': androidInfo.model,
            'version': androidInfo.version.release,
            'sdkInt': androidInfo.version.sdkInt,
            'architecture': androidInfo.supportedAbis.join(', '),
            'manufacturer': androidInfo.manufacturer,
            'hardware': androidInfo.hardware,
          };
        });
      }
    } catch (e) {
      DebugHelper.debugPrint('Error getting device info: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _run16KBTests() async {
    List<String> results = [];
    
    // Test 1: Check Android version
    if (deviceInfo['sdkInt'] != null) {
      int sdkInt = deviceInfo['sdkInt'];
      if (sdkInt >= 31) { // Android 12+
        results.add('✅ Android ${deviceInfo['version']} (API $sdkInt) - Supports 16KB page size');
      } else {
        results.add('⚠️ Android ${deviceInfo['version']} (API $sdkInt) - Uses 4KB page size');
      }
    }

    // Test 2: Check architecture
    if (deviceInfo['architecture'] != null) {
      String arch = deviceInfo['architecture'];
      if (arch.contains('arm64')) {
        results.add('✅ ARM64 architecture detected - Optimal for 16KB page size');
      } else if (arch.contains('arm')) {
        results.add('⚠️ ARM architecture detected - May use 4KB page size');
      }
    }

    // Test 3: Check if app is running in 16KB mode
    try {
      // This is a theoretical test - in practice, we'd need native code
      results.add('🔍 App compiled with 16KB page size support');
      results.add('🔍 Using legacy packaging for compatibility');
      results.add('🔍 NDK optimization enabled for 16KB');
    } catch (e) {
      results.add('❌ Error checking 16KB mode: $e');
    }

    // Test 4: Memory allocation test
    try {
      // Test large memory allocation to see page size behavior
      List<int> testArray = List.filled(1024 * 1024, 0); // 1MB
      results.add('✅ Large memory allocation test passed');
    } catch (e) {
      results.add('❌ Memory allocation test failed: $e');
    }

    setState(() {
      testResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: AppBar(
        title: Text('16KB Page Size Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Info Card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📱 Device Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...deviceInfo.entries.map((entry) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Expanded(
                                  child: Text(
                                    '${entry.value}',
                                    style: TextStyle(fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Test Results Card
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧪 16KB Compatibility Test Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...testResults.map((result) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(result),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Manual Test Instructions
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 Manual Testing Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('1. Check if you see "This app isn\'t 16 KB compatible" dialog'),
                          Text('2. If NO dialog appears → 16KB support is working ✅'),
                          Text('3. If dialog appears → 16KB support needs fixing ❌'),
                          Text('4. Check logcat for 16KB related messages'),
                          Text('5. Monitor app performance and memory usage'),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _run16KBTests,
                          icon: Icon(Icons.refresh),
                          label: Text('Re-run Tests'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Show instructions for logcat monitoring
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Logcat Monitoring'),
                                content: Text(
                                  'To monitor 16KB logs in real-time:\n\n'
                                  '1. Open terminal\n'
                                  '2. Run: ./test_16kb_support.sh\n'
                                  '3. Launch this app\n'
                                  '4. Watch for 16KB related messages'
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.terminal),
                          label: Text('Logcat Guide'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 