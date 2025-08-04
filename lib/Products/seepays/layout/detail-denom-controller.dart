// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/seepays/layout/detail-denom.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:package_info_plus/package_info_plus.dart';

abstract class SeepaysDetailDenomController extends State<SeepaysDetailDenom>
    with TickerProviderStateMixin {
  List<PrepaidDenomModel> listDenom = [];
  String coverIcon = '';
  bool loading = true;
  bool failed = false;
  PrepaidDenomModel selectedDenom;
  TextEditingController tujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();
  String packageName = '';

  @override
  void initState() {
    super.initState();
    _getPackageName();
    analitycs.pageView('/menu/transaksi/' + widget.menu.category_id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Buka Menu ' + widget.menu.name
    });
    getData();
  }

  Future<void> _getPackageName() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageName = info.packageName;
    });
  }

  getData() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PrepaidDenomModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => PrepaidDenomModel.fromJson(m))
          .toList();

      // SET CATEGORY COVER ICON
      coverIcon = json.decode(response.body)['url_image'] ?? '';

      setState(() {
        listDenom = lm;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        listDenom = [];
      });
    }
  }

  onTapDenom(denom) {
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