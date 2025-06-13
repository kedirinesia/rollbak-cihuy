// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/topup_va.dart';
import 'package:mobile/Products/ampedia/layout/topup/merchant/deposit_merchant.dart';

class TopupMerchant extends StatefulWidget {
  final PaymentModel payment;
  TopupMerchant(this.payment);

  @override
  _TopupMerchantState createState() => _TopupMerchantState();
}

class _TopupMerchantState extends State<TopupMerchant> {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  void topup() async {
    if (nominal.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nominal masih kosong')));
      return;
    } else if (int.parse(nominal.text) < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Minimal topup adalah Rp 10.000')));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      http.Response response =
          await http.post(Uri.parse('$apiUrl/deposit/payment-channel'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json'
              },
              body: json.encode({
                'nominal': int.parse(nominal.text),
                'type': 6,
                'vaname': widget.payment.type == 4 ? 5 : 6
              }));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body)['data'];
        VaTopup vaTopup = VaTopup.fromJson(data);
        Navigator.of(context).pop();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DepositMerchant(vaTopup)));
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan pada server')));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.payment.title), centerTitle: true, elevation: 0),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: loading
                ? Center(
                    child: SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor, size: 35))
                : ListView(padding: EdgeInsets.all(20), children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .10),
                    CachedNetworkImage(
                        imageUrl: widget.payment.icon,
                        width: MediaQuery.of(context).size.width * .5),
                    SizedBox(height: MediaQuery.of(context).size.height * .05),
                    TextFormField(
                        controller: nominal,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nominal',
                            prefixText: 'Rp ',
                            isDense: true))
                  ])),
        floatingActionButton: loading
            ? null
            : FloatingActionButton.extended(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(Icons.navigate_next),
                label: Text('Lanjut'),
                onPressed: () => topup()));
  }
}
