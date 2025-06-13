// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/dynamic-prepaid.dart';
import 'package:http/http.dart' as http;
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;
import './dynamic-denom.dart';

abstract class DynamicDenomController extends State<DynamicPrepaidDenom>
    with TickerProviderStateMixin {
  List<DynamicPrepaidLayoutModel> layoutDenom = [];
  List<DynamicPrepaidDenom> listDenom = [];
  bool loading = false;
  bool failed = false;
  DynamicPrepaidDenomModel selectedDenom;
  TextEditingController tujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();
  TabController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new TabController(length: layoutDenom.length, vsync: this);
  }

  getData() async {
    http.Response response = await http.get(
        Uri.parse(
            '$apiUrl/product/dynamic/prepaid?product=${widget.menu.kodeProduk}&tujuan=${tujuan.text}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<DynamicPrepaidLayoutModel> lm =
          (jsonDecode(response.body)['data'] as List)
              .map((m) => DynamicPrepaidLayoutModel.fromJson(m))
              .toList();

      setState(() {
        layoutDenom = lm;
        loading = false;
      });

      controller = new TabController(length: layoutDenom.length, vsync: this);
    } else {
      setState(() {
        loading = false;
        layoutDenom = [];
      });
    }
  }

  selectDenom(denom) {
    if (denom != null) {
      setState(() {
        selectedDenom = denom;
      });
    }
  }
}
