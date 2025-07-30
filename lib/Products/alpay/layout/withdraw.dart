// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/models/wd_bank.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:mobile/screen/wd/list_bank.dart';
import 'package:http/http.dart' as http;

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  TextEditingController bank = TextEditingController();
  TextEditingController tujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();
  TextEditingController namaController = TextEditingController();
  WithdrawBankModel selectedBank;
  PostpaidInquiryModel inq;
  bool loading = false;
  bool checked = false;
  bool boxFavorite = false;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/withdraw/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Withdraw',
    });
  }

  @override
  void dispose() {
    bank.dispose();
    tujuan.dispose();
    nominal.dispose();
    super.dispose();
  }

  void getBank() async {
    WithdrawBankModel item = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WithdrawBankPage()));
    if (item == null) return;
    bank.text = item.nama;
    selectedBank = item;

    setState(() {});
  }

  void checkNumberFavorite(String notujuan) async {
    setState(() {
      tujuan.text = notujuan;
    });

    Map<String, dynamic> dataToSend = {'tujuan': notujuan, 'type': 'WD'};

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
                    color: Theme.of(context).primaryColor,
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
    if (tujuan.text == '' || namaController.text == '') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  content: Text("Nomor Tujuan dan Nama Tidak Boleh Kosong !"),
                  actions: [
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: Navigator.of(ctx).pop)
                  ]));
    } else {
      setState(() {
        loading = true;
      });

      var dataToSend = {
        'tujuan': tujuan.text,
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
                    color: Theme.of(context).primaryColor,
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

  void inquiry() async {
    if (nominal.text.isEmpty || tujuan.text.isEmpty || selectedBank == null)
      return;
    if (int.parse(nominal.text) < 10000) {
      String message = 'Nominal withdraw minimal Rp 10.000';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
      return;
    }
    if (bloc.user.valueWrapper?.value.saldo <
        (selectedBank.admin + int.parse(nominal.text))) {
      String message = 'Saldo tidak mencukupi untuk melakukan withdraw';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
      return;
    }

    setState(() {
      loading = true;
    });

    Map<String, dynamic> dataToSend = {
      'kode_produk': selectedBank.kodeProduk,
      'tujuan': tujuan.text,
      'nominal': int.parse(nominal.text),
      'counter': 1
    };

    http.Response response =
        await http.post(Uri.parse('$apiUrl/trx/postpaid/inquiry'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': bloc.token.valueWrapper?.value
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      checkNumberFavorite(tujuan.text);
      Map<String, dynamic> data = json.decode(response.body)['data'];
      inq = PostpaidInquiryModel.fromJson(data);
      checked = true;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }

    setState(() {
      loading = false;
    });
  }

  void purchase() async {
    if (!bloc.user.valueWrapper?.value.kyc_verification) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Transaksi Gagal'),
          content: Text(
              'Akun anda belum diverifikasi, transaksi dibatalkan. Silahkan verifikasi akun untuk dapat menikmati fitur tarik saldo',
              textAlign: TextAlign.justify),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SubmitKyc1()));
      return;
    }

    String pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => VerifikasiPin()));
    if (pin == null) return;

    setState(() {
      loading = true;
    });
    sendDeviceToken();
    http.Response response = await http.post(
        Uri.parse('$apiUrl/trx/postpaid/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bloc.token.valueWrapper?.value
        },
        body: json
            .encode({'tracking_id': inq.trackingId, 'nominal': nominal.text}));

    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text('Berhasil'),
                  content: Text(
                      'Transaksi sedang di proses, anda dapat melihat status transaksi di riwayat transaksi'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('TUTUP'))
                  ]));
      nominal.clear();
      bank.clear();
      tujuan.clear();
      selectedBank = null;
      inq = null;
      checked = false;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text('Tarik Saldo'), centerTitle: true, elevation: 0),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: loading
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(20),
                            child: Center(
                                child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                    size: 35)))
                        : ListView(
                            children: <Widget>[
                              Text('Bank Tujuan',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextFormField(
                                  controller: bank,
                                  readOnly: true,
                                  decoration: InputDecoration(isDense: true),
                                  onTap: () => getBank()),
                              SizedBox(height: 10),
                              Text('Nomor Rekening Tujuan',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextFormField(
                                  controller: tujuan,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(isDense: true)),
                              SizedBox(height: 10),
                              Text('Nominal',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextFormField(
                                  controller: nominal,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                      isDense: true, prefixText: 'Rp  ')),
                              SizedBox(height: 10),
                              selectedBank != null
                                  ? Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.1),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('Admin',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey)),
                                                  Text(
                                                      formatRupiah(
                                                          selectedBank.admin),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ])
                                          ]))
                                  : SizedBox(),
                              SizedBox(height: boxFavorite ? 10.0 : 0.0),
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
                                                color: Colors.black
                                                    .withOpacity(.1),
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
                                              Text('Simpan Nomor Favorit',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Icon(
                                                Icons.receipt,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )
                                            ],
                                          ),
                                          Divider(),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: tujuan,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                                labelText: 'Nomor Tujuan Bank',
                                                prefixIcon:
                                                    Icon(Icons.contacts)),
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
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              onPressed: () => simpanFavorite(),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : SizedBox(height: 0.0),
                              SizedBox(height: 10),
                              checked
                                  ? ListView(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: <Widget>[
                                          Text('Nomor Rekening',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(inq.noPelanggan,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Nama Pemilik',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(inq.nama,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Nominal',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(formatRupiah(inq.tagihan),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Admin',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(formatRupiah(inq.admin),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Cashback',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(formatRupiah(inq.fee),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Total Bayar',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11)),
                                          SizedBox(height: 5),
                                          Text(formatRupiah(inq.total),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ])
                                  : SizedBox(),
                            ],
                          )),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                      ),
                      child: Text(checked ? 'Kirim Uang' : 'Lanjut'),
                      onPressed: () {
                        if (checked)
                          return purchase();
                        else
                          return inquiry();
                      }),
                )
              ]),
        ));
  }
}
