// @dart=2.9

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/Products/santren/layout/print_mutasi.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
// <-- Pastikan path benar

class WatermarkNetworkLogo extends StatelessWidget {
  final String logoUrl;
  final double size;
  final double opacity;
  final double rotationDeg;

  const WatermarkNetworkLogo({
    Key key,
    @required this.logoUrl,
    this.size = 60,
    this.opacity = 0.02,
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

class DetailMutasi extends StatefulWidget {
  final MutasiModel mutasi;
  DetailMutasi(this.mutasi);

  @override
  _DetailMutasiState createState() => _DetailMutasiState();
}

class _DetailMutasiState extends State<DetailMutasi> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/mutasi/detail/' + widget.mutasi.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Mutasi',
    });
  }

  /// Mapping MutasiModel ke TrxModel agar bisa di-print seperti transaksi biasa
  TrxModel mutasiToTrx(MutasiModel mutasi) {
    return TrxModel(
      id: mutasi.id,
      created_at: mutasi.created_at,
      tujuan: mutasi.keterangan ?? '-',
      harga_jual: mutasi.jumlah ?? 0,
      admin: 0,
      sn: '',
      produk: {
        'nama': (mutasi.type ?? 'Mutasi'),
        'kode_produk': 'MUTASI',
        'type': (mutasi.type?.toLowerCase() == 'transfer') ? 1 : 0,
      },
      status: 2,
      print: [
        {'label': 'Saldo Awal', 'value': formatRupiah(mutasi.saldo_awal)},
        {'label': 'Saldo Akhir', 'value': formatRupiah(mutasi.saldo_akhir)},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoUrl = configAppBloc.iconApp.valueWrapper?.value['logo'];
    final nominal = widget.mutasi.jumlah;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Detail Mutasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: headerColor,
        iconTheme: IconThemeData(color: Colors.white),
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
          Container(height: 140, width: double.infinity, color: headerColor),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 65, bottom: 24),
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    constraints: BoxConstraints(minHeight: screenHeight * 0.8),
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
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18, 38, 18, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if ((widget.mutasi.type ?? '').toLowerCase() ==
                                  'transfer') ...[
                                Text(
                                  'Transfer Berhasil',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: headerColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                              Text(
                                formatRupiah(nominal),
                                style: TextStyle(
                                  fontSize: 22,
                                  color:
                                      nominal > 0 ? Colors.green : headerColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                widget.mutasi.id.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 14),
                              _buildDashedLine(),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Informasi Mutasi',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: headerColor),
                                  ),
                                  Icon(Icons.info, color: headerColor),
                                ],
                              ),
                              SizedBox(height: 12),
                              buildRow(
                                  'ID Mutasi', widget.mutasi.id.toUpperCase()),
                              SizedBox(height: 8),
                              buildRow(
                                  'Waktu',
                                  formatDate(widget.mutasi.created_at,
                                      'd MMMM yyyy HH:mm:ss')),
                              SizedBox(height: 8),
                              buildRow('Saldo Awal',
                                  formatRupiah(widget.mutasi.saldo_awal)),
                              SizedBox(height: 8),
                              buildRow('Saldo Akhir',
                                  formatRupiah(widget.mutasi.saldo_akhir)),
                              SizedBox(height: 8),
                              buildRow('Keterangan', widget.mutasi.keterangan),
                              SizedBox(height: 14),
                              _buildDashedLine(),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(' Transfer Via Santren Pay',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(width: 6),
                                  Icon(Icons.shield,
                                      color: Colors.grey, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        child: Icon(Icons.arrow_upward,
                            color: headerColor, size: 32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final mutasiType = widget.mutasi.type?.toUpperCase() ?? '';
          print('[DEBUG] Mutasi Type: $mutasiType');
          print('[DEBUG] Mutasi ID: ${widget.mutasi.id}');
          print('[DEBUG] Keterangan: ${widget.mutasi.keterangan}');

          if (mutasiType == 'KS') {
            print(
                '[DEBUG] Menampilkan tombol cetak karena ini transfer saldo (KS)');
            return FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: Icon(Icons.print),
              label: Text('Print'),
              onPressed: () {
                print('[DEBUG] Tombol print ditekan');
                TrxModel trx = mutasiToTrx(widget.mutasi);
                print('[DEBUG] TrxModel: ${trx.toString()}');
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CetakMutasiPage(mutasi: widget.mutasi),
                ));
              },
            );
          } else {
            print(
                '[DEBUG] Tombol cetak disembunyikan, karena bukan transfer (bukan KS)');
            return SizedBox.shrink();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 7.0;
        final dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
                width: dashWidth, height: 1, color: Colors.grey.shade300);
          }),
        );
      },
    );
  }

  Widget buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(value ?? '-',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
