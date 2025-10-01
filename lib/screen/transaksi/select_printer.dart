
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/component/bluetooth_helper.dart';
import 'package:mobile/utils/debug_helper.dart';

class SelectPrinterPage extends StatefulWidget {
  @override
  _SelectPrinterPageState createState() => _SelectPrinterPageState();
}

class _SelectPrinterPageState extends State<SelectPrinterPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/select/printer/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Pilih Printer',
    });
  }
  
  Future<List<BluetoothDevice>> _getBondedDevices() async {
    try {
      DebugHelper.debugPrint('"Getting bonded devices..."');
      
      // Check if Bluetooth is enabled
      bool isEnabled = await BluetoothHelper.isBluetoothEnabled();
      if (isEnabled != true) {
        throw Exception('Bluetooth tidak aktif. Silakan aktifkan Bluetooth di pengaturan.');
      }
      
      List<BluetoothDevice> devices = await BluetoothHelper.getBondedDevices();
      DebugHelper.debugPrint('"Found ${devices.length} valid bonded devices"');
      
      return devices;
    } catch (e) {
      DebugHelper.debugPrint('"Error getting bonded devices: $e"');
      
      if (e.toString().contains('permission')) {
        throw Exception('Izin Bluetooth diperlukan. Pastikan aplikasi memiliki akses Bluetooth.');
      } else if (e.toString().contains('Bluetooth tidak aktif')) {
        throw Exception('Bluetooth tidak aktif. Silakan aktifkan Bluetooth di pengaturan.');
      } else {
        throw Exception('Gagal mendapatkan daftar printer: ${e.toString()}');
      }
    }
  }

  Future<void> _refreshDevices() async {
    setState(() {
      // Trigger rebuild
    });
  }

  Future<void> _openBluetoothSettings() async {
    // Show instructions since openBluetoothSettings is not available
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buka Pengaturan Bluetooth'),
          content: Text('Buka Pengaturan > Bluetooth dan pastikan printer sudah dipasangkan (paired) dengan perangkat ini.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Printer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<BluetoothDevice>>(
        future: _getBondedDevices(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshDevices,
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: SpinKitThreeBounce(
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                  size: 35,
                ),
              ),
            );
          }

          if (snapshot.data!.length == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ditemukan perangkat printer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pastikan printer sudah dipasangkan (paired) dengan perangkat ini melalui pengaturan Bluetooth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshDevices,
                      child: Text('Refresh'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _openBluetoothSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Buka Pengaturan Bluetooth'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(15),
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) {
              BluetoothDevice device = snapshot.data!.elementAt(i);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context)
                              .secondaryHeaderColor
                              .withOpacity(.3)
                          : Theme.of(context).primaryColor.withOpacity(.3),
                      width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: packageName == 'com.lariz.mobile'
                        ? Theme.of(context)
                            .secondaryHeaderColor
                            .withOpacity(.15)
                        : Theme.of(context).primaryColor.withOpacity(.15),
                    child: Icon(
                      Icons.print_rounded,
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    device.name ?? '',
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: Text(
                    device.address ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(device),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
