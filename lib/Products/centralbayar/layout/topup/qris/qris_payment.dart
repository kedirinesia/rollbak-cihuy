// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/qris_topup.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/payment_tutorial.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrisPayment extends StatefulWidget {
  final QrisTopupModel data;
  QrisPayment(this.data);

  @override
  _QrisPaymentState createState() => _QrisPaymentState();
}

class _QrisPaymentState extends State<QrisPayment> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/payment/qris/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Pembayarab QRIS',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QRIS'),
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
          child: ListView(padding: EdgeInsets.all(20), children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * .05),
            Align(
              alignment: Alignment.center,
              child: QrImageView(
                backgroundColor: Theme.of(context).canvasColor,
                foregroundColor: Colors.black,
                gapless: true,
                size: MediaQuery.of(context).size.width * .75,
                version: QrVersions.auto,
                data: widget.data.code,
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(formatRupiah(widget.data.total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  )),
            ),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        offset: Offset(5, 10.0),
                        blurRadius: 20)
                  ]),
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Informasi Deposit',
                          style: TextStyle(
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold)),
                      Icon(
                        Icons.info,
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      )
                    ]),
                Divider(),
                SizedBox(height: 15),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Nama',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(widget.data.displayName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Kadaluarsa',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(
                          formatDate(
                              widget.data.expired, 'd MMMM yyyy HH:mm:ss'),
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Nominal',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(formatRupiah(widget.data.nominal),
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Admin',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(formatRupiah(widget.data.admin),
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Total',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(formatRupiah(widget.data.total),
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                SizedBox(
                  height: 20.0,
                ),
                PaymentTutorialPage(),
              ]),
            )
          ])),
    );
  }
}
