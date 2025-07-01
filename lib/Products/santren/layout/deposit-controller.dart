// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/Products/santren/layout/deposit.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'dart:convert';
import 'package:mobile/models/deposit.dart';
import 'package:mobile/provider/analitycs.dart';
 
import 'package:http/http.dart' as http;
import '../../../bloc/Bloc.dart' show bloc;
import '../../../bloc/Api.dart' show apiUrl;

abstract class DepositController extends State<DepositPage> {
  bool loadingNewPage = false;
  bool loading = true;
  bool isEdge = false;
  int limit = 20;
  int currentPage = 0;
  List<DepositModel> listDeposit = [];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/history/deposit', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Deposit'
    });

    if (configAppBloc.autoReload.valueWrapper?.value) {
      Timer.periodic(new Duration(seconds: 1), (timer) => getData());
    } else {
      getData();
    }
  }

  getData() async {
    if (isEdge) return;
    http.Response response = await http.get(
        Uri.parse('$apiUrl/deposit/list?page=$currentPage&limit=$limit'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body)['data'] as List;
      if (list.length == 0) isEdge = true;
      list.forEach((item) => listDeposit.add(DepositModel.fromJson(item)));
      currentPage++;
    }

    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
