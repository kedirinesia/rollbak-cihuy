// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/config.dart';
import 'package:mobile/screen/payment_tutorial.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/topup_va.dart';
import 'package:mobile/modules.dart';

class DepositMerchant extends StatefulWidget {
  final VaTopup va;
  DepositMerchant(this.va);

  @override
  _DepositMerchantState createState() => _DepositMerchantState();
}

class _DepositMerchantState extends State<DepositMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detail Top Up'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
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
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(children: <Widget>[
              Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          Theme.of(context).canvasColor
                        ],
                        begin: AlignmentDirectional.topCenter,
                        end: AlignmentDirectional.bottomCenter),
                  ),
                  child: Center(
                      child: Text(formatRupiah(widget.va.total),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40)))),
              Flexible(
                  flex: 1,
                  child:
                      ListView(padding: EdgeInsets.all(15), children: <Widget>[
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
                                  Text("Informasi Top Up",
                                      style: TextStyle(
                                          color: packageName ==
                                                  'com.lariz.mobile'
                                              ? Theme.of(context)
                                                  .secondaryHeaderColor
                                              : Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold)),
                                  Icon(
                                    Icons.info,
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                  )
                                ]),
                            SizedBox(height: 15),
                            Text("Kode Pembayaran",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(widget.va.kode,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  InkWell(
                                    child: Icon(Icons.content_copy,
                                        color: Colors.grey),
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: widget.va.kode));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Kode pembayaran berhasil di salin ke papan klip'),
                                      ));
                                    },
                                  )
                                ]),
                            SizedBox(height: 10),
                            Text("Nama Pengguna",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(widget.va.nama,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Nominal TopUp",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(formatRupiah(widget.va.nominal),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Biaya Admin",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(formatRupiah(widget.va.fee),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Total Bayar",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(formatRupiah(widget.va.total),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            widget.va.keterangan != ''
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Keterangan",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                      SizedBox(height: 5),
                                      Text(widget.va.keterangan,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 10),
                                    ],
                                  )
                                : SizedBox(),
                            Text("Waktu Kadaluarsa",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(widget.va.expiredDate,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 20.0),
                            PaymentTutorialPage(),
                            SizedBox(height: 10),
                          ]),
                    )
                  ]))
            ])));
  }
}
