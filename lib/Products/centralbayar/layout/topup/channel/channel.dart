// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/deposit_link.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class TopupChannel extends StatefulWidget {
  final PaymentModel payment;
  TopupChannel(this.payment);

  @override
  _TopupChannelState createState() => _TopupChannelState();
}

class _TopupChannelState extends State<TopupChannel> {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  void topup() async {
    double parsedNominal = double.parse(nominal.text.replaceAll('.', ''));
    if (nominal.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nominal belum diisi')));
      return;
    } else if (parsedNominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Minimal deposit adalah Rp 10.000')));
      return;
    }

    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
        Uri.parse('$apiUrl/deposit/payment-link'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode(
            {'nominal': parsedNominal, 'type': widget.payment.channel}));

    if (response.statusCode == 200) {
      DepositLink link = DepositLink.fromJson(json.decode(response.body));
      Navigator.of(context).pop();

      try {
        await launch(link.url,
            customTabsOption: CustomTabsOption(
                toolbarColor: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
                enableDefaultShare: false,
                enableUrlBarHiding: true,
                showPageTitle: true,
                animation: CustomTabsSystemAnimation.slideIn()));
      } catch (e) {
        debugPrint(e.toString());
      }

      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (_) => Webview(widget.payment.title, link.url)));
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi masalah pada server';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: SpinKitThreeBounce(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      size: 35)))
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView(padding: EdgeInsets.all(20), children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .10),
                SvgPicture.asset('assets/img/payment_channel.svg',
                    width: MediaQuery.of(context).size.width * .5),
                SizedBox(height: MediaQuery.of(context).size.height * .05),
                TextFormField(
                  controller: nominal,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor)
                      ),
                      labelText: 'Nominal',
                      labelStyle: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor
                      ),
                      isDense: true),
                  onChanged: (value) {
                    int amount = int.tryParse(
                            nominal.text.replaceAll(RegExp('[^0-9]'), '')) ??
                        0;
                    nominal.text = formatRupiah(amount);
                    nominal.selection = TextSelection.fromPosition(
                        TextPosition(offset: nominal.text.length));
                  },
                )
              ])),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              icon: Icon(Icons.navigate_next),
              label: Text('Lanjut'),
              onPressed: () => topup()),
    );
  }
}
