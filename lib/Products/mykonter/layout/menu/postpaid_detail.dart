// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/mykonter/layout/favorite_number.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/models/favorite_number.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/detail_postpaid.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

class PostpaidDetailPage extends StatefulWidget {
  final MenuModel menu;
  PostpaidDetailPage(this.menu);

  @override
  _PostpaidDetailPageState createState() => _PostpaidDetailPageState();
}

class _PostpaidDetailPageState extends State<PostpaidDetailPage> {
  bool _loading = false;
  bool _isChecked = false;
  PostpaidInquiryModel _inquiryData;
  TextEditingController _idpel = TextEditingController();
  TextEditingController _nominal = TextEditingController();
  TextEditingController _simpanNama = TextEditingController();

  @override
  void dispose() {
    _idpel.dispose();
    _nominal.dispose();
    _simpanNama.dispose();
    super.dispose();
  }

  Future<void> cekTagihan() async {
    if (_loading) return;
    if (_idpel.text.isEmpty) return;
    if (widget.menu.bebasNominal && _nominal.text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    Map<String, dynamic> dataToSend = {
      'kode_produk': widget.menu.kodeProduk,
      'tujuan': _idpel.text.trim(),
      'counter': 1,
    };

    if (widget.menu.bebasNominal)
      dataToSend['nominal'] = int.parse(_nominal.text.trim());

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/inquiry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode(dataToSend),
    );

    if (response.statusCode == 200) {
      _isChecked = true;
      _inquiryData =
          PostpaidInquiryModel.fromJson(json.decode(response.body)['data']);
      _simpanNama.text = _inquiryData.nama;
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
    if (_loading) return;
    if (_inquiryData.total > bloc.user.valueWrapper?.value.saldo) {
      showToast(context, 'Saldo tidak mencukupi untuk melakukan transaksi ini');
      return;
    }

    String pin = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifikasiPin(),
      ),
    );

    if (pin == null) return;
    setState(() {
      _loading = true;
    });
    sendDeviceToken();

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'tracking_id': _inquiryData.trackingId,
      }),
    );

    if (response.statusCode == 200) {
      PostpaidPurchaseModel data = json.decode(response.body)['data'];
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

  Future<void> saveNumber() async {
    if (_simpanNama.text.isEmpty)
      return showToast(context, 'Field nama tidak boleh kosong');

    showLoading(context);

    http.Response response = await http.post(
      Uri.parse('$apiUrl/favorite/saveNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'tujuan': _inquiryData.noPelanggan.trim(),
        'nama': _simpanNama.text.trim(),
        'type': 'postpaid',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu.name,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before_rounded),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.person_search_rounded),
            onPressed: () async {
              FavoriteNumberModel favNumber = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FavoriteNumberPage(type: 'postpaid'),
                ),
              );

              if (favNumber == null) return;
              _idpel.text = favNumber.tujuan;
              cekTagihan();
            },
          ),
        ],
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
                    //   icon: Icon(Icons.contacts),
                    //   onPressed: () async {
                    //     _idpel.text = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (_) => ContactPage(),
                    //       ),
                    //     );
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
                SizedBox(height: widget.menu.bebasNominal ? 10 : 0),
                widget.menu.bebasNominal
                    ? Text(
                        'Nominal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: widget.menu.bebasNominal ? 5 : 0),
                widget.menu.bebasNominal
                    ? TextField(
                        controller: _nominal,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          prefixText: 'Rp ',
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 15),
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
                          SizedBox(height: 5),
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
                                  _inquiryData.produk,
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
                                  _inquiryData.noPelanggan,
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
                                  _inquiryData.nama,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: _inquiryData.params.length == 0 ? 0 : 5),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _inquiryData.params.length,
                            separatorBuilder: (_, __) => SizedBox(height: 5),
                            itemBuilder: (_, i) {
                              Map<String, dynamic> item =
                                  _inquiryData.params.elementAt(i);
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
                                  formatRupiah(_inquiryData.tagihan),
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
                                  formatRupiah(_inquiryData.admin),
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
                                  formatRupiah(_inquiryData.fee),
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
                                  formatRupiah(_inquiryData.total),
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
                                  formatRupiah(
                                      _inquiryData.total - _inquiryData.fee),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                'Simpan Nomor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
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
