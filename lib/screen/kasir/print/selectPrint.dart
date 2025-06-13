// @dart=2.9

import 'package:flutter/material.dart';

// install package
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

// component
import 'package:mobile/component/template-main.dart';

// model
import 'package:mobile/models/kasir/kasirPrint.dart';

// config bloc
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class SelectPrint extends StatefulWidget {
  KasirPrintModel printTrx;

  SelectPrint(this.printTrx);

  @override
  createState() => SelectPrintState();
}

class SelectPrintState extends State<SelectPrint> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devicesList = [];
  var scanSub;

  BluetoothDevice _device;
  bool _connected = false;
  bool _scan = false;
  int blututSelected = -1;

  @override
  initState() {
    super.initState();
    checkBlututOn();

    bluetooth.isConnected.then((c) {
      setState(() {
        _connected = c;
      });
    });
  }

  void cancelScan() async {
    setState(() {
      _scan = false;
    });
  }

  void checkBlututOn() async {
    if (!await bluetooth.isOn) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Warning'),
          content: Text(
              'Waduh, Bluetooth kamu belum aktif ternyata, silahkan aktifkan dulu ya'),
          actions: [
            TextButton(
                child: Text('Aktifkan'),
                onPressed: () async => await bluetooth.openSettings),
            TextButton(
                child: Text('Kembali'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      );

      scanSub = bluetooth.onStateChanged().listen((state) {
        if (state == BlueThermalPrinter.STATE_ON) {
          print('blutut berhasil di hidup kan');
          Navigator.of(context, rootNavigator: true).pop();
          scanSub.cancel();
          this.scanBlutut();
        }
      });
    } else {
      this.scanBlutut();
    }
  }

  void scanBlutut() async {
    setState(() {
      _scan = true;
      _devicesList = [];
    });

    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      setState(() {
        _scan = false;
        _devicesList = [];
      });
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _scan = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _scan = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;

    setState(() {
      _scan = false;
      _devicesList = devices;
    });
  }

  void connectBlutut(int i, BluetoothDevice d) async {
    if (d == null) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Warning'),
                content: Text(
                    'Bluetooth yang Kamu pilih tidak dapat di hubungkan, Pilih Bluetooth lainnya yang dapat di hubungkan aplikasi ini ya'),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      }),
                ],
              ));
    }

    setState(() {
      blututSelected = i;
      _connected = false;
    });

    // LOADING
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(width: 20.0),
                    Text('Loading...')
                  ],
                ),
              ),
            ));
    // END LOADING

    print('APAKAH BLUETHOOT SUDAH TERHUBUNG ? $_connected');
    if (_connected) {
      await bluetooth.disconnect();
    }

    scanSub = bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          Navigator.of(context, rootNavigator: true).pop();
          scanSub.cancel();
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            blututSelected = -1;
          });
          scanSub.cancel();
          break;
        default:
          print(state);
          break;
      }
    });

    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        print('blutut sudah terhubung');
        setState(() {
          _device = d;
          _connected = true;
        });
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        try {
          bluetooth.connect(d).catchError((error) {
            Navigator.of(context, rootNavigator: true).pop();
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Warning'),
                      content: Text(
                          'Bluetooth yang Kamu pilih tidak dapat di hubungkan, Pilih Bluetooth lainnya yang dapat di hubungkan aplikasi ini ya'),
                      actions: <Widget>[
                        TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            }),
                      ],
                    ));

            setState(() {
              _device = null;
              blututSelected = -1;
            });
          }).then((v) {
            print('blutut sudah terhubung ke 2');
            setState(() {
              _device = d;
              _connected = true;
            });
          });
        } catch (err) {
          print(err);
        }
      }
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Warning'),
                content: Text(
                    'Bluetooth yang Kamu pilih tidak dapat di hubungkan, Pilih Bluetooth lainnya yang dapat di hubungkan aplikasi ini ya'),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.of(context, rootNavigator: true).pop();
                      }),
                ],
              ));

      setState(() {
        _device = null;
        _connected = false;
      });
    });
  }

  void realPrint() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printNewLine();
        bluetooth.printCustom(
            bloc.user.valueWrapper?.value.namaToko == ''
                ? bloc.username.valueWrapper?.value
                : bloc.user.valueWrapper?.value.namaToko,
            3,
            1);
        bluetooth.printCustom(
            bloc.user.valueWrapper?.value.alamatToko == ''
                ? bloc.user.valueWrapper?.value.alamat
                : bloc.user.valueWrapper?.value.alamatToko,
            1,
            1);
        bluetooth.printNewLine();

        bluetooth.printCustom(
            'TGL : ${formatDate(widget.printTrx.created_at, 'd MMMM yyyy HH:mm:ss')}',
            1,
            0);
        bluetooth.printCustom(
            'NO  : ${widget.printTrx.id.toUpperCase()}', 1, 0);
        bluetooth.printCustom(
            'KASIR  : ${widget.printTrx.userID['nama']}', 1, 0);

        bluetooth.printNewLine();
        widget.printTrx.detailTrx.forEach((d) {
          bluetooth.printCustom('${d['nama_barang'].toUpperCase()}', 1, 0);
          bluetooth.printLeftRight(
              '${d['qty']} x ${formatNominal(d['harga_jual'])}',
              '${formatNominal(d['total_harga'])}',
              1);
        });
        bluetooth.printNewLine();

        bluetooth.printLeftRight(
            'PEMBAYARAN', '${widget.printTrx.termin.toUpperCase()}', 1);
        bluetooth.printLeftRight(
            'TOTAL HARGA', '${formatNominal(widget.printTrx.totalJual)}', 1);
        bluetooth.printLeftRight(
            'UANG BAYAR', '${formatNominal(widget.printTrx.terbayar)}', 1);

        if (widget.printTrx.termin.toUpperCase() == 'CASH') {
          bluetooth.printLeftRight(
              'KEMBALIAN',
              '${formatNominal(widget.printTrx.terbayar - widget.printTrx.totalJual)}',
              1);
        } else {
          bluetooth.printLeftRight(
              'JUMLAH HUTANG',
              '${formatNominal(widget.printTrx.totalJual - widget.printTrx.terbayar)}',
              1);
        }

        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom('TERIMA KASIH ATAS KUNJUNGAN ANDA', 1, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
        Navigator.of(context).pop(true);
        // Navigator.of(context).popUntil(ModalRoute.withName('/kasir'));
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Warning'),
                  content:
                      Text('Device Tidak Konek Bluetooth, Silahkan Coba Lagi'),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        }),
                  ],
                ));
      }
    }).catchError((error) {
      print(error);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Warning'),
                content: Text('Proses Cetak Struk Gagal. ${error.toString()}'),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      }),
                ],
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TemplateMain(
      title: 'Pilih Printer',
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.print),
        label: Text('Print'),
        onPressed: _connected ? realPrint : null,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pilih Devices:'),
              Spacer(),
              !_connected
                  ? Container()
                  : TextButton.icon(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      label: Text('Disconnect'),
                      onPressed: () async {
                        await bluetooth.disconnect();
                        setState(() {
                          _connected = false;
                        });
                      },
                    ),
              _scan
                  ? InkWell(
                      child: TextButton(
                          onPressed: cancelScan,
                          child: CircularProgressIndicator()),
                    )
                  : TextButton.icon(
                      onPressed: _scan ? cancelScan : scanBlutut,
                      label: Text('Scan'),
                      icon: Icon(Icons.refresh, color: Colors.blue),
                    )
            ],
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            itemCount: _devicesList.length,
            itemBuilder: (_, int i) {
              BluetoothDevice device = _devicesList[i];
              return Container(
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  color: i == blututSelected
                      ? Colors.blue.withOpacity(.2)
                      : Colors.white,
                  boxShadow: i == blututSelected
                      ? []
                      : [
                          BoxShadow(
                              color: Colors.black.withOpacity(.2),
                              offset: Offset(5.0, 10.0),
                              blurRadius: 8.0)
                        ],
                ),
                child: ListTile(
                  onTap: () => connectBlutut(i, device),
                  leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(.2),
                      child: Icon(Icons.print, color: Colors.blue)),
                  title: Text(device.name),
                  subtitle: Text(device.address),
                  trailing: Text(
                      (i == blututSelected) && (_connected) ? 'Terhubung' : ''),
                ),
              );
            }),
      ],
    );
  }

  @override
  dispose() {
    bluetooth.disconnect();
    super.dispose();
  }
}
