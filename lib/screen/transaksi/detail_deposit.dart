// @dart=2.9
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/deposit.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/topup/bank/transfer-deposit.dart';
import 'package:qr_flutter/qr_flutter.dart';

const String apiUrl = 'https://santren-app.findig.id/api/v1';

/// -------- WATERMARK LAYER --------
class WatermarkNetworkLogo extends StatelessWidget {
  final String logoUrl;
  final double size;
  final double opacity;
  final double rotationDeg;

  const WatermarkNetworkLogo({
  Key key,
  @required this.logoUrl,
  this.size = 100,     
  this.opacity = 0.22,  
  this.rotationDeg = -19,
}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl.isEmpty) return SizedBox();
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final rows = (constraints.maxHeight / (size * 0.9)).ceil();
        final cols = (constraints.maxWidth / (size * 2.1)).ceil();
        List<Widget> marks = [];
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            final top = i * size * 0.9;
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
/// -------- END WATERMARK LAYER --------

class DetailDeposit extends StatefulWidget {
  final DepositModel dep;
  DetailDeposit(this.dep);

  @override
  _DetailDepositState createState() => _DetailDepositState();
}

class _DetailDepositState extends DetailDepositController {
  DepositModel _dep;
  bool _loadingDetail = true;
  String namaPengguna = '-';
  bool loadingNama = true;

  @override
  void initState() {
    super.initState();
    _dep = widget.dep;
    _fetchDetail();
    getNamaPengguna();
    analitycs.pageView('/deposit/detail/' + widget.dep.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Deposit',
    });
  }

  Future<void> _fetchDetail() async {
    final token = bloc.token.valueWrapper?.value;
    setState(() => _loadingDetail = true);
    try {
      final resp = await http.get(
        Uri.parse('$apiUrl/trx/${widget.dep.id}'),
        headers: {'Authorization': token},
      );
      print('RAW DETAIL API: ${resp.body}');
      if (resp.statusCode == 200) {
        final jsonBody = json.decode(resp.body);
        final body = jsonBody['data'] ?? jsonBody;
        setState(() {
          _dep = DepositModel.fromJson(body);
          _loadingDetail = false;
        });
      } else {
        print('Detail fetch failed: ${resp.statusCode}');
        setState(() => _loadingDetail = false);
      }
    } catch (e) {
      print('ERROR _fetchDetail: $e');
      setState(() => _loadingDetail = false);
    }
  }

