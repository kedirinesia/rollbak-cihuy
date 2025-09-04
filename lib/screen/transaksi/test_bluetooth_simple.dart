import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

class TestBluetoothSimplePage extends StatefulWidget {
  @override
  _TestBluetoothSimplePageState createState() => _TestBluetoothSimplePageState();
}

class _TestBluetoothSimplePageState extends State<TestBluetoothSimplePage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  String status = 'Ready';
  bool isConnecting = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      setState(() {
        status = 'Checking Bluetooth status...';
      });

      bool? isOn = await bluetooth.isOn;
      if (isOn == true) {
        setState(() {
          status = 'Bluetooth is ON';
        });
        await _getBondedDevices();
      } else {
        setState(() {
          status = 'Bluetooth is OFF. Please enable Bluetooth.';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error checking Bluetooth: $e';
      });
    }
  }

  Future<void> _getBondedDevices() async {
    try {
      setState(() {
        status = 'Getting bonded devices...';
      });

      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      
      // Filter valid devices
      List<BluetoothDevice> validDevices = bondedDevices.where((device) => 
        device.name != null && 
        device.name!.isNotEmpty && 
        device.address != null && 
        device.address!.isNotEmpty
      ).toList();

      setState(() {
        devices = validDevices;
        status = 'Found ${validDevices.length} devices';
      });

      print('Found ${validDevices.length} valid devices:');
      for (var device in validDevices) {
        print('- ${device.name} (${device.address})');
      }

    } catch (e) {
      setState(() {
        status = 'Error getting devices: $e';
      });
      print('Error getting bonded devices: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (isConnecting) return;

    setState(() {
      isConnecting = true;
      status = 'Connecting to ${device.name}...';
    });

    try {
      // Check if already connected
      bool? currentStatus = await bluetooth.isConnected;
      if (currentStatus == true) {
        await bluetooth.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Try to connect
      await bluetooth.connect(device).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout after 10 seconds');
        },
      );

      // Verify connection
      bool? connected = await bluetooth.isConnected;
      if (connected == true) {
        setState(() {
          selectedDevice = device;
          isConnected = true;
          status = 'Connected to ${device.name}';
        });
        print('Successfully connected to ${device.name}');
      } else {
        throw Exception('Connection verification failed');
      }

    } catch (e) {
      setState(() {
        status = 'Connection failed: $e';
        isConnected = false;
      });
      print('Connection error: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      setState(() {
        status = 'Disconnecting...';
      });

      await bluetooth.disconnect();
      
      setState(() {
        selectedDevice = null;
        isConnected = false;
        status = 'Disconnected';
      });
      print('Disconnected successfully');

    } catch (e) {
      setState(() {
        status = 'Disconnect error: $e';
      });
      print('Disconnect error: $e');
    }
  }

  void _showConnectionStatus() {
    if (selectedDevice != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Printer Connection Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device: ${selectedDevice!.name}'),
                Text('Address: ${selectedDevice!.address}'),
                SizedBox(height: 16),
                Text('Status: Connected and Ready'),
                Text('This printer is now available for use in the main app.'),
                SizedBox(height: 16),
                Text(
                  'Note: No test print was sent. The printer is ready for actual printing operations.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Test - Simple'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(status),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _checkBluetoothStatus,
                          child: Text('Refresh Status'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _getBondedDevices,
                          child: Text('Refresh Devices'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Connection Card
            if (isConnected && selectedDevice != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Device:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text('Name: ${selectedDevice!.name}'),
                      Text('Address: ${selectedDevice!.address}'),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _showConnectionStatus,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            child: Text('Connection Status'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _disconnect,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text('Disconnect'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // Devices List
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Devices (${devices.length}):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      if (devices.isEmpty)
                        Center(
                          child: Text(
                            'No devices found. Make sure your printer is paired.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              BluetoothDevice device = devices[index];
                              bool isSelected = selectedDevice?.address == device.address;
                              
                              return ListTile(
                                leading: Icon(
                                  isSelected ? Icons.bluetooth_connected : Icons.bluetooth,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                title: Text(device.name ?? 'Unknown Device'),
                                subtitle: Text(device.address ?? 'No Address'),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: isConnecting ? null : () => _connectToDevice(device),
                                        child: Text('Connect'),
                                      ),
                                onTap: isConnecting ? null : () => _connectToDevice(device),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 