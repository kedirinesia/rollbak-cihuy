// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/mykonter/layout/menu/select_pdam.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/detail_postpaid.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

class PdamPage extends StatefulWidget {
  final MenuModel menu;
  PdamPage(this.menu);

  @override
  _PdamPageState createState() => _PdamPageState();
}

class _PdamPageState extends State<PdamPage> {
  TextEditingController _idpel = TextEditingController();
  TextEditingController _area = TextEditingController();
  bool _isChecked = false;
  bool _loading = false;
  MenuModel _denom;
  PostpaidInquiryModel _inq;

  @override
  void dispose() {
    _idpel.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> cekTagihan() async {
    if (_loading) return;
    if (_idpel.text.isEmpty) return;
    if (_denom == null) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/inquiry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'kode_produk': _denom.kodeProduk,
        'tujuan': _idpel.text.trim(),
        'counter': 1,
      }),
    );

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body)['data'];
      _inq = PostpaidInquiryModel.fromJson(data);
      _isChecked = true;
    } else {
      String message = 'Terjadi kesalahan saat mengambil data dari server';
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {}

      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> bayarTagihan() async {
    if (!_isChecked) return;
    if (_inq == null) return;

    setState(() {
      _loading = true;
    });

    String pin = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifikasiPin(),
      ),
    );

    if (pin == null) return;
    sendDeviceToken();

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'tracking_id': _inq.trackingId,
      }),
    );

    if (response.statusCode == 200) {
      PostpaidPurchaseModel data =
          PostpaidPurchaseModel.fromJson(json.decode(response.body)['data']);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailPostpaid(data),
        ),
      );
    } else {
      String message = 'Terjadi kesalahan saat mengambil data dari server';
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {}

      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDAM',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                Text(
                  'Nomor Pelanggan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _idpel,
                  keyboardType: widget.menu.isString
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: [
                    widget.menu.isString
                        ? FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z-_.]"))
                        : FilteringTextInputFormatter.digitsOnly,
                  ],
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(Icons.contacts_rounded),
                    //   onPressed: () async {
                    //     String nomor = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (_) => ContactPage(),
                    //       ),
                    //     );
                    //     if (nomor == null) return;
                    //     setState(() {
                    //       _idpel.text = nomor.trim();
                    //     });
                    //   },
                    // ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'No. Pelangganmu ada dalam surat tagihan. Simpan datamu supaya kamu cuma perlu memasukannya sekali ini saja',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Area PDAM',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _area,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  readOnly: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onTap: () async {
                    MenuModel denom = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SelectPdamArea(widget.menu),
                      ),
                    );

                    if (denom == null) return;
                    setState(() {
                      _area.text = denom.name;
                      _denom = denom;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Pilih area yang terkait dengan nomor pelanggan ini',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 35),
                _isChecked
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                'Informasi Tagihan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Produk',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _inq.produk,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nomor Pelanggan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _inq.noPelanggan,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _inq.nama,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _inq.params.length == 0 ? 0 : 5),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _inq.params.length,
                            separatorBuilder: (_, __) => SizedBox(height: 5),
                            itemBuilder: (_, i) {
                              Map<String, dynamic> item =
                                  _inq.params.elementAt(i);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item['value'],
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tagihan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatRupiah(_inq.tagihan),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatRupiah(_inq.admin),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cashback',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatRupiah(_inq.fee),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatRupiah(_inq.total),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Bayar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatRupiah(_inq.total - _inq.fee),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(),
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
              child: _loading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isChecked ? 'Bayar Tagihan' : 'Cek Tagihan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: _isChecked ? bayarTagihan : cekTagihan,
            ),
          ),
        ],
      ),
    );
  }
}
