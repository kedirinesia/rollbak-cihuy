// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/Products/pgkreload/layout/components/list-sub-menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;

abstract class ListSubMenuController extends State<ListSubMenu>
    with TickerProviderStateMixin {
  bool loading = true;
  MenuModel currentMenu;
  List<MenuModel> listMenu = [];
  List<MenuModel> tempMenu = [];
  TextEditingController query = TextEditingController();

  bool isProductIconMenu = false;

  @override
  void initState() {
    super.initState();
    currentMenu = widget.menuModel;
    analitycs.pageView('/menu/' + currentMenu.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Buka Menu ' + currentMenu.name
    });
    getData();
  }

  getData() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/menu/${currentMenu.id}/child'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<MenuModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => MenuModel.fromJson(m))
          .toList();
      tempMenu = lm;
      listMenu = lm;
    } else {
      listMenu = [];
    }

    setState(() {
      loading = false;
    });
  }

  onTapMenu(MenuModel menu) async {
    if (menu.category_id.isNotEmpty && menu.type == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DetailDenom(menu)));
    } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DetailDenomPostpaid(menu)));
    } else if (menu.category_id.isEmpty) {
      if (menu.type == 3) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DynamicPrepaidDenom(menu)));
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
      }
    }
  }
}
