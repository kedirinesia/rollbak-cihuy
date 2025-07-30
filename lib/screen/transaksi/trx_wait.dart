// @dart=2.9

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/paymobileku/layout/history.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';

class TransactionWaitPage extends StatefulWidget {
  @override
  _TransactionWaitPageState createState() => _TransactionWaitPageState();
}

class _TransactionWaitPageState extends State<TransactionWaitPage> {
  int _count = 1;
  Timer timer;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/trx/wait/', {
      'userId': bloc.userId.valueWrapper.value,
      'title': 'Transaksi Menunggu',
    });
    timer = new Timer.periodic(Duration(seconds: 1), (timer) => checkStatus());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void checkStatus() {
    getLatestTrx().then((trx) {
      if (trx != null) {
        if (trx.status == 2) {
          timer.cancel();
          return Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => packageName == 'id.paymobileku.app'
                    ? HistoryPage(initIndex: 1)
                    : DetailTransaksi(trx)),
          );
        } else {
          if (_count >= 6) {
            timer.cancel();
            return Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => packageName == 'id.paymobileku.app'
                      ? HistoryPage(initIndex: 1)
                      : DetailTransaksi(trx)),
            );
          }
        }
      }

      setState(() {
        _count++;
      });
    }).catchError((_) {
      // timer.cancel();
      setState(() {
        _count++;
      });
    });
  }

  Future<TrxModel> getLatestTrx() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/trx/list?page=0&limit=1'),
      headers: {
        'Authorization': bloc.token.valueWrapper.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return TrxModel.fromJson(datas[0]);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            packageName == 'id.paymobileku.app'
                ? Image.asset(
                    'assets/img/waiting.gif',
                    // width: 350.0,
                    // height: 300.0,
                  )
                : Image.asset(
                    'assets/img/wait.gif',
                    width: 250.0,
                    height: 250.0,
                  ),
            SizedBox(height: 10),
            Text(
              'Tunggu sebentar, ya..',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Transaksi sedang diproses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            // SizedBox(height: 25),
            // SpinKitThreeBounce(
            //   color: packageName == 'com.lariz.mobile'
            //       ? Theme.of(context).secondaryHeaderColor
            //       : Theme.of(context).primaryColor,
            //   size: 35,
            // ),
          ],
        ),
      ),
    );
  }
}
