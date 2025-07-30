// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/talentapay/layout/history.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/models/virtual_account.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/kyc/not_verified_user.dart';
import 'package:mobile/screen/transaksi/trx_wait.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import '../../bloc/Bloc.dart' show bloc;
import 'dart:convert';

class InquiryDynamicPrepaid extends StatefulWidget {
  final String nomorTujuan;
  final String kodeProduk;
  final int nominal;
  final String kategori;
  final String subProduk;

  InquiryDynamicPrepaid(
      this.kategori, this.kodeProduk, this.subProduk, this.nomorTujuan,
      {this.nominal});

  @override
  _InquiryDynamicPrepaidState createState() => _InquiryDynamicPrepaidState();
}

class _InquiryDynamicPrepaidState extends InquiryDynamicPrepaidController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView(
        '/menu/transaksi/dynamic/' +
            widget.kodeProduk +
            '?tujuan=' +
            widget.nomorTujuan,
        {
          'userId': bloc.userId.valueWrapper?.value,
          'title': 'Inquiry Transaksi ' + widget.kodeProduk
        });
    checkNumberFavorite(widget.nomorTujuan);
    getData(widget.kategori, widget.kodeProduk, widget.subProduk,
        widget.nomorTujuan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: configAppBloc.enableMultiChannel.valueWrapper?.value
                ? null
                : 200.0,
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Konfirmasi Pembelian'),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home_rounded),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          configAppBloc
                              .layoutApp?.valueWrapper?.value['home'] ??
                          templateConfig[
                              configAppBloc.templateCode.valueWrapper?.value],
                    ),
                    (route) => false),
              ),
            ],
          ),
          loading
              ? loadingWidget()
              : SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.1),
                                        offset: Offset(5, 10),
                                        blurRadius: 20)
                                  ]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Detail Pembelian',
                                              style: TextStyle(
                                                  color: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                          Icon(
                                            Icons.receipt,
                                            color: packageName ==
                                                    'com.lariz.mobile'
                                                ? Theme.of(context)
                                                    .secondaryHeaderColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                          )
                                        ]),
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Nama Produk',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          SizedBox(width: 5),
                                          Flexible(
                                            flex: 1,
                                            child: Text(data['nama'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.right),
                                          ),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Description',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          SizedBox(width: 5),
                                          Flexible(
                                            flex: 1,
                                            child: Text(
                                                data['description'] ?? '',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.right),
                                          ),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Nomor Tujuan',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text(data['tujuan'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Pengisian Ke',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text(data['counter'].toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Poin',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text((data['point'] ?? 0).toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    data['params'] == null
                                        ? SizedBox()
                                        : data['params'].length > 0
                                            ? ListView.separated(
                                                shrinkWrap: true,
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    data['params'].length,
                                                separatorBuilder: (_, i) =>
                                                    SizedBox(height: 10),
                                                itemBuilder: (ctx, i) {
                                                  Map<String, dynamic> item =
                                                      data['params'][i];
                                                  return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Text(item['label'],
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10)),
                                                        Flexible(
                                                          flex: 1,
                                                          child: Text(
                                                              item['value'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ]);
                                                })
                                            : SizedBox()
                                  ]),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.1),
                                        offset: Offset(5, 10),
                                        blurRadius: 20)
                                  ]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Detail Harga',
                                              style: TextStyle(
                                                  color: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                          Icon(
                                            Icons.receipt,
                                            color: packageName ==
                                                    'com.lariz.mobile'
                                                ? Theme.of(context)
                                                    .secondaryHeaderColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                          )
                                        ]),
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Harga Awal',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text(formatRupiah(data['harga_jual']),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Diskon',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text(
                                              formatRupiah(
                                                  data['discount'] ?? 0),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Cashback',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                          Text(
                                              formatRupiah(
                                                  data['cashback'] ?? 0),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    SizedBox(height: 10),
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Total Bayar',
                                              style: TextStyle(
                                                  color: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                          Text(
                                              _opsiBayar == 0
                                                  ? formatRupiah(
                                                      data['harga_jual'] -
                                                          (data['discount'] ??
                                                              0))
                                                  : formatRupiah(_jumlahBayar),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: packageName ==
                                                        'com.lariz.mobile'
                                                    ? Theme.of(context)
                                                        .secondaryHeaderColor
                                                    : Theme.of(context)
                                                        .primaryColor,
                                              )),
                                        ]),
                                  ]),
                            ),
                            SizedBox(height: boxFavorite ? 15.0 : 0.0),
                            boxFavorite
                                ? Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.1),
                                              offset: Offset(5, 10),
                                              blurRadius: 20),
                                        ]),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Simpan Nomor',
                                              style: TextStyle(
                                                color: packageName ==
                                                        'com.lariz.mobile'
                                                    ? Theme.of(context)
                                                        .secondaryHeaderColor
                                                    : Theme.of(context)
                                                        .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.receipt,
                                              color: packageName ==
                                                      'com.lariz.mobile'
                                                  ? Theme.of(context)
                                                      .secondaryHeaderColor
                                                  : Theme.of(context)
                                                      .primaryColor,
                                            )
                                          ],
                                        ),
                                        Divider(),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: tujuanController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                            labelText: 'Nomor Tujuan',
                                            prefixIcon: Icon(Icons.contacts),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: namaController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                            labelText: 'Nama',
                                            prefixIcon: Icon(Icons.person),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 40.0,
                                          child: TextButton(
                                            child: Text(
                                              'SIMPAN',
                                              style: TextStyle(
                                                color: packageName ==
                                                        'com.lariz.mobile'
                                                    ? Theme.of(context)
                                                        .secondaryHeaderColor
                                                    : Theme.of(context)
                                                        .primaryColor,
                                              ),
                                            ),
                                            onPressed: simpanFavorite,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(height: 80.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              label: Text('Bayar'),
              icon: Icon(Icons.navigate_next),
              onPressed: () => bayar(),
            ),
    );
  }
}

