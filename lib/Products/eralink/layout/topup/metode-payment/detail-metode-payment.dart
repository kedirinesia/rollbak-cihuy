// @dart=2.9

import 'package:flutter/material.dart';

// PACKAGE

// MODEL
import 'package:mobile/models/metode_payment.dart';

import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';

class DetailMetodePayment extends StatefulWidget {
  MetodePaymentModel payment;
  DetailMetodePayment(this.payment);

  @override
  createState() => DetailMetodePaymentState();
}

class DetailMetodePaymentState extends State<DetailMetodePayment> {
  
  @override
  initState() {
    super.initState();
    void initState() {
      analitycs.pageView('/detail/payment/', {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Detail Methode Payment',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
          title: Text('Detail Pembayaran'), centerTitle: true, elevation: 0),
      body: ListView(
        children: [
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
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.payment.paymentCode,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
