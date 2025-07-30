// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/select_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------- WATERMARK LAYER --------
class WatermarkNetworkLogo extends StatelessWidget {
  final String logoUrl;
  final double size;
  final double opacity;
  final double rotationDeg;

  const WatermarkNetworkLogo({
    Key key,
    @required this.logoUrl,
    this.size = 48,
    this.opacity = 0.13,
    this.rotationDeg = -19,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl.isEmpty) return SizedBox();
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final rows = (constraints.maxHeight / (size * 1.5)).ceil();
        final cols = (constraints.maxWidth / (size * 2.1)).ceil();
        List<Widget> marks = [];
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            final top = i * size * 1.5;
            final left = j * size * 2.1 + (i.isOdd ? size : 0);
            marks.add(Positioned(
              top: top,
              left: left,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotationDeg * math.pi / 180,
                  child: Image.network(
                    logoUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: size),
                  ),
                ),
              ),
            ));
          }
        }
        return IgnorePointer(child: Stack(children: marks));
      },
    );
  }
}
// -------- END WATERMARK LAYER --------

Widget buildDashedLine() {
  return LayoutBuilder(
    builder: (_, constraints) {
      final dashWidth = 7.0;
      final dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dashCount, (_) {
          return Container(
              width: dashWidth, height: 1, color: Colors.grey.shade400);
        }),
      );
    },
  );
}

class PrintPreview extends StatefulWidget {
  final TrxModel trx;
  final bool isPostpaid;
  PrintPreview({Key key, this.trx, this.isPostpaid = false}) : super(key: key);
  @override
  _PrintPreviewState createState() => _PrintPreviewState();
}

class _PrintPreviewState extends PrintPreviewController {
  BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  ScreenshotController _screenshotController = ScreenshotController();
  File image;

  @override
  void initState() {
    super.initState();

    if (widget.trx.print == null || widget.trx.print.isEmpty) {
      trxData = widget.trx;
      harga = trxData.harga_jual ?? 0;
      admin = trxData.admin ?? 0;
      total = harga + admin + cetak;
      txtHarga.text = harga.toString();
      txtAdmin.text = admin.toString();
      loadEditHargaLokal();
      labelHarga =
          (trxData.produk != null && trxData.produk['kode_produk'] == 'MUTASI')
              ? 'Nominal'
              : 'Harga';
      showSN = trxData.sn != null && trxData.sn.isNotEmpty;
      print(labelHarga);
      setState(() {});
    } else {
      getData();
    }
    analitycs.pageView('/transaksi/' + widget.trx.id + '/print',
        {'userId': bloc.userId.valueWrapper.value, 'title': 'Print Transaksi'});
  }

  Future<void> share() async {
    Directory temp = await getTemporaryDirectory();
    image = await File('${temp.path}/trx_${widget.trx.id}.png').create();
    Uint8List bytes = await _screenshotController.capture(
        pixelRatio: 2.5, delay: Duration(milliseconds: 100));
    if (bytes != null) {
      await image.writeAsBytes(bytes);
      await Share.file(
        'Transaksi ${widget.trx.produk != null ? widget.trx.produk['nama'] : ''}',
        'trx_${widget.trx.id}.png',
        bytes,
        'image/png',
      );
    }
  }

