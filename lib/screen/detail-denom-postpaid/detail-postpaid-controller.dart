// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/screen/transaksi/detail_postpaid.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

abstract class DetailDenomPostpaidController extends State<DetailDenomPostpaid>
    with TickerProviderStateMixin {
  TextEditingController idpel = TextEditingController();
  TextEditingController nominal = TextEditingController();
  TextEditingController namaController = TextEditingController();

  bool loading = false;
  bool isChecked = false;
  bool boxFavorite = true;
  PostpaidInquiryModel inq;
  String menuLogo = '';

  @override
  void initState() {
    _getMenuLogo();
    super.initState();
  }

  Future<void> _getMenuLogo() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {
          'Authorization': bloc.token.valueWrapper.value,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          menuLogo = json.decode(response.body)['url_image'] ?? '';
        });
      }
    } catch (err) {
      print('ERROR: $err');
    }
  }

  void cekTagihan(String kodeProduk) async {
    if (idpel.text.isEmpty) return;
    if (widget.menu.bebasNominal) {
      bool confirm = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
                  title: Text('Nominal'),
                  content: TextFormField(
                      controller: nominal,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          prefixText: 'Rp  ',
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)))),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Lanjut'.toUpperCase()),
                        onPressed: () {
                          if (nominal.text.isEmpty) return;
                          if (int.parse(nominal.text) <= 0) return;
                          Navigator.of(ctx).pop(true);
                        }),
                    TextButton(
                        child: Text('Batal'.toUpperCase()),
                        onPressed: () => Navigator.of(ctx).pop())
                  ]));
      if (confirm == null) return;
    }
    setState(() {
      loading = true;
    });
    Map<String, dynamic> dataToSend;
    if (widget.menu.bebasNominal) {
      dataToSend = {
        'kode_produk': kodeProduk,
        'tujuan': idpel.text,
        'nominal': int.parse(nominal.text),
        'counter': 1
      };
    } else {
      dataToSend = {
        'kode_produk': kodeProduk,
        'tujuan': idpel.text,
        'counter': 1
      };
    }

    http.Response response =
        await http.post(Uri.parse('$apiUrl/trx/postpaid/inquiry'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      inq = PostpaidInquiryModel.fromJson(json.decode(response.body)['data']);
      isChecked = true;
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Inquiry Gagal'),
                  content: Text(json.decode(response.body)['message']),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
    }

    checkNumberFavorite(idpel.text); // check number favorite

    setState(() {
      loading = false;
    });
  }

  void bayar() async {
    if (!isChecked) return;
    String pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => VerifikasiPin()));
    if (pin != null) {
      sendDeviceToken();
      http.Response response =
          await http.post(Uri.parse('$apiUrl/trx/postpaid/purchase'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json'
              },
              body: json.encode({'tracking_id': inq.trackingId, 'pin': pin}));
      print(response.body);
      if (response.statusCode == 200) {
        PostpaidPurchaseModel data =
            PostpaidPurchaseModel.fromJson(json.decode(response.body)['data']);
        // TrxModel trx = TrxModel(id: data.id);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => DetailPostpaid(data)));
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (_) => DetailTransaksi(trx)));
      } else {
        String message = json.decode(response.body)['message'];
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text('Pembayaran Gagal'),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            'TUTUP',
                            style: TextStyle(
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop())
                    ]));
      }
    }
  }

  void checkNumberFavorite(String tujuan) async {
    setState(() {
      idpel.text = tujuan;
    });

    Map<String, dynamic> dataToSend = {'tujuan': tujuan, 'type': 'postpaid'};

    http.Response response =
        await http.post(Uri.parse('$apiUrl/favorite/checkNumber'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json',
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        boxFavorite = !responseData['data'];
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      );

      setState(() {
        boxFavorite = true;
      });
    }
  }

  void simpanFavorite() async {
    if (idpel.text == '' || namaController.text == '') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  content: Text("Nomor Tujuan dan Nama Tidak Boleh Kosong !"),
                  actions: [
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: Navigator.of(ctx).pop)
                  ]));
    } else {
      setState(() {
        loading = true;
      });

      var dataToSend = {
        'tujuan': idpel.text,
        'nama': namaController.text,
        'type': 'postpaid',
      };

      http.Response response =
          await http.post(Uri.parse('$apiUrl/favorite/saveNumber'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json',
              },
              body: json.encode(dataToSend));

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      );

      setState(() {
        loading = false;
      });
    }
  }

  Widget loadingWidget() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SpinKitThreeBounce(
                color: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
                size: 35)));
  }

  Widget formFavorite() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                offset: Offset(5, 10),
                blurRadius: 20),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Simpan Untuk Transaksi Selanjutnya',
                  style: TextStyle(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.receipt,
                color: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
              )
            ],
          ),
          Divider(),
          SizedBox(height: 10),
          TextFormField(
            controller: idpel,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Nomor Tujuan',
                prefixIcon: Icon(Icons.contacts)),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: namaController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person)),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40.0,
            child: TextButton(
              child: Text(
                'SIMPAN',
                style: TextStyle(
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => simpanFavorite(),
            ),
          )
        ],
      ),
    );
  }
}
