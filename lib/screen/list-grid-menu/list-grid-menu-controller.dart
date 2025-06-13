// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// INSTALL PACKAGE
import 'package:http/http.dart' as http;
import 'package:mobile/provider/analitycs.dart';

// BLOC
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;

// MODEL
import 'package:mobile/models/menu.dart';

import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/screen/detail-denom/detail-denom-grid.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';

abstract class ListGridMenuController extends State<ListGridMenu>
    with TickerProviderStateMixin {
  bool loading = true;
  MenuModel currentMenu;
  List<MenuModel> listMenu = [];
  List<MenuModel> tempMenu = [];
  TextEditingController query = TextEditingController();

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
          .push(MaterialPageRoute(builder: (_) => DetailDenomGrid(menu)));
    } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DetailDenomPostpaid(menu)));
    } else if (menu.category_id.isEmpty) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ListGridMenu(menu)));
    }
  }
}