  Future<void> simpanEditHarga() async {
    setState(() {
      harga = int.tryParse(txtHarga.text) ?? 0;
      admin = int.tryParse(txtAdmin.text) ?? 0;
      total = harga + admin + cetak;
      showEditor = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('harga_${widget.trx.id}', harga);
    await prefs.setInt('admin_${widget.trx.id}', admin);

    showToast(context, 'Perubahan disimpan untuk transaksi ini');
  }

  Future<void> loadEditHargaLokal() async {
    final prefs = await SharedPreferences.getInstance();
    final localHarga = prefs.getInt('harga_${widget.trx.id}');
    final localAdmin = prefs.getInt('admin_${widget.trx.id}');

    if (localHarga != null) {
      harga = localHarga;
      txtHarga.text = localHarga.toString();
    }

    if (localAdmin != null) {
      admin = localAdmin;
      txtAdmin.text = localAdmin.toString();
    }

    total = harga + admin + cetak;
    setState(() {});
  }

  Widget snWidget() {
    if (showSN) {
      if (trxData.print.length == 0) {
        return buildRow("Nomor Serial", trxData.sn ?? '-');
      } else {
        return SizedBox();
      }
    } else {
      if (trxData.print
              .where((el) => el['label'].toString().toLowerCase() == 'token')
              .length >
          0) {
        final tokenValue = trxData.print
            .where((el) => el['label'].toString().toLowerCase() == 'token')
            .first['value'];
        return buildRow("Token", tokenValue ?? '-');
      } else {
        return SizedBox();
      }
    }
  }

  Future<void> startPrint() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    bool isOn = await _bluetooth.isOn;

    if (status != PermissionStatus.granted) {
      showToast(context, 'Aplikasi memerlukan izin bluetooth');
      return;
    }
    if (!isOn) {
      showToast(context, 'Bluetooth belum aktif');
      return;
    }

    BluetoothDevice device = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SelectPrinterPage()));
    if (device == null) return;

    if (await _bluetooth.isConnected) await _bluetooth.disconnect();
    await _bluetooth.connect(device);
    final _profile = await CapabilityProfile.load();

