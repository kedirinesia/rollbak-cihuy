// @dart=2.9

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/models/bank.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/print.dart';
import 'package:screenshot/screenshot.dart';

/// ------------ WATERMARK LAYER ---------------
class WatermarkNetworkLogo extends StatelessWidget {
  final String logoUrl;
  final double size;
  final double opacity;
  final double rotationDeg;

  const WatermarkNetworkLogo({
    Key key,
    @required this.logoUrl,
    this.size = 48,
    this.opacity = 0.12,
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

class DetailTransaksi extends StatefulWidget {
  final TrxModel data;
  DetailTransaksi(this.data);

  @override
  _DetailTransaksiState createState() => _DetailTransaksiState();
}

class _DetailTransaksiState extends State<DetailTransaksi> {
  final _refreshController = RefreshController(initialRefresh: false);
  TrxModel trx;
  List<BankModel> banks = [];
  ScreenshotController _screenshot = ScreenshotController();
  bool danaApp = false;
  bool customPrint = false;
  String customHeaderText = "";
  String customFooterText = "";

  @override
  void initState() {
    super.initState();
    trx = widget.data;
    analitycs.pageView('/history/transaksi/' + trx.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Transaksi'
    });
    _loadData();
    _checkDanaApp();
  }

  void _checkDanaApp() {
    InstalledApps.getAppInfo('id.dana').then((_) {
      setState(() => danaApp = true);
    }).catchError((_) {
      setState(() => danaApp = false);
    });
  }

  Future<void> _loadData() async {
    final resp = await http.get(
      Uri.parse('$apiUrl/trx/${trx.id}/print'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );
    if (resp.statusCode == 200) {
      final d = json.decode(resp.body)['data'];
      if (d['produk'] == null || d['produk'].isEmpty) {
        d['produk'] = widget.data.produk ?? {};
      }
      if (d['payment_by'] == 'transfer') await _loadBanks();
      setState(() => trx = TrxModel.fromJson(d));
    }
  }

  Future<void> _loadBanks() async {
    final resp = await http.get(
      Uri.parse('$apiUrl/bank/list?type=1'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body)['data'] as List;
      banks = list.map((e) => BankModel.fromJson(e)).toList();
    }
  }

  @override
  Widget build(BuildContext c) {
    final headerColor = Color(0xFF43B368);
    final isSuccess = trx.status == 2;
    final isPending = trx.status == 0;
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

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Detail Transaksi'),
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
        ],
      ),
      floatingActionButton: trx.status == 2
          ? FloatingActionButton(
              child: Icon(Icons.print),
              backgroundColor: headerColor,
              onPressed: () {
                if (trx.produk == null || trx.produk.isEmpty) {
                  trx.produk = widget.data.produk ?? {};
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrintPreview(
                      trx: trx,
                      isPostpaid:
                          trx.produk['type'] != null && trx.produk['type'] == 1,
                    ),
                  ),
                );
              },
            )
          : null,
      body: Stack(
        children: [
          Container(color: headerColor, height: 130, width: double.infinity),
          SmartRefresher(
            controller: _refreshController,  
            onRefresh: () async {
              await _loadData();
              _refreshController.refreshCompleted();
            },
            enablePullUp: false,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 55, bottom: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // — White Card + Watermark —
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            150, // Ubah angka sesuai kebutuhan
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
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
                                trx.produk != null
                                    ? "${trx.produk['nama']} - ${trx.tujuan ?? '-'}"
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
                                      formatDate(
                                          trx.created_at, "d MMM yyyy HH:mm"),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "TrxID : ${trx.id?.toUpperCase()}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildDashedLine(),
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
                                  "Jenis Transaksi", trx.produk['nama'] ?? '-'),
                              buildRow("No HP", trx.tujuan ?? '-'),
                              buildRow("Jumlah", formatRupiah(trx.harga_jual)),
                              buildRow("Admin", formatRupiah(trx.admin)),
                              buildRow("Nomor Serial", trx.sn ?? '-'),
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
                                  Text(formatRupiah(trx.harga_jual),
                                      style: TextStyle(
                                          color: Color(0xFF2676C5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildDashedLine(),
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
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          "Transaksi diamankan",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.left,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
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