  Future<void> getNamaPengguna() async {
    final token = bloc.token.valueWrapper != null
        ? bloc.token.valueWrapper.value
        : null;
    setState(() => loadingNama = true);
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/info'),
        headers: {'Authorization': token},
      );
      print('RESPONSE BODY user/info: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String hasilNama = '-';
        if (data['nama'] != null && data['nama'].toString().isNotEmpty) {
          hasilNama = data['nama'];
        } else if (data['data'] != null &&
            data['data']['nama'] != null &&
            data['data']['nama'].toString().isNotEmpty) {
          hasilNama = data['data']['nama'];
        }
        setState(() {
          namaPengguna = hasilNama;
          loadingNama = false;
        });
      } else {
        setState(() {
          namaPengguna = '-';
          loadingNama = false;
        });
      }
    } catch (e) {
      print('ERROR getNamaPengguna: $e');
      setState(() {
        namaPengguna = '-';
        loadingNama = false;
      });
    }
  }

  String safe(String s) => s != null && s.trim().isNotEmpty ? s : '-';

  Widget fab() {
    if (_dep.statusModel.status == 0 &&
        (_dep.type == 1 || _dep.type == 2)) {
      return FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        icon: Icon(Icons.navigate_next),
        label: Text('Bayar Sekarang'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransferDepositPage(_dep.nominal, _dep.type),
          ),
        ),
      );
    } else if (_dep.statusModel.status == 0 &&
        (_dep.type == 5 ||
            _dep.vaname == 'alfamart' ||
            _dep.vaname == 'indomaret')) {
      return FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text('Salin Kode Pembayaran'),
        icon: Icon(Icons.content_copy),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: _dep.kodePembayaran));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Kode pembayaran berhasil disalin")));
        },
      );
    } else {
      return null;
    }
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
              width: dashWidth,
              height: 1,
              color: Colors.grey.shade300,
            );
          }),
        );
      },
    );
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Berhasil';
      default:
        return 'Gagal';
    }
  }

  IconData getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.access_time;
      case 1:
        return Icons.check;
      default:
        return Icons.cancel;
    }
  }

  // Widget Kode Pembayaran agar tidak memakan tempat
  Widget buildKodePembayaran(String kode) {
    if (kode == null || kode.isEmpty) return Text('-');
    final tampil = kode.length > 24 ? kode.substring(0, 24) + '...' : kode;
    return Tooltip(
      message: kode,
      child: Text(
        tampil,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget buildRow(String label, Widget valueWidget,
      {Color color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Flexible(child: valueWidget),
        ],
      ),
    );
  }

  Widget buildRowText(String label, String value,
      {Color color, bool isBold = false}) {
    return buildRow(
      label,
      Text(
        value ?? '-',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
      ),
      color: color,
      isBold: isBold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _dep?.statusModel?.status ?? 0;
    final headerColor = Color(0xFF43B368);
    final statusIcon = getStatusIcon(status);
    final statusColor = getStatusColor(status);
    final statusText = getStatusText(status);
    final logoUrl =
        configAppBloc.iconApp.valueWrapper.value['logo']?.toString() ?? "";

    final double minCardHeight = MediaQuery.of(context).size.height - 120;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Detail Deposit'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: headerColor,
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
      floatingActionButton: !_loadingDetail ? fab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            color: headerColor,
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 65, bottom: 24),
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card utama min full height
                  Container(
                    constraints: BoxConstraints(
                      minHeight: minCardHeight,
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
                              size: 90,
                              opacity: 0.09,
                              rotationDeg: -19,
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Deposit $statusText',
                              style: TextStyle(
                                fontSize: 16,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              formatRupiah(_dep.nominal),
                              style: TextStyle(
                                fontSize: 22,
                                color: headerColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatDate(_dep.created_at, 'd MMM yyyy HH:mm:ss'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 14),
                            if (_dep.type == 8 &&
                                _dep.kodePembayaran?.isNotEmpty == true)
                              Column(
                                children: [
                                  QrImageView(
                                    data: _dep.kodePembayaran,
                                    size: 130,
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                            _buildDashedLine(),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Informasi Deposit",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: headerColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Status",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  status == 1
                                      ? Icons.check_circle
                                      : status == 0
                                          ? Icons.access_time
                                          : Icons.cancel,
                                  color: statusColor,
                                  size: 16,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            buildRow("Kode Pembayaran",
                                buildKodePembayaran(_dep.kodePembayaran)),
                            SizedBox(height: 10),
                            buildRowText("Nominal", formatRupiah(_dep.nominal)),
                            SizedBox(height: 10),
                            buildRowText("Biaya Admin", formatRupiah(_dep.admin)),
                            SizedBox(height: 10),
                            buildRowText("Keterangan", safe(_dep.keterangan)),
                            SizedBox(height: 10),
                            buildRowText("Waktu Deposit",
                                formatDate(_dep.created_at, 'd MMM yyyy HH:mm:ss')),
                            SizedBox(height: 10),
                            buildRowText("Waktu Kadaluarsa",
                                formatDate(_dep.expired_at, 'd MMM yyyy HH:mm:ss')),
                            SizedBox(height: 14),
                            _buildDashedLine(),
                            SizedBox(height: 10),
                            buildRowText("Nama Pengguna",
                                loadingNama ? "Memuat..." : namaPengguna),
                            SizedBox(height: 10),
                            buildRowText("Nama Akun Virtual",
                                safe(_dep.vaname?.toUpperCase())),
                            SizedBox(height: 18),
                            Center(
                              child: Icon(
                                Icons.verified_user_rounded,
                                color: headerColor.withOpacity(0.25),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Floating status icon
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
                            statusIcon,
                            color: statusColor,
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
    );
  }
}

abstract class DetailDepositController extends State<DetailDeposit>
    with TickerProviderStateMixin {}
