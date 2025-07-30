// @dart=2.9

import 'dart:convert';

import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/paymobileku/layout/history.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/inquiry_prepaid.dart';
import 'package:mobile/screen/transaksi/list_voucher_denom.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:http/http.dart' as http;

class BulkPage extends StatefulWidget {
  final MenuModel menu;
  const BulkPage(this.menu, {Key key}) : super(key: key);

  @override
  State<BulkPage> createState() => _BulkPageState();
}

class _BulkPageState extends State<BulkPage> {
  bool _loading = false;
  TextEditingController _voucherCode = TextEditingController();
  TextEditingController _voucherStartCode = TextEditingController();
  TextEditingController _voucherEndCode = TextEditingController();
  List<Map<String, dynamic>> _masterVouchers = [];
  List<Map<String, dynamic>> _vouchers = [];
  PrepaidDenomModel _denom;
  bool _isPromo = false;
  int totalHarga = 0;
  int _filteredStatus = 0;
  String _voucherLabel = 'Semua Voucher :';

  @override
  void dispose() {
    _voucherCode.dispose();
    _voucherStartCode.dispose();
    _voucherEndCode.dispose();
    super.dispose();
  }

  void _calculateTotalHarga() {
    totalHarga = _denom.harga_jual * _vouchers.length;
    print("Total Harga: $totalHarga");
  }

  void _generateVoucher() {
    if (_loading) return;

    try {
      String startCodeText = _voucherStartCode.text.trim();
      String endCodeText = _voucherEndCode.text.trim();

      if (startCodeText.isEmpty || endCodeText.isEmpty) return;

      int startCode = int.parse(startCodeText);
      int endCode = int.parse(endCodeText);

      if (startCode == endCode) return;
      _masterVouchers.clear();

      int codeLength = startCodeText.length;

      if (startCode <= endCode) {
        for (int i = startCode; i <= endCode; i++) {
          String code = i.toString().padLeft(codeLength, '0');
          _masterVouchers.add({
            'code': code,
            'selected': true,
            'status': 1,
          });
        }
      } else {
        for (int i = startCode; i >= endCode; i--) {
          String code = i.toString().padLeft(codeLength, '0');
          _masterVouchers.add({
            'code': code,
            'selected': true,
            'status': 1,
          });
        }
      }

      _vouchers = _masterVouchers;
      _calculateTotalHarga();

      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  Future<void> _scanBarcode(String type) async {
    if (_loading) return;

    ScanResult result = await BarcodeScanner.scan();
    if (result.rawContent.isEmpty) return;
    setState(() {
      if (type == 'start') {
        _voucherStartCode.text = result.rawContent;
      } else if (type == 'end') {
        _voucherEndCode.text = result.rawContent;
      } else if (type == 'single') {
        _voucherCode.text = result.rawContent;
      }
    });
  }

  Future<void> _selectDenom() async {
    if (_loading) return;

    PrepaidDenomModel result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListVoucherDenomPage(widget.menu),
      ),
    );

    if (result == null) return;

    setState(() {
      _denom = result;
      _isPromo = result.harga_promo != null &&
          result.harga_promo > 0 &&
          result.harga_jual > result.harga_promo;
    });
  }

