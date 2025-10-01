import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:async';

class TestBluetoothSimpleConnection extends StatefulWidget {
  @override
  _TestBluetoothSimpleConnectionState createState() => _TestBluetoothSimpleConnectionState();
}

class _TestBluetoothSimpleConnectionState extends State<TestBluetoothSimpleConnection> {
  BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  String _status = 'Ready';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _status = 'Loading devices...';
    });

    try {
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
        _status = 'Found ${devices.length} devices';
        _addLog('📱 Found ${devices.length} bonded devices');
        for (var device in devices) {
          _addLog('  - ${device.name} (${device.address})');
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _addLog('❌ Error loading devices: $e');
      });
    }
  }

  Future<void> _testDirectConnection() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _status = 'Testing direct connection...';
    });

    try {
      _addLog('🔍 Testing DIRECT connection to ${_selectedDevice!.name}');
      _addLog('  Device: ${_selectedDevice!.name}');
      _addLog('  Address: ${_selectedDevice!.address}');
      
      // Check Bluetooth status first
      bool? isOn = await _bluetooth.isOn;
      _addLog('  Bluetooth On: $isOn');
      
      if (isOn != true) {
        _addLog('❌ Bluetooth is not enabled');
        _status = 'Bluetooth not enabled';
        return;
      }

      // Try direct connection without any helper
      _addLog('  Attempting connection...');
      bool connected = await _bluetooth.connect(_selectedDevice!);
      
      if (connected) {
        _addLog('✅ Direct connection successful');
        _status = 'Direct connection: SUCCESS';
        
        // Check connection status
        bool? isConnected = await _bluetooth.isConnected;
        _addLog('  Connection verified: $isConnected');
      } else {
        _addLog('❌ Direct connection failed');
        _status = 'Direct connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Direct connection error: $e');
      _status = 'Direct connection: ERROR';
    }
  }

  Future<void> _testConnectionWithTimeout() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _status = 'Testing connection with timeout...';
    });

    try {
      _addLog('🔍 Testing connection with TIMEOUT to ${_selectedDevice!.name}');
      
      // Try connection with a timeout
      bool connected = false;
      
      // Use a timer to implement timeout
      Timer? timer;
      bool timeoutOccurred = false;
      
      timer = Timer(Duration(seconds: 30), () {
        timeoutOccurred = true;
        _addLog('⏰ Connection timeout after 30 seconds');
      });

      try {
        connected = await _bluetooth.connect(_selectedDevice!);
      } catch (e) {
        _addLog('❌ Connection attempt error: $e');
      }

      timer.cancel();

      if (timeoutOccurred) {
        _addLog('⏰ Connection timed out');
        _status = 'Connection: TIMEOUT';
      } else if (connected) {
        _addLog('✅ Connection successful');
        _status = 'Connection: SUCCESS';
      } else {
        _addLog('❌ Connection failed');
        _status = 'Connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Connection test error: $e');
      _status = 'Connection: ERROR';
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      bool? isConnected = await _bluetooth.isConnected;
      bool? isOn = await _bluetooth.isOn;
      
      _addLog('📱 Connection Status:');
      _addLog('  Connected: $isConnected');
      _addLog('  Bluetooth On: $isOn');
      _addLog('  Selected Device: ${_selectedDevice?.name ?? 'None'}');
      
      _status = 'Status checked';
    } catch (e) {
      _addLog('❌ Error checking status: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _bluetooth.disconnect();
      _addLog('✅ Disconnected');
      _status = 'Disconnected';
    } catch (e) {
      _addLog('❌ Disconnect error: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 100) {
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
        title: Text('Test Bluetooth Simple'),
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
            color: Colors.blue[100],
            child: Text(
              'Testing WITHOUT any 16KB optimizations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
            ),
          ),
          
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
                    onPressed: _testDirectConnection,
                    icon: Icon(Icons.bluetooth),
                    label: Text('Test Direct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testConnectionWithTimeout,
                    icon: Icon(Icons.timer),
                    label: Text('Test Timeout'),
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
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Test Logs (No 16KB optimizations):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
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