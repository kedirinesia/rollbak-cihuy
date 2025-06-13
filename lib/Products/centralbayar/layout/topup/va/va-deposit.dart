// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/virtual_account.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/payment_tutorial.dart';

class DepositVa extends StatefulWidget {
  final VirtualAccountResponse va;
  DepositVa(this.va);

  @override
  _DepositVaState createState() => _DepositVaState();
}

class _DepositVaState extends State<DepositVa> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/deposit/va/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Deposit Virtual Account',
    });
  }

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
                      child: Text(formatRupiah(widget.va.totalAmount),
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
                                  Text(widget.va.va,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  InkWell(
                                    child: Icon(Icons.content_copy,
                                        color: Colors.grey),
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: widget.va.va));
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
                            Text(widget.va.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Nominal TopUp",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(formatRupiah(widget.va.amount),
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
                            Text(formatRupiah(widget.va.totalAmount),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            widget.va.description != ''
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Keterangan",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                      SizedBox(height: 5),
                                      Text(widget.va.description,
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
                            Text(widget.va.expiredAt,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            PaymentTutorialPage(),
                            SizedBox(height: 10),
                          ]),
                    )
                  ]))
            ])));
  }
}
