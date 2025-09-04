import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class TestBluetoothWithout16KB extends StatefulWidget {
  @override
  _TestBluetoothWithout16KBState createState() => _TestBluetoothWithout16KBState();
}

class _TestBluetoothWithout16KBState extends State<TestBluetoothWithout16KB> {
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
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _testSimpleConnection() async {
    if (_selectedDevice == null) {
      _addLog('❌ No device selected');
      return;
    }

    setState(() {
      _status = 'Testing simple connection...';
    });

    try {
      _addLog('🔍 Testing simple connection to ${_selectedDevice!.name}');
      
      // Simple connection without any helper
      bool connected = await _bluetooth.connect(_selectedDevice!);
      
      if (connected) {
        _addLog('✅ Simple connection successful');
        _status = 'Simple connection: SUCCESS';
      } else {
        _addLog('❌ Simple connection failed');
        _status = 'Simple connection: FAILED';
      }
    } catch (e) {
      _addLog('❌ Simple connection error: $e');
      _status = 'Simple connection: ERROR';
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
        title: Text('Test Bluetooth (No 16KB)'),
        backgroundColor: Colors.red,
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
            color: Colors.red[100],
            child: Text(
              'Testing WITHOUT 16KB optimizations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[800]),
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
                    onPressed: _testSimpleConnection,
                    icon: Icon(Icons.bluetooth),
                    label: Text('Test Simple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
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
                    onPressed: _disconnect,
                    icon: Icon(Icons.bluetooth_disabled),
                    label: Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearLogs,
                    icon: Icon(Icons.clear),
                    label: Text('Clear Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Logs (No 16KB optimizations):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[800]),
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