// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/deposit_link.dart';
import 'package:mobile/models/ewallet-account.dart';
import 'package:mobile/screen/topup/ewallet/ewallet.dart';
import 'package:http/http.dart' as http;

abstract class EwalletController extends State<TopupEwallet> {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<EwalletAccount>> getEwallet() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/deposit/ewallet/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return datas.map((el) => EwalletAccount.fromJson(el)).toList();
    } else {
      return [];
    }
  }

  void topup(String ewalletCode) async {
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
        Uri.parse('$apiUrl/deposit/ewallet'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json
            .encode({'nominal': parsedNominal, 'ewallet_code': ewalletCode}));

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
}
