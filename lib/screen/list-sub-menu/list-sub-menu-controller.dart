// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/transaksi/bulk.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;

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

  List<String> pkgName = [
    'com.mkrdigital.mobile',
    'id.outletpay.mobile',
    'id.payku.app',
    'com.eralink.mobileapk',
    'mobile.payuni.id',
    'com.esaldoku.mobileserpul',
    'com.talentapay.android',
    'mypay.co.id',
    'id.ptspay.mobileapp',
    'com.hexamobile.androidapp',
    'id.agenpayment.app',
    // 'com.lapaupayment.mobile',
    'id.lokapulsa.mobile',
    'com.akupay.androidmobileapps',
    // 'id.payu.co',
    'id.mykonter.app',
    'com.santrenpay.mobile'
  ];

  onTapMenu(MenuModel menu) async {
    if (menu.category_id.isNotEmpty && menu.type == 1) {
      if (menu.jenis == 5 || menu.jenis == 6) {
        if (configAppBloc.packagename.valueWrapper?.value ==
            'id.paymobileku.app') {
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BulkPage(menu),
            ),
          );
        } else if (pkgName.contains(packageName)) {
          return Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => VoucherBulkPage(menu)));
        } else {
          return;
        }
      } else {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenom(menu),
          ),
        );
      }
    } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailDenomPostpaid(menu),
        ),
      );
    } else if (menu.category_id.isEmpty) {
      if (menu.type == 3) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DynamicPrepaidDenom(menu),
          ),
        );
      } else {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListSubMenu(menu),
          ),
        );
      }
    }
  }
}