abstract class InquiryDynamicPrepaidController
    extends State<InquiryDynamicPrepaid> {
  TextEditingController tujuanController = TextEditingController();
  TextEditingController namaController = TextEditingController();

  bool loading = true;
  bool boxFavorite = false;
  Map<String, dynamic> data;
  List<dynamic> listPayment;

  List<VirtualAccount> vaList = [];
  int minDep = 10000;
  double adminQris = 0;
  int _opsiBayar = 0; // 0 -> SALDO, 1 -> TRANSFER BANK, 2 -> QRIS
  int _jumlahBayar = 0;

  checkMinDep(int value) async {
    int jumlah = 0;
    if (value == 1) {
      jumlah = data['harga_unik'];
    } else if (value == 2) {
      jumlah = (data['harga_unik'] +
              ((data['harga_unik'] - data['discount']) * (adminQris / 100)))
          .toInt();
      jumlah -= data['discount'];
    }

    if (jumlah >= data['min_dep']) {
      setState(() {
        _opsiBayar = value;
        _jumlahBayar = jumlah;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Minimal Pembayaran harus ${formatRupiah(minDep)}',
          isError: true,
        ),
      );
      setState(() {
        _opsiBayar = 0;
      });
    }
  }

  getData(String kategori, String kodeProduk, String subProduk,
      String tujuan) async {
    Map<String, dynamic> dataToSend;

    if (widget.nominal != null) {
      dataToSend = {
        'kategori': kategori,
        'kode_produk': kodeProduk,
        'sub_kode_produk': subProduk,
        'tujuan': tujuan,
        'nominal': widget.nominal
      };
    } else {
      dataToSend = {
        'kategori': kategori,
        'kode_produk': kodeProduk,
        'sub_kode_produk': subProduk,
        'tujuan': tujuan
      };
    }
    http.Response response =
        await http.post(Uri.parse('$apiUrl/trx/dynamic/inquiry'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        data = jsonDecode(response.body)['data'];
      });
      print(data);
    } else if (response.statusCode == 403 &&
        json.decode(response.body)['need_verification']) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>
              configAppBloc
                  .layoutApp.valueWrapper?.value['not_verified_user'] ??
              NotVerifiedPage()));
      setState(() {
        loading = false;
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(content: Text(message), actions: [
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
      Navigator.of(context).pop();
      setState(() {
        loading = false;
      });
    }
  }

  checkNumberFavorite(String tujuan) async {
    setState(() {
      tujuanController.text = tujuan;
    });

    Map<String, dynamic> dataToSend = {'tujuan': tujuan, 'type': 'prepaid'};

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

  simpanFavorite() async {
    if (tujuanController.text == '' || namaController.text == '') {
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
        'tujuan': tujuanController.text,
        'nama': namaController.text,
        'type': 'prepaid',
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

  // BAYAR VIA SALDO
  bayar() async {
    setState(() {
      loading = true;
    });

    try {
      sendDeviceToken();
      String pin = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => VerifikasiPin()));
      if (pin != null) {
        var dataToSend = {
          'kode_produk': data['kode_produk'],
          'tujuan': data['tujuan'],
          'counter': data['counter'] ?? 1,
          'pin': pin,
          'kategori': widget.kategori,
          'sub_kode_produk': widget.subProduk
        };

        if (widget.nominal != null) {
          dataToSend['nominal'] = widget.nominal;
        }

        http.Response response =
            await http.post(Uri.parse('$apiUrl/trx/dynamic/purchase'),
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
            await getLatestTrx();
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            packageName == 'com.talentapay.android'
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPageTalenta(initIndex: 1),
                    ),
                  )
                : Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(initIndex: 1),
                    ),
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

  Widget loadingWidget() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SpinKitThreeBounce(
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            size: 35,
          ),
        ),
      )
    ]));
  }
}
