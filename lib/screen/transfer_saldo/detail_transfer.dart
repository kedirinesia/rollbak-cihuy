// @dart=2.9

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/transfer.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

/// ------------ WATERMARK LAYER ---------------
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
/// ------------ END WATERMARK LAYER -----------

class DetailTransfer extends StatefulWidget {
  final TransferModel trf;
  final String tujuan;
  final String nama;
  final int nominal;
  DetailTransfer(this.nama, this.tujuan, this.nominal, this.trf);

  @override
  _DetailTransferState createState() => _DetailTransferState();
}

class _DetailTransferState extends State<DetailTransfer> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/detail/transfer/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Transfer',
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoUrl = configAppBloc.iconApp.valueWrapper?.value['logo'];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Detail Transfer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: headerColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Header hijau
          Container(
            height: 140,
            width: double.infinity,
            color: headerColor,
          ),

          // Card & ikon floating
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 65, bottom: 24),
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card putih dengan watermark
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
                              rotationDeg: -19,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18, 38, 18, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Judul transfer & nominal
                              Text(
                                'Transfer Berhasil',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: headerColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                formatRupiah(widget.nominal),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: headerColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 5),
                              // Tanggal & waktu
                              Text(
                                formatDate(widget.trf.createdAt, 'd MMM yyyy HH:mm:ss'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 14),

                              // Garis putus-putus
                              _buildDashedLine(),
                              SizedBox(height: 12),

                              // ===== PENAMBAHAN BARU DI SINI =====
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rincian Transfer',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: headerColor),
                                  ),
                                  Text(
                                    formatRupiah(widget.nominal),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: headerColor),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Berhasil',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: headerColor),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.check_circle,
                                          color: headerColor, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // ===== SAMPAI SINI =====

                              // Informasi Transfer header
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Informasi Transfer",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: headerColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // Baris detail yang sudah ada
                              buildRow("ID Mutasi", widget.trf.id.toUpperCase()),
                              SizedBox(height: 12),
                              buildRow("Waktu",
                                  formatDate(widget.trf.createdAt, 'd MMMM yyyy HH:mm:ss')),
                              SizedBox(height: 12),
                              buildRow("Transfer ke", widget.tujuan),
                              SizedBox(height: 12),
                              buildRow("Nama Penerima", widget.nama),
                              SizedBox(height: 12),
                              buildRow("Saldo Awal", formatRupiah(widget.trf.saldoAwal)),
                              SizedBox(height: 12),
                              buildRow("Saldo Akhir", formatRupiah(widget.trf.saldoAkhir)),
                              SizedBox(height: 18),

                              // Garis putus-putus
                              _buildDashedLine(),
                              SizedBox(height: 14),

                              // Footer metode
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Transfer Via SantrenPay',
                                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                                    SizedBox(width: 6),
                                    Icon(Icons.shield, color: Colors.grey, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon panah naik floating
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
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward,
                            color: headerColor,
                            size: 32,
                          ),
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
      // Tombol Kembali
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: headerColor,
        icon: Icon(Icons.navigate_before),
        label: Text('Kembali'),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/');
        },
      ),
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
            return Container(width: dashWidth, height: 1, color: Colors.grey.shade300);
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
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 12),
        Flexible(
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
    );
  }
}