  Future<void> _processVoucher() async {
    if (widget.menu.jenis == 5) {
      if (_denom == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InquiryPrepaid(_denom.kode_produk, _voucherCode.text.trim()),
        ),
      );
      return;
    } else if (widget.menu.jenis == 6) {
      if (_denom == null || _vouchers.length == 0) return;

      bool isBalanceEnough = await _checkBalance();
      if (!isBalanceEnough) {
        return;
      }

      bool status = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(
            'Setelah memasukkan kode PIN, sistem akan memotong saldo dan memproses transaksi anda tanpa melalui proses inquiry. Apakah anda yakin untuk melanjutkan transaksi ?',
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(
                'LANJUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            TextButton(
              child: Text(
                'BATAL',
                style: TextStyle(
                  color: Colors.red.shade600,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      );
      if (!status) return;

      try {
        if (_loading) return;

        setState(() {
          _loading = true;
        });

        String pin = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifikasiPin(),
          ),
        );
        if (pin == null) return;

        sendDeviceToken();

        String startVoucherCode = _vouchers[0]['code'];
        var dataToSend = {
          'kode_produk': _denom.kode_produk,
          'startFrom': startVoucherCode,
          'length': _vouchers.length,
          'pin': pin,
        };

        http.Response response = await http
            .post(
              Uri.parse('$apiUrl/trx/voucher/bulk/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': bloc.token.valueWrapper.value,
              },
              body: json.encode(dataToSend),
            )
            .timeout(Duration(minutes: 5));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          for (var voucher in _vouchers) {
            voucher['status'] = 2;
          }
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(ctx).pop(); // Menutup dialog/alert

                  getLatestTrx().then((trx) {
                    if (trx != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HistoryPage(initIndex: 1),
                        ),
                      );
                    }
                  });
                });
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('Transaksi berhasil diproses'),
                );
              });
        } else {
          for (var voucher in _vouchers) {
            voucher['status'] = 3;
          }
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error'),
              content: Text('Transaksi gagal diproses'),
            ),
          );
        }
      } on TimeoutException catch (_) {
        // Menangani TimeoutException
        for (var voucher in _vouchers) {
          voucher['status'] = 3;
        }
        print('Request timed out');
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<TrxModel> getLatestTrx() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/trx/list?page=0&limit=1'),
      headers: {
        'Authorization': bloc.token.valueWrapper.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return TrxModel.fromJson(datas[0]);
    } else {
      return null;
    }
  }

  Future<bool> _checkBalance() async {
    double totalAmount = _denom.harga_jual.toDouble() * _vouchers.length;

    if (bloc.user.valueWrapper.value.saldo < totalAmount) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(ctx).pop(); // Menutup dialog/alert
            });
            return AlertDialog(
              title: Text('Error'),
              content: Text('Saldo tidak cukup.'),
            );
          });
      return false;
    } else {
      return true;
    }
  }

  // Future<void> _purchaseVoucher(int index, String pin) async {
  //   try {
  //     var dataToSend = {
  //       'kode_produk': _denom!.kode_produk,
  //       'tujuan': _vouchers[index]['code'],
  //       'counter': 1,
  //       'pin': pin,
  //     };

  //     http.Response response = await http
  //         .post(
  //           Uri.parse('$apiUrl/bayar/baru'),
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Authorization': bloc.token.valueWrapper!.value,
  //           },
  //           body: json.encode(dataToSend),
  //         )
  //         .timeout(Duration(minutes: 5)); // Menambahkan timeout di sini
  //     if (response.statusCode == 200) {
  //       _vouchers[index]['status'] = 2;
  //     } else {
  //       _vouchers[index]['status'] = 3;
  //     }
  //   } on TimeoutException catch (_) {
  //     // Menangani TimeoutException
  //     _vouchers[index]['status'] = 3;
  //     print('Request timed out');
  //   } catch (err) {
  //     _vouchers[index]['status'] = 3;
  //     print(err);
  //   } finally {
  //     setState(() {});
  //   }
  // }

  Widget _content() {
    if (widget.menu.jenis == 6) {
      // VOUCHER MASSAL
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Voucher Awal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _voucherStartCode,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_2_rounded),
                color: Theme.of(context).primaryColor,
                onPressed: () => _scanBarcode('start'),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Kode Voucher Akhir',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _voucherEndCode,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_2_rounded),
                color: Theme.of(context).primaryColor,
                onPressed: () => _scanBarcode('end'),
              ),
            ),
          ),
          SizedBox(height: 15),
          MaterialButton(
            minWidth: double.infinity,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Theme.of(context).primaryColor,
            colorBrightness: Brightness.dark,
            elevation: 0,
            child: Text('Generate Voucher'),
            onPressed: _generateVoucher,
          ),
          Divider(),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                _voucherLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Spacer(),
              Builder(
                builder: (_) {
                  int selectedVoucher = 0;
                  int totalVoucher = _vouchers.length;

                  _vouchers.forEach((voucher) {
                    if (voucher['selected']) selectedVoucher++;
                  });

                  return Text(
                    '$selectedVoucher / $totalVoucher',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _vouchers.length == 0
                ? Container(
                    child: Center(
                      child: Text(
                        'Tidak Ada Voucher'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _vouchers.length,
                    itemBuilder: (_, i) {
                      Map<String, dynamic> voucher = _vouchers[i];
                      Color bgColor = Colors.transparent;

                      if (voucher['selected']) {
                        switch (voucher['status']) {
                          case 1:
                            bgColor = Colors.amber.shade100;
                            break;
                          case 2:
                            bgColor = Colors.green.shade100;
                            break;
                          case 3:
                            bgColor = Colors.red.shade100;
                            break;
                          default:
                            bgColor = Colors.transparent;
                        }
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey.shade300,
                              width: .5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              fillColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor,
                              ),
                              value: voucher['selected'],
                              onChanged: (value) {
                                if (_loading) return;

                                setState(() {
                                  voucher['selected'] = value;
                                });
                              },
                            ),
                            Text(voucher['code']),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      // VOUCHER MANUAL
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Voucher',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _voucherCode,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_2_rounded),
                color: Theme.of(context).primaryColor,
                onPressed: () => _scanBarcode('single'),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voucher'),
        centerTitle: true,
        elevation: 0,
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _selectDenom,
                    child: _denom == null
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Klik Untuk Pilih Produk'.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.15),
                                  offset: Offset(3, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            width: double.infinity,
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: CachedNetworkImage(
                                  imageUrl: widget.menu.icon,
                                  errorWidget: (_, __, ___) => SizedBox(),
                                ),
                              ),
                              title: Text(
                                _denom.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(_denom.description),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatRupiah(_isPromo
                                        ? _denom.harga_promo
                                        : _denom.harga_jual),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  _isPromo
                                      ? Text(
                                          formatRupiah(_denom.harga_jual),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red.shade600,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: _content(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Colors.grey.withOpacity(.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        SizedBox(height: 3),
                        Text(
                          formatRupiah(totalHarga),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      minWidth: double.infinity,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: Theme.of(context).primaryColor,
                      disabledColor: Colors.grey.shade200,
                      colorBrightness: Brightness.dark,
                      elevation: 0,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey)),
                      child: _loading
                          ? SpinKitThreeBounce(color: Colors.white, size: 20)
                          : Text(widget.menu.jenis == 5
                              ? 'Lanjutkan'
                              : 'Proses Voucher'),
                      onPressed: _denom == null ? null : _processVoucher,
                    ),
                  )
                ],
              ),
            ),
            // child: MaterialButton(
            //   minWidth: double.infinity,
            //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //   color: Theme.of(context).primaryColor,
            //   disabledColor: Colors.grey.shade200,
            //   colorBrightness: Brightness.dark,
            //   elevation: 0,
            //   shape: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //       borderSide: BorderSide(color: Colors.grey)),
            //   child: _loading
            //       ? SpinKitThreeBounce(
            //           color: Colors.white,
            //           size: 20,
            //         )
            //       : Text(
            //           widget.menu.jenis == 5 ? 'Lanjutkan' : 'Proses Voucher'),
            //   onPressed: _denom == null ? null : _processVoucher,
            // ),
          ),
        ],
      ),
    );
  }
}
