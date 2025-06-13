// @dart=2.9
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/print_mutasi.dart';
import 'package:mobile/screen/transaksi/select_printer.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailMutasi extends StatefulWidget {
  final MutasiModel mutasi;

  DetailMutasi(this.mutasi);

  @override
  _DetailMutasiState createState() => _DetailMutasiState();
}

class _DetailMutasiState extends State<DetailMutasi> {
  BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/mutasi/detail/' + widget.mutasi.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Mutasi',
    });
  }

  Uint8List v1(PaperSize paperSize, CapabilityProfile profile) {
    // Ticket ticket = new Ticket(paperSize);
    Generator ticket = new Generator(paperSize, profile);
    List<int> bytes = [];

    ticket.setGlobalFont(PosFontType.fontB);
    ticket.setStyles(PosStyles(height: PosTextSize.size1));

    bytes += ticket.emptyLines(1);
    bytes += ticket.text(
      formatRupiah(widget.mutasi.jumlah * -1),
      styles: PosStyles(
        bold: true,
        fontType: PosFontType.fontA,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text(
      ' Transfer berhasil ',
      styles: PosStyles(
        reverse: true,
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text(
      widget.mutasi.id.toUpperCase(),
      styles: PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.emptyLines(2);
    bytes += ticket.hr(ch: '-');
    bytes += ticket.text(
      'RINCIAN TRANSFER',
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
      ),
    );
    bytes += ticket.hr(ch: '-');
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Pengirim',
        styles: PosStyles(
          bold: true,
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
      PosColumn(
        width: 8,
        text: bloc.user.valueWrapper?.value.nama,
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Nominal',
        styles: PosStyles(
          bold: true,
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
      PosColumn(
        width: 8,
        text: formatRupiah(widget.mutasi.jumlah * -1),
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Sumber Dana',
        styles: PosStyles(
          bold: true,
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
      PosColumn(
        width: 8,
        text: 'Saldo',
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Keterangan',
        styles: PosStyles(
          bold: true,
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
      PosColumn(
        width: 8,
        text: widget.mutasi.keterangan,
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);
    bytes += ticket.hr(ch: '-', linesAfter: 1);
    bytes += ticket.text(
      'Transfer via $appName',
      styles: PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text(
      formatDate(widget.mutasi.created_at, 'dd MMM yyyy HH:mm'),
      styles: PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.emptyLines(3);

    return Uint8List.fromList(bytes);
  }

  Future<void> v2() async {
    await _bluetooth.printNewLine();
    await _bluetooth.printCustom(formatRupiah(widget.mutasi.jumlah * -1), 3, 1);
    await _bluetooth.printCustom('Transfer Berhasil', 0, 1);
    await _bluetooth.printCustom(widget.mutasi.id.toUpperCase(), 0, 1);
    await _bluetooth.printNewLine();
    await _bluetooth.printNewLine();
    await _bluetooth.printCustom('------------------', 0, 1);
    await _bluetooth.printCustom('RINCIAN TRANSFER', 1, 1);
    await _bluetooth.printCustom('------------------', 0, 1);
    await _bluetooth.printLeftRight(
        'Pengirim', bloc.user.valueWrapper?.value.nama, 0);
    await _bluetooth.printLeftRight(
        'Nominal', formatRupiah(widget.mutasi.jumlah * -1), 0);
    await _bluetooth.printLeftRight('Sumber Dana', 'Saldo', 0);
    await _bluetooth.printLeftRight('Keterangan', widget.mutasi.keterangan, 0);
    await _bluetooth.printCustom('------------------', 0, 1);
    await _bluetooth.printNewLine();
    await _bluetooth.printCustom('Transfer via $appName', 0, 1);
    await _bluetooth.printCustom(
        formatDate(widget.mutasi.created_at, 'dd MMM yyyy HH:mm'), 0, 1);
    await _bluetooth.printNewLine();
    await _bluetooth.printNewLine();
    await _bluetooth.printNewLine();
  }

  Future<bool> checkBluetooth() async {
    bool isOn = await _bluetooth.isOn;
    if (!isOn) {
      showToast(context, 'Bluetooth belum aktif');
      return false;
    }

    PermissionStatus status = await Permission.accessMediaLocation.status;

    if (status != PermissionStatus.granted) {
      showToast(context, 'Aplikasi tidak diizinkan untuk mengakses bluetooth');
      return false;
    }

    return true;
  }

  Future<void> startPrint() async {
    bool status = await checkBluetooth();
    if (!status) return;

    BluetoothDevice device = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SelectPrinterPage()));
    if (device == null) return;

    if (await _bluetooth.isConnected) await _bluetooth.disconnect();
    await _bluetooth.connect(device);
    final profile = await CapabilityProfile.load();

    try {
      switch (bloc.printerType.valueWrapper?.value) {
        case 1:
          await _bluetooth.writeBytes(v1(PaperSize.mm58, profile));
          break;
        case 2:
          await _bluetooth.writeBytes(v1(PaperSize.mm80, profile));
          break;
        case 3:
          await v2();
          break;
        default:
          await _bluetooth.writeBytes(v1(PaperSize.mm58, profile));
      }
      showToast(context, 'Berhasil mencetak struk');
    } catch (_) {
      showToast(context, 'Gagal mencetak struk');
    } finally {
      await _bluetooth.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Mutasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        Theme.of(context).canvasColor
                      ],
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter),
                ),
                child: Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        formatRupiah(widget.mutasi.jumlah < 0
                            ? widget.mutasi.jumlah * -1
                            : widget.mutasi.jumlah),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(widget.mutasi.jumlah < 0 ? 'DEBIT' : 'KREDIT',
                        style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold))
                  ],
                )),
              ),
              Flexible(
                flex: 1,
                child: ListView(
                  padding: EdgeInsets.all(15),
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                offset: Offset(5, 10.0),
                                blurRadius: 20)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Informasi Mutasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                  )),
                              Icon(
                                Icons.info,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(height: 15),
                          Text('ID Mutasi',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 5),
                          Text(widget.mutasi.id.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Waktu',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 5),
                          Text(
                              formatDate(widget.mutasi.created_at,
                                  'd MMMM yyyy HH:mm:ss'),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Saldo Awal',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 5),
                          Text(formatRupiah(widget.mutasi.saldo_awal),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Saldo Akhir',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 5),
                          Text(formatRupiah(widget.mutasi.saldo_akhir),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Keterangan',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          SizedBox(height: 5),
                          Text(widget.mutasi.keterangan,
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          widget.mutasi.type == 'KS'
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          heroTag: 'print-1',
                          backgroundColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          child: Icon(Icons.print_rounded),
                          onPressed: startPrint,
                        ),
                        SizedBox(height: 15),
                        FloatingActionButton(
                          backgroundColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          child: Icon(Icons.share_rounded),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PrintMutasiPage(widget.mutasi),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(width: 0, height: 0),
        ],
      ),
    );
  }
}
