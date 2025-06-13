// @dart=2.9

import 'package:flutter/material.dart';

// install package
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// component
import 'package:mobile/component/template-main.dart';

// model
import 'package:mobile/models/kasir/kasirPrint.dart';

// config bloc
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class SelectPrintIOS extends StatefulWidget {
  final KasirPrintModel printTrx;

  SelectPrintIOS(this.printTrx);

  @override
  createState() => SelectPrintIOSState();
}

class SelectPrintIOSState extends State<SelectPrintIOS> {
  PrinterBluetoothManager _printerBluetoothManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  PrinterBluetooth _device;
  bool _connected = false;
  bool _scan = true;
  int blututSelected = -1;

  @override
  initState() {
    super.initState();
    initBlutut();
  }

  void initBlutut() async {
    _printerBluetoothManager.startScan(Duration(seconds: 10));
    _printerBluetoothManager.isScanningStream.listen((isScan) async {
      print('isScan device --> $isScan');
      setState(() {
        _scan = isScan;
      });
    });
  }

  void connectBlutut(index, d) async {
    setState(() {
      blututSelected = index;
      _device = d;
      _connected = true;
    });
  }

  void realPrint() async {
    print('device ---> $_device');
    if (_device != null) {
      _printerBluetoothManager.stopScan();
      final profile = await CapabilityProfile.load();
      Generator ticket = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // DRAW HEADER
      bytes += ticket.emptyLines(2);
      bytes += ticket.text(
          bloc.user.valueWrapper?.value.namaToko == ''
              ? bloc.username.valueWrapper?.value
              : bloc.user.valueWrapper?.value.namaToko,
          styles: PosStyles(
              align: PosAlign.center,
              fontType: PosFontType.fontA,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              bold: true));
      bytes += ticket.text(
          bloc.user.valueWrapper?.value.alamatToko == ''
              ? bloc.user.valueWrapper?.value.alamat
              : bloc.user.valueWrapper?.value.alamatToko,
          styles: PosStyles(align: PosAlign.center, bold: true));
      bytes += ticket.emptyLines(1);
      bytes += ticket.text(
          'TGL : ${formatDate(widget.printTrx.created_at, 'd MMMM yyyy HH:mm:ss')}',
          styles: PosStyles(align: PosAlign.left));
      bytes += ticket.text('NO : ${widget.printTrx.id.toUpperCase()}',
          styles: PosStyles(align: PosAlign.left));
      bytes += ticket.text('KASIR : ${widget.printTrx.userID['nama']}',
          styles: PosStyles(align: PosAlign.left));
      bytes += ticket.emptyLines(1);
      // END HEADER

      // BODY STRUK
      widget.printTrx.detailTrx.forEach((d) {
        bytes += ticket.text('${d['nama_barang'].toUpperCase()}',
            styles: PosStyles(align: PosAlign.left));
        bytes += ticket.row([
          PosColumn(
            width: 5,
            text: '${d['qty']} x ${formatNominal(d['harga_jual'])}',
          ),
          PosColumn(
              width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              width: 6,
              text: '${formatNominal(d['total_harga'])}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
      });
      bytes += ticket.row([
        PosColumn(
          width: 4,
          text: 'PEMBAYARAN',
        ),
        PosColumn(
            width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            width: 7,
            text: '${widget.printTrx.termin.toUpperCase()}',
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += ticket.row([
        PosColumn(
          width: 4,
          text: 'TOTAL HARGA',
        ),
        PosColumn(
            width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            width: 7,
            text: '${formatNominal(widget.printTrx.totalJual)}',
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += ticket.row([
        PosColumn(
          width: 4,
          text: 'UANG BAYAR',
        ),
        PosColumn(
            width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            width: 7,
            text: '${formatNominal(widget.printTrx.terbayar)}',
            styles: PosStyles(align: PosAlign.right)),
      ]);

      if (widget.printTrx.termin.toUpperCase() == 'CASH') {
        bytes += ticket.row([
          PosColumn(
            width: 4,
            text: 'KEMBALIAN',
          ),
          PosColumn(
              width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              width: 7,
              text:
                  '${formatNominal(widget.printTrx.terbayar - widget.printTrx.totalJual)}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
      } else {
        bytes += ticket.row([
          PosColumn(
            width: 4,
            text: 'JUMLAH HUTANG',
          ),
          PosColumn(
              width: 1, text: ':', styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              width: 7,
              text:
                  '${formatNominal(widget.printTrx.totalJual - widget.printTrx.terbayar)}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
      }
      // END BODY
      bytes += ticket.emptyLines(2);

      // FOOTER STRUK
      bytes += ticket.text('TERIMA KASIH ATAS KUNJUNGAN ANDA',
          styles: PosStyles(align: PosAlign.center));
      bytes += ticket.emptyLines(1);
      // END FOOTER
      bytes += ticket.cut();

      // SHOW LOADING
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SpinKitFadingCircle(
              size: 30, color: Theme.of(context).primaryColor));
      // END LOADING

      // CETAK STRUK
      _printerBluetoothManager.selectPrinter(_device);
      final PosPrintResult res =
          await _printerBluetoothManager.printTicket(bytes);
      _printerBluetoothManager.stopScan();
      // END
      Navigator.of(context, rootNavigator: true).pop(); // HIDE LOADING

      // Navigator.of(context).popUntil(ModalRoute.withName('/kasir')); // REDIRECT TO DASHBOARD KASIR
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
            children: <Widget>[
              Text('Pilih Devices:'),
              Spacer(),
              _scan
                  ? InkWell(
                      child: TextButton(
                          onPressed: () {}, child: CircularProgressIndicator()),
                    )
                  : TextButton.icon(
                      onPressed: () async {
                        _printerBluetoothManager.stopScan();
                        _printerBluetoothManager
                            .startScan(Duration(seconds: 4));
                        setState(() {
                          _connected = false;
                        });
                      },
                      label: Text('Scan'),
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context).primaryColor),
                    )
            ],
          ),
        ),
        StreamBuilder<List<PrinterBluetooth>>(
            stream: _printerBluetoothManager.scanResults,
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData) {
                return ListView.separated(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    itemCount: snapshot.data.length,
                    separatorBuilder: (_, i) => Divider(),
                    itemBuilder: (_, i) {
                      PrinterBluetooth device = snapshot.data[i];
                      return Container(
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
                          trailing: Text((i == blututSelected) && (_connected)
                              ? 'Terhubung'
                              : ''),
                        ),
                      );
                    });
              }
            })
      ],
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
