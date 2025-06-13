// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/transfer.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:mobile/Products/centralbayar/layout/transfer_saldo/detail_transfer.dart';

class InquiryTransfer extends StatefulWidget {
  final String tujuan;
  final int nominal;

  InquiryTransfer(this.tujuan, this.nominal);

  @override
  _InquiryTransferState createState() => _InquiryTransferState();
}

class _InquiryTransferState extends InquiryTransferController {
  @override
  void initState() {
    getData(widget.tujuan, widget.nominal);
    super.initState();
    analitycs.pageView('/inquiry/transfer/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Inquiry Transfer',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Transfer Saldo'), centerTitle: true, elevation: 0),
      body: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).canvasColor
                ],
                begin: AlignmentDirectional.topCenter,
                end: AlignmentDirectional.bottomCenter),
          ),
        ),
        loading
            ? loadingWidget()
            : Flexible(
                flex: 1,
                child: ListView(padding: EdgeInsets.all(15), children: <Widget>[
                  SizedBox(height: 20.0),
                  Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Informasi Transfer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor)),
                              Icon(
                                Icons.info,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Nomor Tujuan',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              Text(phone,
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Nama Pengguna',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              Text(nama,
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Nama Toko',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              Text(namaToko,
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Nominal',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              Text(formatRupiah(nom),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ]),
                  ),
                ]))
      ]),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.navigate_next),
              label: Text('Transfer'),
              onPressed: () => transfer(),
            ),
    );
  }
}

abstract class InquiryTransferController extends State<InquiryTransfer>
    with TickerProviderStateMixin {
  bool loading = true;
  String namaToko = '';
  String trxId = '';
  String userId = '';
  String phone = '';
  String nama = '';
  int nom = 0;

  void getData(String tujuan, int nominal) async {
    http.Response response =
        await http.post(Uri.parse('$apiUrl/transfer/inquiry'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode({'phone': tujuan, 'nominal': nominal}));

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> data = json.decode(response.body)['data'];
      userId = data['tujuan']['_id'];
      phone = data['tujuan']['phone'];
      nama = data['tujuan']['nama'];
      namaToko = data['tujuan']['toko']['nama'];
      nom = data['nominal'];
      trxId = data['trxId'];
      setState(() {
        loading = false;
      });
    } else {
      String message = json.decode(response.body)['message'];
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Transfer Gagal'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
      Navigator.of(context).pop();
    }
  }

  void transfer() async {
    String pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => VerifikasiPin()));

    if (pin != null) {
      setState(() {
        loading = true;
      });
      sendDeviceToken();
      http.Response response = await http.post(
          Uri.parse('$apiUrl/transfer/send'),
          headers: {
            'Authorization': bloc.token.valueWrapper?.value,
            'Content-Type': 'application/json'
          },
          body:
              json.encode({'user_id': userId, 'nominal': nom, 'trxId': trxId}));

      if (response.statusCode == 200) {
        TransferModel trf =
            TransferModel.fromJson(json.decode(response.body)['data']);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => DetailTransfer(nama, namaToko, phone, nom, trf)));
      } else {
        String message = json.decode(response.body)['message'];
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text('Transfer Gagal'),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            'TUTUP',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop())
                    ]));
      }
      setState(() {
        loading = false;
      });
    }
  }

  Widget loadingWidget() {
    return Flexible(
        flex: 1,
        child: Center(
            child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor, size: 35)));
  }
}
