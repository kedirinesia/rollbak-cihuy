// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/pulsa.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:http/http.dart' as http;
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;

abstract class PulsaController extends State<Pulsa>
    with TickerProviderStateMixin {
  List<PulsaModel> listDenom = [];
  bool loading = false;
  bool failed = false;
  String prefixNomor = "";
  PulsaModel selectedDenom;
  TextEditingController nomorHp = TextEditingController();

  void getDenom(String nomor) async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/pulsa?q=$nomor'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PulsaModel> list = (json.decode(response.body)['data'] as List)
          .map((item) => PulsaModel.fromJson(item))
          .toList();
      listDenom = list;
    }

    setState(() {
      loading = false;
    });
  }

  void selectDenom(PulsaModel denom) {
    if (denom.note == 'gangguan') {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Produk sedang mengalami gangguan',
          isError: true,
        ),
      );
      return;
    }
    if (denom != null) {
      setState(() {
        selectedDenom = denom;
      });
    }
  }
}
