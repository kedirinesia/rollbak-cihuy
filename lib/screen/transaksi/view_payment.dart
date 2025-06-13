// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/models/trx.dart';
import 'package:mobile/models/bank.dart';
import 'package:mobile/provider/analitycs.dart';

class ViewPaymentTrx extends StatefulWidget {
  final TrxModel trx;
  final int opsiBayar;

  ViewPaymentTrx(this.trx, this.opsiBayar);

  @override
  createState() => ViewPaymentTrxState();
}

class ViewPaymentTrxState extends State<ViewPaymentTrx> {
  List<BankModel> banks = [];
  bool loaded = true;

  @override
  initState() {
    super.initState();
    analitycs.pageView('/payment/view',
        {'userId': bloc.userId.valueWrapper?.value, 'title': 'Payment View'});
  }

  Future<void> getBank() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/bank/list?type=1'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});
    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      var banks = datas.map((e) => BankModel.fromJson(e)).toList();
    }
    setState(() {
      loaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