    try {
      Generator generator = Generator(PaperSize.mm58, _profile);
      List<int> bytes = [];
      // HEADER
      bytes += generator.text(
        bloc.user.valueWrapper.value.namaToko.isEmpty
            ? bloc.user.valueWrapper.value.nama
            : bloc.user.valueWrapper.value.namaToko,
        styles: PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1,
      );
      bytes += generator.text(
        bloc.user.valueWrapper.value.alamatToko.isEmpty
            ? bloc.user.valueWrapper.value.alamat
            : bloc.user.valueWrapper.value.alamatToko,
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.text(
        formatDate(trxData.created_at, 'd MMMM yyyy HH:mm:ss'),
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'TrxID: ${trxData.id.toUpperCase()}',
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.hr();
      bytes += generator.text('Transaksi:',
          styles: PosStyles(underline: true), linesAfter: 1);

      final isMutasi =
          (trxData.produk != null && trxData.produk['kode_produk'] == 'MUTASI');
      if (isMutasi) {
        // Mutasi/transfer
        bytes += generator.row([
          PosColumn(text: 'Jenis', width: 6),
          PosColumn(
              text: trxData.produk['nama'] ?? '-',
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        bytes += generator.row([
          PosColumn(text: 'Nominal', width: 6),
          PosColumn(
              text: formatRupiah(harga),
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        trxData.print?.forEach((el) {
          bytes += generator.row([
            PosColumn(text: el['label'] ?? '-', width: 6),
            PosColumn(
                text: el['value'] ?? '-',
                width: 6,
                styles: PosStyles(align: PosAlign.right)),
          ]);
        });
        bytes += generator.row([
          PosColumn(text: 'Keterangan', width: 6),
          PosColumn(
              text: trxData.tujuan ?? '-',
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
      } else {
        // Transaksi reguler
        bytes += generator.row([
          PosColumn(text: 'Produk', width: 6),
          PosColumn(
              text: trxData.produk['nama'] ?? '-',
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        bytes += generator.row([
          PosColumn(text: 'Tujuan', width: 6),
          PosColumn(
              text: trxData.tujuan ?? '-',
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        bytes += generator.row([
          PosColumn(text: labelHarga, width: 6),
          PosColumn(
              text: formatRupiah(harga),
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        bytes += generator.row([
          PosColumn(text: 'Admin', width: 6),
          PosColumn(
              text: formatRupiah(admin),
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        trxData.print?.forEach((el) {
          bytes += generator.row([
            PosColumn(text: el['label'] ?? '-', width: 6),
            PosColumn(
                text: el['value'] ?? '-',
                width: 6,
                styles: PosStyles(align: PosAlign.right)),
          ]);
        });
        if (showSN && (trxData.sn != null && trxData.sn.isNotEmpty)) {
          bytes += generator.text('SN: ${trxData.sn}',
              styles: PosStyles(align: PosAlign.center, bold: true),
              linesAfter: 1);
        }
      }

      bytes += generator.hr();
      bytes += generator.text(
        'Total: ${formatRupiah(total)}',
        styles: PosStyles(bold: true, align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.hr();
      bytes += generator.text('Struk ini merupakan bukti pembayaran yang sah',
          styles: PosStyles(align: PosAlign.center), linesAfter: 2);

      await _bluetooth.writeBytes(Uint8List.fromList(bytes));
      showToast(context, 'Berhasil mencetak struk');
    } catch (e) {
      showToast(context, 'Gagal mencetak struk');
    } finally {
      await _bluetooth.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = Color(0xFF43B368);
    if (trxData == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('Struk Transaksi'),
          backgroundColor: headerColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isSuccess = trxData.status == 2;
    final isPending = trxData.status == 0;
    final statusIcon = isSuccess
        ? Icons.check
        : isPending
            ? Icons.access_time
            : Icons.close;
    final statusText = isSuccess
        ? "Transaksi Berhasil"
        : isPending
            ? "Transaksi Pending"
            : "Transaksi Gagal";
    final statusColor = isSuccess
        ? headerColor
        : isPending
            ? Colors.orange
            : Colors.red;
    final logoUrl = configAppBloc.iconApp.valueWrapper?.value['logo'];

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Struk Transaksi'),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (_) => false,
              );
            },
          ),
          IconButton(icon: Icon(Icons.share_rounded), onPressed: share),
          IconButton(
            icon: Icon(Icons.edit_rounded),
            onPressed: () {
              setState(() {
                showEditor = !showEditor;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.print),
        backgroundColor: headerColor,
        onPressed: startPrint,
      ),
      body: Stack(
        children: [
          Container(color: headerColor, height: 130, width: double.infinity),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 55, bottom: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.8,
                      ),
                      padding: EdgeInsets.fromLTRB(18, 38, 18, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (logoUrl != null && logoUrl.isNotEmpty)
                            Positioned.fill(
                              child: WatermarkNetworkLogo(
                                logoUrl: logoUrl,
                                size: 48,
                                opacity: 0.13,
                                rotationDeg: -19,
                              ),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                trxData.produk != null
                                    ? "${trxData.produk['nama']} - ${trxData.tujuan ?? '-'}"
                                    : "-",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3D5A7A),
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 50),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      formatDate(trxData.created_at,
                                          "d MMM yyyy HH:mm"),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "TrxID : ${trxData.id?.toUpperCase()}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              buildDashedLine(),
                              SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Detail Transaksi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              buildRow(
                                "Status",
                                isSuccess
                                    ? "Berhasil"
                                    : isPending
                                        ? "Pending"
                                        : "Gagal",
                                color: statusColor,
                                isBold: true,
                                icon: isSuccess
                                    ? Icons.check_circle
                                    : isPending
                                        ? Icons.access_time
                                        : Icons.cancel,
                              ),
                              buildRow(
                                (trxData.produk != null &&
                                        trxData.produk['kode_produk'] ==
                                            'MUTASI')
                                    ? 'Jenis'
                                    : "Jenis Transaksi",
                                trxData.produk['nama'] ?? '-',
                              ),
                              buildRow(
                                (trxData.produk != null &&
                                        trxData.produk['kode_produk'] ==
                                            'MUTASI')
                                    ? 'Keterangan'
                                    : "Nomor",
                                trxData.tujuan ?? '-',
                              ),
                              buildRow(
                                (trxData.produk != null &&
                                        trxData.produk['kode_produk'] ==
                                            'MUTASI')
                                    ? 'Nominal'
                                    : labelHarga,
                                formatRupiah(harga),
                              ),
                              if (!(trxData.produk != null &&
                                  trxData.produk['kode_produk'] == 'MUTASI'))
                                buildRow("Admin", formatRupiah(admin)),
                              trxData.print != null
                                  ? Column(
                                      children: trxData.print.map<Widget>((el) {
                                        return buildRow(
                                            el['label'], el['value']);
                                      }).toList(),
                                    )
                                  : SizedBox(),
                              snWidget(),
                              SizedBox(height: 10),
                              Divider(thickness: 1, height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Bayar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(formatRupiah(total),
                                      style: TextStyle(
                                          color: Color(0xFF2676C5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 10),
                              buildDashedLine(),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Struk Ini Adalah Bukti Pembayaran Yang Sah",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: Colors.grey[600],
                                    size: 28,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // — Floating Status Icon —
                  Positioned(
                    top: -27,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 32),
                      ),
                    ),
                  ),
                  // Edit Harga/Admin
                  if (showEditor)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.11),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                  controller: txtHarga,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: labelHarga,
                                      prefixText: 'Rp '),
                                  onChanged: (value) => setState(() {
                                        if (value == null || value.isEmpty) {
                                          harga = 0;
                                          total = 0 + admin + cetak;
                                        } else {
                                          harga = int.parse(value);
                                          total = harga + admin + cetak;
                                        }
                                      })),
                              SizedBox(height: 10),
                              TextFormField(
                                  controller: txtAdmin,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Admin',
                                      prefixText: 'Rp '),
                                  onChanged: (value) => setState(() {
                                        if (value == null || value.isEmpty) {
                                          admin = 0;
                                          total = harga + 0 + cetak;
                                        } else {
                                          admin = int.parse(value);
                                          total = harga + admin + cetak;
                                        }
                                      })),
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: headerColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Simpan'),
                                  onPressed: simpanEditHarga,
                                ),
                              ),
                              TextButton(
                                child: Text("Tutup"),
                                onPressed: () {
                                  setState(() => showEditor = false);
                                },
                              ),
                            ],
                          ),
                        ),
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

  Widget buildRow(String label, String value,
      {Color color, bool isBold = false, IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13))),
          Expanded(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(icon, size: 16, color: color ?? Colors.black54),
                  ),
                Flexible(
                  child: Text(
                    value ?? '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: color ?? Colors.black,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------ CONTROLLER LOGIC ---------
abstract class PrintPreviewController extends State<PrintPreview>
    with TickerProviderStateMixin {
  TrxModel trxData;
  List<Map<String, dynamic>> additionalData = [];
  bool showEditor = false;
  bool showSN = false;
  bool showDefaultTagihan = true;
  bool showDefaultAdmin = true;
  int harga = 0;
  int admin = 0;
  int cetak = 0;
  int total = 0;
  String labelHarga = "Harga";

  TextEditingController txtHarga = TextEditingController();
  TextEditingController txtAdmin = TextEditingController();
  TextEditingController txtCetak = TextEditingController();

  void getData() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/trx/${widget.trx.id}/print'),
        headers: {'Authorization': bloc.token.valueWrapper.value});

    if (response.statusCode == 200) {
      trxData = TrxModel.fromJson(json.decode(response.body)['data']);
      String kodeProduk = trxData.produk['kode_produk'];
      admin = trxData.admin;
      harga = trxData.harga_jual;
      total = harga + admin + cetak;
      txtHarga.text = harga.toString();
      txtAdmin.text = admin.toString();
      labelHarga = kodeProduk.startsWith("PLN") ? 'Nominal' : 'Harga';
      trxData.print.forEach((el) {
        if (el['label'].toString().toLowerCase() == 'admin') {
          admin = int.parse(el['value']);
          total = harga + admin + cetak;
          txtAdmin.text = admin.toString();
        }
        if (['tagihan', 'jumlah', 'nominal']
            .contains(el['label'].toString().toLowerCase())) {
          labelHarga = el['label'];
          harga = int.parse(el['value']);
          total = harga + admin + cetak;
          txtHarga.text = harga.toString();
        }
      });
      if (trxData.print
              .where((el) => el['label'].toString().toLowerCase() == 'token')
              .length ==
          0) {
        showSN = true;
      }
      setState(() {});
    } else {
      print('Error: ${response.body}');
    }
  }
}
