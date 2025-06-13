// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// PACKAGE
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// MODEL
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/models/virtual_account.dart';
import 'package:mobile/models/metode_payment.dart';
import 'package:mobile/provider/analitycs.dart';

import 'package:mobile/Products/eralink/layout/topup/metode-payment/detail-metode-payment.dart';

import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

class MethodPayment extends StatefulWidget {
  final PaymentModel payment;
  MethodPayment(this.payment);
  @override
  createState() => MethodPaymentState();
}

class MethodPaymentState extends State<MethodPayment> {
  bool loaded = true;
    List<VirtualAccount> VAList = [];

  @override
  initState() {
    super.initState();
    void initState() {
      analitycs.pageView('/method/payment/', {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Methode Pembayaran',
      });
    }

    getVA();
  }

  void getVA() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/deposit/virtual-account/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      datas.map((el) => VAList.add(VirtualAccount.fromJson(el))).toList();
    }

    setState(() {
      loaded = false;
    });
  }

  void topup(VirtualAccount va) async {
    setState(() {
      loaded = true;
    });

    try {
      var dataToSend = {
        'vacode': va.code,
      };

      http.Response response =
          await http.post(Uri.parse('$apiUrl/deposit/create-payment'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json'
              },
              body: json.encode(dataToSend));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        var payment = MetodePaymentModel.fromJson(data);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailMetodePayment(payment),
          ),
        );
      } else {
        String message = json.decode(response.body)['message'];
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text("Create Payment Gagal"),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            'TUTUP',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop())
                    ]));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text("Create Payment Gagal"),
                  content: Text(err.toString()),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop())
                  ]));
    } finally {
      setState(() {
        loaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
          title: Text(widget.payment.title), centerTitle: true, elevation: 0),
      body: loaded
          ? loading()
          : Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SvgPicture.asset('assets/img/va.svg',
                      width: MediaQuery.of(context).size.width * .3),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Divider(),
                  SizedBox(height: 15),
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: VAList.length,
                        separatorBuilder: (_, i) => SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          VirtualAccount va = VAList[i];

                          return Container(
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.2),
                                  offset: Offset(5, 10),
                                  blurRadius: 10.0)
                            ]),
                            child: ListTile(
                                onTap: () => topup(va),
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.15),
                                  child: Text(
                                    (i + 1).toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  va.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                subtitle: Text(
                                  va.description,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                )),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }

  Widget loading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: SpinKitThreeBounce(
              color: Theme.of(context).primaryColor, size: 35)),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
