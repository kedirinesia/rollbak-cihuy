// @dart=2.9
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screen/transaksi/select_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/modules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../bloc/Bloc.dart';

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

class CetakMutasiPage extends StatefulWidget {
  final MutasiModel mutasi;
  CetakMutasiPage({Key key, @required this.mutasi}) : super(key: key);

  @override
  _CetakMutasiPageState createState() => _CetakMutasiPageState();
}

class _CetakMutasiPageState extends State<CetakMutasiPage> {
  ScreenshotController _screenshotController = ScreenshotController();
  bool showEditor = false;
  TextEditingController txtNominal = TextEditingController();
  int nominal;
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  @override
  void initState() {
    super.initState();
    nominal = widget.mutasi.jumlah ?? 0;
    txtNominal.text = nominal.toString();
    loadNominalLokal();
  }

  Future<void> simpanNominalLokal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mutasi_nominal_${widget.mutasi.id}', value);
  }

  Future<void> loadNominalLokal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNominal = prefs.getInt('mutasi_nominal_${widget.mutasi.id}');
    if (savedNominal != null) {
      setState(() {
        nominal = savedNominal;
        txtNominal.text = nominal.toString();
      });
    }
  }

  Future<void> shareScreenshot() async {
    Directory temp = await getTemporaryDirectory();
    File image =
        await File('${temp.path}/mutasi_${widget.mutasi.id}.png').create();
    Uint8List bytes = await _screenshotController.capture(
      pixelRatio: 2.5,
      delay: Duration(milliseconds: 100),
    );
    if (bytes != null) {
      await image.writeAsBytes(bytes);
      await Share.file(
        'Struk Mutasi',
        'mutasi_${widget.mutasi.id}.png',
        bytes,
        'image/png',
      );
    }
  }

  Future<void> startPrint() async {
    final printer = BlueThermalPrinter.instance;

    // Minta izin lokasi (diperlukan untuk Bluetooth)
    final permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) {
      showToast(context,
          'Aplikasi memerlukan izin lokasi untuk menggunakan Bluetooth.');
      return;
    }

    // Cek status Bluetooth
    final isOn = await printer.isOn;
    if (!isOn) {
      showToast(
          context, 'Bluetooth belum aktif. Silakan aktifkan terlebih dahulu.');
      return;
    }

    // Pilih perangkat printer
    final BluetoothDevice device = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SelectPrinterPage()),
    );

    if (device == null) {
      showToast(context, 'Printer tidak dipilih.');
      return;
    }

    try {
      // Disconnect jika sudah terkoneksi
      if (await printer.isConnected) {
        await printer.disconnect();
      }

      // Connect ke printer baru
      await printer.connect(device);

      // Load profil dan generator ESC/POS
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Ambil data toko dari BLoC
      final toko = bloc.user.valueWrapper.value;
      final namaToko =
          toko.namaToko?.isNotEmpty == true ? toko.namaToko : toko.nama;
      final alamatToko = toko.alamat ?? '-';

      // Header
      bytes += generator.text(namaToko,
          styles: PosStyles(align: PosAlign.center, bold: true), linesAfter: 1);
      bytes += generator.text(alamatToko,
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);
      bytes += generator.text(
        formatDate(widget.mutasi.created_at, "d MMMM yyyy HH:mm:ss"),
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text('MutasiID: ${widget.mutasi.id.toUpperCase()}',
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);
      bytes += generator.hr();

      // Isi Mutasi
      bytes += generator.text('Detail Mutasi:',
          styles: PosStyles(underline: true), linesAfter: 1);
      bytes += generator.row([
        PosColumn(text: 'Jenis', width: 6),
        PosColumn(
            text: widget.mutasi.type ?? '-',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Keterangan', width: 6),
        PosColumn(
            text: widget.mutasi.keterangan ?? '-',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Nominal', width: 6),
        PosColumn(
            text: formatRupiah(nominal),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Saldo Awal', width: 6),
        PosColumn(
            text: formatRupiah(widget.mutasi.saldo_awal),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Saldo Akhir', width: 6),
        PosColumn(
            text: formatRupiah(widget.mutasi.saldo_akhir),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      bytes += generator.hr();
      bytes += generator.text(
        'Total Mutasi: ${formatRupiah(nominal)}',
        styles: PosStyles(bold: true, align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.hr();
      bytes += generator.text(
        'Struk ini adalah bukti mutasi yang sah',
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 2,
      );

      await printer.writeBytes(Uint8List.fromList(bytes));
      showToast(context, 'Struk berhasil dicetak');
    } catch (e) {
      showToast(context, 'Gagal mencetak struk: $e');
    } finally {
      await printer.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = Color(0xFF43B368);
    final screenHeight = MediaQuery.of(context).size.height;
    final logoUrl = configAppBloc.iconApp.valueWrapper?.value['logo'];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Struk Mutasi'),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: shareScreenshot,
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded),
            onPressed: () {
              setState(() {
                showEditor = !showEditor;
              });
            },
          ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: headerColor,
        child: Icon(Icons.print),
        onPressed: () => startPrint(),
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
                                'Mutasi Saldo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: headerColor,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                widget.mutasi.id?.toUpperCase() ?? '-',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      formatDate(widget.mutasi.created_at,
                                          "d MMM yyyy HH:mm"),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Saldo: ${formatRupiah(widget.mutasi.saldo_akhir)}",
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
                                  "Detail Mutasi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              buildRow("Jenis", widget.mutasi.type ?? "-"),
                              buildRow("Keterangan",
                                  widget.mutasi.keterangan ?? "-"),
                              buildRow("Nominal", formatRupiah(nominal)),
                              buildRow("Saldo Awal",
                                  formatRupiah(widget.mutasi.saldo_awal)),
                              buildRow("Saldo Akhir",
                                  formatRupiah(widget.mutasi.saldo_akhir)),
                              SizedBox(height: 20),
                              Divider(thickness: 1, height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Mutasi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(formatRupiah(nominal),
                                      style: TextStyle(
                                          color: Color(0xFF2676C5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 20),
                              buildDashedLine(),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Struk Ini Adalah Bukti Mutasi Yang Sah",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
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
                        child: Icon(
                          Icons.compare_arrows, // Icon mutasi
                          color: headerColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // ==== EDITOR MODAL ====
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
                                controller: txtNominal,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nominal',
                                  prefixText: 'Rp ',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    nominal = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
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
                                  onPressed: () async {
                                    final parsed =
                                        int.tryParse(txtNominal.text) ?? 0;
                                    setState(() {
                                      nominal = parsed;
                                      showEditor = false;
                                    });
                                    await simpanNominalLokal(parsed);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Nominal berhasil disimpan untuk transaksi ini.')),
                                    );
                                  },
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

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13))),
          Expanded(
            flex: 7,
            child: Text(
              value ?? '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
