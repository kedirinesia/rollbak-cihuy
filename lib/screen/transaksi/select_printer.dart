// @dart=2.9

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';

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
        future: bluetooth.getBondedDevices(),
        builder: (ctx, snapshot) {
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

          if (snapshot.data.length == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Tidak ditemukan perangkat apapun'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(15),
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemCount: snapshot.data.length,
            itemBuilder: (_, i) {
              BluetoothDevice device = snapshot.data.elementAt(i);

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
                    device.name,
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: Text(
                    device.address,
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
