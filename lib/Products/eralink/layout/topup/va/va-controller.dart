// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/virtual_account.dart';
import 'package:mobile/Products/eralink/layout/topup/va/va-deposit.dart';
import 'package:mobile/Products/eralink/layout/topup/va/va.dart';
import 'package:http/http.dart' as http;

abstract class VAController extends State<TopupVA> {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<VirtualAccount>> getVa() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/deposit/virtual-account/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return datas.map((el) => VirtualAccount.fromJson(el)).toList();
    } else {
      return [];
    }
  }

  void topup(VirtualAccount va) async {
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
    try {
      http.Response response =
          await http.post(Uri.parse('$apiUrl/deposit/payment-va'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json'
              },
              body: json.encode({'nominal': parsedNominal, 'vacode': va.code}));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body)['data'];
        VirtualAccountResponse va = VirtualAccountResponse.fromJson(data);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DepositVa(va)));
      } else {
        String message = json.decode(response.body)['message'];
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text("TopUp Gagal"),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            'TUTUP',
                            style: TextStyle(
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop())
                    ]));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text("TopUp Gagal"),
                  content: Text(err.toString()),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop())
                  ]));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
