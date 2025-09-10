import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:mobile/component/bluetooth_helper.dart';
import 'package:mobile/component/bluetooth_modern_helper.dart';
import 'package:mobile/utils/debug_helper.dart';

class TestPhysicalDevicePage extends StatefulWidget {
  @override
  _TestPhysicalDevicePageState createState() => _TestPhysicalDevicePageState();
}

class _TestPhysicalDevicePageState extends State<TestPhysicalDevicePage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isLoading = false;
  String _status = 'Ready';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading devices...';
    });

    try {
      List<BluetoothDevice> devices = await BluetoothHelper.getBondedDevices();
      setState(() {
        _devices = devices;
        _status = 'Found ${devices.length} devices';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading devices: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testStandardConnection() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing standard connection...';
    });

    try {
      _addLog('🔍 Testing standard connection to ${_selectedDevice!.name}');
      
      bool connected = await BluetoothHelper.connectWithAdvancedRetry(
        _selectedDevice!,
        maxRetries: 5,
        timeoutSeconds: 20,
        retryDelaySeconds: 3,
      );

      if (connected) {
        _addLog('✅ Standard connection successful');
        _status = 'Standard connection: SUCCESS';
      } else {
        _addLog('❌ Standard connection failed');
        _status = 'Standard connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Standard connection error: $e');
      _status = 'Standard connection: ERROR';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPhysicalDeviceConnection() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing physical device connection...';
    });

    try {
      _addLog('🔍 Testing physical device connection to ${_selectedDevice!.name}');
      
      bool connected = await BluetoothHelper.connectForPhysicalDevice(
        _selectedDevice!,
        maxRetries: 7,
        timeoutSeconds: 30,
      );

      if (connected) {
        _addLog('✅ Physical device connection successful');
        _status = 'Physical device connection: SUCCESS';
      } else {
        _addLog('❌ Physical device connection failed');
        _status = 'Physical device connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Physical device connection error: $e');
      _status = 'Physical device connection: ERROR';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      Map<String, dynamic> status = await BluetoothHelper.getConnectionStatus();
      
      _addLog('📱 Connection Status:');
      _addLog('  Connected: ${status['isConnected']}');
      _addLog('  Bluetooth On: ${status['isBluetoothOn']}');
      _addLog('  Current Device: ${status['currentDevice']?.name ?? 'None'}');
      _addLog('  Is Connecting: ${status['isConnecting']}');
      
      if (status['error'] != null) {
        _addLog('  Error: ${status['error']}');
      }
      
      _status = 'Status checked';
    } catch (e) {
      _addLog('❌ Error checking status: $e');
    }
  }

  Future<void> _testModernConnection() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing modern connection...';
    });

    try {
      _addLog('🔍 Testing modern connection to ${_selectedDevice!.name}');
      
      bool connected = await BluetoothModernHelper.connectWithModernApproach(
        _selectedDevice!,
        maxRetries: 3,
        timeoutSeconds: 45,
      );

      if (connected) {
        _addLog('✅ Modern connection successful');
        _status = 'Modern connection: SUCCESS';
      } else {
        _addLog('❌ Modern connection failed');
        _status = 'Modern connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Modern connection error: $e');
      _status = 'Modern connection: ERROR';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showModernTroubleshooting() {
    BluetoothModernHelper.showModernTroubleshooting(context);
  }

  Future<void> _disconnect() async {
    try {
      await BluetoothHelper.disconnect();
      _addLog('✅ Disconnected');
      _status = 'Disconnected';
    } catch (e) {
      _addLog('❌ Disconnect error: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 50) {
        _logs.removeAt(0);
      }
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physical Device Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              _status,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Device Selection
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Bluetooth Device:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                DropdownButton<BluetoothDevice>(
                  value: _selectedDevice,
                  isExpanded: true,
                  hint: Text('Choose a device'),
                  items: _devices.map((device) {
                    return DropdownMenuItem(
                      value: device,
                      child: Text('${device.name} (${device.address})'),
                    );
                  }).toList(),
                  onChanged: (BluetoothDevice? device) {
                    setState(() {
                      _selectedDevice = device;
                    });
                  },
                ),
              ],
            ),
          ),

          // Test Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testStandardConnection,
                    icon: Icon(Icons.bluetooth),
                    label: Text('Test Standard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testPhysicalDeviceConnection,
                    icon: Icon(Icons.phone_android),
                    label: Text('Test Physical'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testModernConnection,
                    icon: Icon(Icons.new_releases),
                    label: Text('Test Modern'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showModernTroubleshooting,
                    icon: Icon(Icons.help),
                    label: Text('Troubleshoot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _checkConnectionStatus,
                    icon: Icon(Icons.info),
                    label: Text('Check Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _disconnect,
                    icon: Icon(Icons.bluetooth_disabled),
                    label: Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Logs
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Connection Logs:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _clearLogs,
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[index],
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 