// @dart=2.9

import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/select_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintSettingsPage extends StatefulWidget {
  @override   
  _PrintSettingsPageState createState() => _PrintSettingsPageState();
}

class _PrintSettingsPageState extends State<PrintSettingsPage> {
  BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  int printerType = 1;
  int fontSize = 1;

  @override
  void initState() {
    setState(() {
      printerType = bloc.printerType.valueWrapper?.value;
      fontSize = bloc.printerFontSize.valueWrapper?.value;
    });
    super.initState();
    analitycs.pageView('/print/setting', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Print Setting',
    });
  }

  Future<void> onChangeValue(int type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('printer_type', type);
    bloc.printerType.add(type);
    setState(() {
      printerType = type;
    });
    showToast(context, 'Layout cetak berhasil diubah');
  }

  Future<void> onChangeSize(int size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('printer_font_size', size);
    bloc.printerFontSize.add(size);
    setState(() {
      fontSize = size;
    });
    showToast(context, 'Ukuran font berhasil diubah');
  }

  Uint8List _printVersionOne(PaperSize paperSize, CapabilityProfile profile) {
    Generator ticket = new Generator(paperSize, profile);
    ticket.setGlobalFont(PosFontType.fontB);
    int i = fontSize - 1;
    List<PosTextSize> sizes = [
      PosTextSize.size1,
      PosTextSize.size2,
      PosTextSize.size3,
      PosTextSize.size4,
      PosTextSize.size5,
      PosTextSize.size6,
      PosTextSize.size7,
      PosTextSize.size8,
    ];

    List<int> bytes = [];

    bytes += ticket.emptyLines(1);

    bytes += ticket.text(
      bloc.user.valueWrapper?.value.namaToko.isEmpty
          ? bloc.user.valueWrapper?.value.nama
          : bloc.user.valueWrapper?.value.namaToko,
      styles: PosStyles(
        width: sizes[i + 1],
        height: sizes[i + 1],
        bold: true,
        align: PosAlign.center,
      ),
    );
    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Tanggal',
        styles: PosStyles(
          width: sizes[i],
          height: sizes[i],
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          width: sizes[i],
          height: sizes[i],
        ),
      ),
      PosColumn(
        width: 8,
        text: formatDate(DateTime.now().toIso8601String(), 'dd MMMM yyyy'),
        styles: PosStyles(
          align: PosAlign.right,
          width: sizes[i],
          height: sizes[i],
        ),
      ),
    ]);
    bytes += ticket.row([
      PosColumn(
        width: 3,
        text: 'Waktu',
        styles: PosStyles(
          width: sizes[i],
          height: sizes[i],
        ),
      ),
      PosColumn(
        width: 1,
        text: ':',
        styles: PosStyles(
          align: PosAlign.center,
          width: sizes[i],
          height: sizes[i],
        ),
      ),
      PosColumn(
        width: 8,
        text: formatDate(DateTime.now().toIso8601String(), 'HH:mm:ss'),
        styles: PosStyles(
          align: PosAlign.right,
          width: sizes[i],
          height: sizes[i],
        ),
      ),
    ]);
    bytes += ticket.hr();
    bytes += ticket.text(
      'INI ADALAH CONTOH BUKTI PEMBAYARAN',
      styles: PosStyles(
        width: sizes[i],
        height: sizes[i],
        align: PosAlign.center,
      ),
      linesAfter: 3,
    );

    return Uint8List.fromList(bytes);
  }

  Future<void> _printVersionTwo() async {
    await _bluetooth.printNewLine();
    await _bluetooth.printCustom(
      bloc.user.valueWrapper?.value.namaToko.isEmpty
          ? bloc.user.valueWrapper?.value.nama
          : bloc.user.valueWrapper?.value.namaToko,
      2,
      1,
    );
    await _bluetooth.printCustom('------------------', 0, 1);
    await _bluetooth.printLeftRight('Tanggal',
        formatDate(DateTime.now().toIso8601String(), 'dd MMMM yyyy'), 0);
    await _bluetooth.printLeftRight(
        'Waktu', formatDate(DateTime.now().toIso8601String(), 'HH:mm:ss'), 0);
    await _bluetooth.printCustom('------------------', 0, 1);
    await _bluetooth.printCustom('INI ADALAH CONTOH BUKTI PEMBAYARAN', 0, 1);
    await _bluetooth.printNewLine();
    await _bluetooth.printNewLine();
    await _bluetooth.printNewLine();
  }

  Future<void> _print() async {
    BluetoothDevice device = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectPrinterPage(),
      ),
    );
    if (device == null) return;
    if (await _bluetooth.isConnected) await _bluetooth.disconnect();
    await _bluetooth.connect(device);
    final profile = await CapabilityProfile.load();

    try {
      if (printerType == 3) {
        await _printVersionTwo();
      } else {
        Uint8List bytes = _printVersionOne(PaperSize.mm58, profile);
        if (printerType == 2) bytes = _printVersionOne(PaperSize.mm80, profile);

        int totalChunks = (bytes.length - (bytes.length % 100)) ~/ 100;
        for (int i = 0; i < totalChunks; i++) {
          if (i == totalChunks - 1) {
            await _bluetooth.writeBytes(bytes.sublist(i * 100));
          } else {
            await _bluetooth.writeBytes(bytes.sublist(i * 100, (i + 1) * 100));
          }
          await Future.delayed(Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      print(e);
      showToast(context, 'Gagal mencetak contoh struk');
    } finally {
      await _bluetooth.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Printer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.print_rounded),
            onPressed: _print,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Text(
            'LAYOUT CETAK',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          ListTile(
            onTap: () => onChangeValue(1),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 1,
              groupValue: printerType,
              onChanged: onChangeValue,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Model Cetak 1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Untuk kertas cetak dengan ukuran 58mm',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            onTap: () => onChangeValue(2),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 2,
              groupValue: printerType,
              onChanged: onChangeValue,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Model Cetak 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Untuk kertas cetak dengan ukuran 80mm',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            onTap: () => onChangeValue(3),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 3,
              groupValue: printerType,
              onChanged: onChangeValue,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Model Cetak 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Untuk ukuran kertas selain 58mm dan 80mm, hasil cetakan kurang rapi',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 5),
          Text(
            'TIPE FONT',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          ListTile(
            onTap: () => onChangeSize(1),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 1,
              groupValue: fontSize,
              onChanged: onChangeSize,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Ukuran 1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            onTap: () => onChangeSize(2),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 2,
              groupValue: fontSize,
              onChanged: onChangeSize,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Ukuran 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            onTap: () => onChangeSize(3),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Radio(
              value: 3,
              groupValue: fontSize,
              onChanged: onChangeSize,
              activeColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              'Ukuran 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
