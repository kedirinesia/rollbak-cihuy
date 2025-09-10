import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:mobile/component/bluetooth_helper.dart';
import 'package:mobile/utils/debug_helper.dart';

class TestBluetoothAdvancedPage extends StatefulWidget {
  @override
  _TestBluetoothAdvancedPageState createState() => _TestBluetoothAdvancedPageState();
}

class _TestBluetoothAdvancedPageState extends State<TestBluetoothAdvancedPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  String status = 'Ready';
  bool isConnecting = false;
  bool isConnected = false;
  Map<String, dynamic>? connectionStatus;
  List<String> diagnosticLog = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      setState(() {
        status = 'Checking Bluetooth status...';
        diagnosticLog.clear();
      });

      // Get detailed connection status
      connectionStatus = await BluetoothHelper.getConnectionStatus();
      diagnosticLog.add('Bluetooth Status: ${connectionStatus!['isBluetoothOn'] ? "ON" : "OFF"}');
      diagnosticLog.add('Current Connection: ${connectionStatus!['isConnected'] ? "Connected" : "Disconnected"}');
      
      if (connectionStatus!['isBluetoothOn'] == true) {
        setState(() {
          status = 'Bluetooth is ON - Running diagnostics...';
        });
        await _runDiagnostics();
      } else {
        setState(() {
          status = 'Bluetooth is OFF. Please enable Bluetooth.';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error checking Bluetooth: $e';
        diagnosticLog.add('Error: $e');
      });
    }
  }

  Future<void> _runDiagnostics() async {
    try {
      // Check for paired devices
      diagnosticLog.add('Checking paired devices...');
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      
      // Filter and analyze devices
      List<BluetoothDevice> validDevices = bondedDevices.where((device) => 
        device.name != null && 
        device.name!.isNotEmpty && 
        device.address != null && 
        device.address!.isNotEmpty
      ).toList();

      setState(() {
        devices = validDevices;
        status = 'Found ${validDevices.length} devices - Analyzing compatibility...';
      });

      diagnosticLog.add('Found ${validDevices.length} valid devices:');
      
      // Analyze each device
      for (var device in validDevices) {
        Map<String, dynamic> compatibility = BluetoothHelper.getDeviceCompatibility(device);
        diagnosticLog.add('- ${device.name} (${device.address})');
        diagnosticLog.add('  Type: ${compatibility['isKnownPrinter'] ? "Known Printer" : "Unknown Device"}');
        diagnosticLog.add('  Recommended Timeout: ${compatibility['recommendedTimeout']}s');
        diagnosticLog.add('  Recommended Retries: ${compatibility['recommendedRetries']}');
      }

      // Check for potential issues
      _analyzePotentialIssues(validDevices);
      
      setState(() {
        status = 'Diagnostics completed - ${validDevices.length} devices found';
      });

    } catch (e) {
      setState(() {
        status = 'Error during diagnostics: $e';
        diagnosticLog.add('Diagnostic Error: $e');
      });
    }
  }

  void _analyzePotentialIssues(List<BluetoothDevice> devices) {
    diagnosticLog.add('\nPotential Issues Analysis:');
    
    // Check for multiple printers
    List<BluetoothDevice> printers = devices.where((device) {
      String name = device.name?.toLowerCase() ?? '';
      return name.contains('printer') || name.contains('thermal') || 
             name.contains('rpp') || name.contains('zj') ||
             name.contains('bt link') || name.contains('air2') || name.contains('sqrs');
    }).toList();
    
    if (printers.length > 1) {
      diagnosticLog.add('⚠️ Multiple printers detected - may cause conflicts');
      diagnosticLog.add('   Consider keeping only one printer paired');
    }
    
    // Check for non-printer devices
    List<BluetoothDevice> nonPrinters = devices.where((device) {
      String name = device.name?.toLowerCase() ?? '';
      return !name.contains('printer') && !name.contains('thermal') && 
             !name.contains('rpp') && !name.contains('zj') &&
             !name.contains('bt link') && !name.contains('air2') && !name.contains('sqrs');
    }).toList();
    
    if (nonPrinters.isNotEmpty) {
      diagnosticLog.add('ℹ️ Non-printer devices found - these are fine');
    }
    
    // Check connection status
    if (connectionStatus != null && connectionStatus!['isConnecting'] == true) {
      diagnosticLog.add('⚠️ Connection already in progress - wait for completion');
    }
    
    diagnosticLog.add('\nRecommendations:');
    diagnosticLog.add('1. Ensure only necessary devices are paired');
    diagnosticLog.add('2. Keep printer within 10 meters');
    diagnosticLog.add('3. Restart printer if connection fails');
    diagnosticLog.add('4. Check printer firmware updates');
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (isConnecting) return;

    setState(() {
      isConnecting = true;
      status = 'Connecting to ${device.name}...';
      diagnosticLog.add('Attempting connection to ${device.name}...');
    });

    try {
      // Get device compatibility info
      Map<String, dynamic> compatibility = BluetoothHelper.getDeviceCompatibility(device);
      diagnosticLog.add('Device: ${compatibility['name']}');
      diagnosticLog.add('Type: ${compatibility['isKnownPrinter'] ? "Known Printer" : "Unknown"}');
      diagnosticLog.add('Recommended Timeout: ${compatibility['recommendedTimeout']}s');
      
      // Use advanced connection with device-specific settings
      bool connected = await BluetoothHelper.connectWithAdvancedRetry(
        device,
        maxRetries: compatibility['recommendedRetries'],
        timeoutSeconds: compatibility['recommendedTimeout'],
        retryDelaySeconds: 3,
        useAlternativeMethod: true,
      );

      if (connected) {
        setState(() {
          selectedDevice = device;
          isConnected = true;
          status = 'Connected to ${device.name}';
        });
        diagnosticLog.add('✅ Connection successful!');
        diagnosticLog.add('Printer ready for use');
        DebugHelper.debugPrint('Successfully connected to ${device.name}');
      } else {
        setState(() {
          status = 'Connection failed after all attempts';
        });
        diagnosticLog.add('❌ Connection failed after all attempts');
        
        // Show troubleshooting options
        _showTroubleshootingOptions();
      }

    } catch (e) {
      setState(() {
        status = 'Connection error: $e';
        isConnected = false;
      });
      diagnosticLog.add('❌ Connection error: $e');
      DebugHelper.debugPrint('Connection error: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _showTroubleshootingOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connection Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connection to ${selectedDevice?.name} failed.'),
              SizedBox(height: 16),
              Text('Try these solutions:'),
              SizedBox(height: 8),
              Text('1. Restart the printer'),
              Text('2. Move closer to the printer'),
              Text('3. Check if printer is busy'),
              Text('4. Re-pair the printer'),
              SizedBox(height: 16),
              Text('Would you like to see advanced troubleshooting?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BluetoothHelper.showTroubleshootingDialog(context);
              },
              child: Text('Advanced Help'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _disconnect() async {
    try {
      setState(() {
        status = 'Disconnecting...';
      });

      await BluetoothHelper.disconnect();
      
      setState(() {
        selectedDevice = null;
        isConnected = false;
        status = 'Disconnected';
      });
      diagnosticLog.add('Disconnected successfully');
      DebugHelper.debugPrint('Disconnected successfully');

    } catch (e) {
      setState(() {
        status = 'Disconnect error: $e';
      });
      diagnosticLog.add('Disconnect error: $e');
      DebugHelper.debugPrint('Disconnect error: $e');
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

  Future<void> _refreshDiagnostics() async {
    setState(() {
      status = 'Refreshing diagnostics...';
    });
    
    await _checkBluetoothStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Advanced Test'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshDiagnostics,
            tooltip: 'Refresh Diagnostics',
          ),
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () => BluetoothHelper.showTroubleshootingDialog(context),
            tooltip: 'Troubleshooting Help',
          ),
        ],
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
                          child: Text('Check Status'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _runDiagnostics,
                          child: Text('Run Diagnostics'),
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
                              Map<String, dynamic> compatibility = BluetoothHelper.getDeviceCompatibility(device);
                              
                              return ListTile(
                                leading: Icon(
                                  isSelected ? Icons.bluetooth_connected : Icons.bluetooth,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                title: Text(device.name ?? 'Unknown Device'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(device.address ?? 'No Address'),
                                    Text(
                                      'Type: ${compatibility['isKnownPrinter'] ? "Printer" : "Other Device"}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
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
            
            SizedBox(height: 16),
            
            // Diagnostic Log
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnostic Log:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        itemCount: diagnosticLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              diagnosticLog[index],
                              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
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
      ),
    );
  }
} 