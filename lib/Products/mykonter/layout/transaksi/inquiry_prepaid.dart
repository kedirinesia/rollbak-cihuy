// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/kyc/not_verified_user.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:mobile/screen/transaksi/trx_wait.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

class InquiryPrepaidPage extends StatefulWidget {
  final String nomorTujuan;
  final String kodeProduk;
  final int nominal;

  InquiryPrepaidPage({
    @required this.nomorTujuan,
    @required this.kodeProduk,
    this.nominal,
  });

  @override
  _InquiryPrepaidPageState createState() => _InquiryPrepaidPageState();
}

class _InquiryPrepaidPageState extends State<InquiryPrepaidPage> {
  bool _loading = true;
  int _opsiBayar = 0;
  Map<String, dynamic> data;
  TextEditingController _simpanNomor = TextEditingController();
  TextEditingController _simpanNama = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _simpanNomor.dispose();
    _simpanNama.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Map<String, dynamic> dataToSend = {
      'kode_produk': widget.kodeProduk,
      'tujuan': widget.nomorTujuan,
    };
    if (widget.nominal != null) {
      dataToSend['nominal'] = widget.nominal;
    }

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/prepaid/inquiry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode(dataToSend),
    );

    if (response.statusCode == 200) {
      data = json.decode(response.body)['data'];
      print(data);
      setState(() {
        _loading = false;
        _simpanNomor.text = data['tujuan'];
      });
    } else if (response.statusCode == 403 &&
        json.decode(response.body)['need_verification']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => NotVerifiedPage(),
        ),
      );
    } else {
      String message;
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {
        message = 'Terjadi kesalahan saat mengambil data dari server';
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Terjadi Kesalahan'),
          content: Text(message, textAlign: TextAlign.justify),
          actions: [
            TextButton(
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> purchase() async {
    if (_opsiBayar == 0 &&
        ((data['harga_jual'] - data['discount']) >
            bloc.user.valueWrapper?.value.saldo)) {
      showToast(context, 'Saldo tidak mencukupi untuk melakukan transaksi ini');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      sendDeviceToken();
      String pin = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerifikasiPin(),
        ),
      );
      if (pin == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      Map<String, dynamic> dataToSend = {
        'kode_produk': widget.kodeProduk,
        'tujuan': data['tujuan'],
        'counter': data['counter'],
        'opsi_bayar': _opsiBayar,
        'pin': pin,
      };

      if (widget.nominal != null) {
        dataToSend['nominal'] = widget.nominal;
      }

      if (_opsiBayar == 1) {
        dataToSend['unik'] = data['unik'];
      }
      print(dataToSend);

      String routePurchase = _opsiBayar == 0
          ? '$apiUrl/trx/prepaid/purchase'
          : '$apiUrl/trx/prepaid/purchaseOrder';
      print(routePurchase);

      http.Response response = await http.post(
        Uri.parse(routePurchase),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bloc.token.valueWrapper?.value,
        },
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        if (realtimePrepaid) {
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionWaitPage(),
            ),
          );
        } else {
          TrxModel trx = await getLatestTrx();
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailTransaksi(trx),
            ),
          );
        }
      } else {
        String message = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      String message = 'Terjadi kesalahan saat mengambil data dari server';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<TrxModel> getLatestTrx() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/trx/list?page=0&limit=1'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return TrxModel.fromJson(datas[0]);
    } else {
      return null;
    }
  }

  Future<void> saveNumber() async {
    if (_simpanNomor.text.isEmpty || _simpanNama.text.isEmpty)
      return showToast(context, 'Field nomor dan nama tidak boleh kosong');

    showLoading(context);

    http.Response response = await http.post(
      Uri.parse('$apiUrl/favorite/saveNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'tujuan': _simpanNomor.text.trim(),
        'nama': _simpanNama.text.trim(),
        'type': 'prepaid',
      }),
    );

    closeLoading(context);
    if (response.statusCode == 200) {
      return showToast(context, 'Berhasil menyimpan nomor tujuan');
    } else {
      return showToast(
          context, 'Terjadi kesalahan, gagal menyimpan nomor tujuan');
    }
  }

  // BAYAR OPSI LAIN
  purchaseOther() async {
    setState(() {
      _loading = true;
    });

    try {
      sendDeviceToken();
      String pin = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => VerifikasiPin()));
      if (pin != null) {
        var dataToSend = {
          'kode_produk': data['kode_produk'],
          'tujuan': data['tujuan'],
          'counter': data['counter'],
          'opsi_bayar': _opsiBayar,
          'unik': data['unik'],
          'pin': pin
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrl/trx/prepaid/purchaseOrder'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': bloc.token.valueWrapper?.value
                },
                body: json.encode(dataToSend));

        if (response.statusCode == 200) {
          if (realtimePrepaid) {
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransactionWaitPage(),
              ),
            );
          } else {
            TrxModel trx = await getLatestTrx();
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailTransaksi(trx)),
            );
          }
        } else {
          String message = json.decode(response.body)['message'] ??
              'Terjadi kesalahan pada server';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Terjadi kesalahan pada server. ERR : ${err.toString()}')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Cek dan Bayar',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before_rounded),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? SpinKitThreeBounce(
              color: Theme.of(context).primaryColor,
              size: 35,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.3),
                              child: Icon(
                                Icons.label_important_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              data['tujuan'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Rangkuman Pembelian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    data['description'],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(formatRupiah(data['harga_jual'])),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pengisian Ke'),
                                Text(data['counter'].toString()),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Poin'),
                                Text(formatNumber(data['point'])),
                              ],
                            ),
                            SizedBox(height: 10),
                            data['params'] != null
                                ? ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: data['params'].length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 10),
                                    itemBuilder: (_, i) {
                                      Map<String, dynamic> item =
                                          data['params'][i];

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item['label']),
                                          Flexible(
                                            child: Text(
                                              item['value'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : SizedBox(),
                            data['params'] != null
                                ? SizedBox(height: 10)
                                : SizedBox(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Diskon'),
                                Text(formatRupiah(data['discount'])),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cashback'),
                                Text(formatRupiah(data['cashback'])),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _opsiBayar == 1
                                      ? formatRupiah(data['harga_unik'])
                                      : formatRupiah(data['harga_jual'] -
                                          data['discount']),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Opsi Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  _opsiBayar = 0;
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Radio(
                                groupValue: _opsiBayar,
                                value: 0,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _opsiBayar = value;
                                  });
                                },
                              ),
                              title: Text('Saldo $appName'),
                              visualDensity: VisualDensity.compact,
                            ),
                            ListTile(
                              onTap: () {
                                setState(() {
                                  _opsiBayar = 1;
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Radio(
                                groupValue: _opsiBayar,
                                value: 1,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _opsiBayar = value;
                                  });
                                },
                              ),
                              title: Text('Transfer Bank'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Simpan Nomor Tujuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _simpanNomor,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(Icons.phone_android_rounded),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Nomor Tujuan',
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _simpanNama,
                              keyboardType: TextInputType.name,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(Icons.person_rounded),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Nama',
                              ),
                            ),
                            SizedBox(height: 10),
                            MaterialButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              minWidth: double.infinity,
                              elevation: 0,
                              child: Text(
                                'Simpan Nomor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: saveNumber,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.25),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: double.infinity,
                    elevation: 0,
                    child: Text(
                      'Proses Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: purchase,
                  ),
                ),
              ],
            ),
    );
  }
}
