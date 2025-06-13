// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/mykonter/layout/menu/postpaid_detail.dart';
import 'package:mobile/Products/mykonter/layout/menu/prepaid.dart';
import 'package:mobile/Products/mykonter/layout/menu/pulsa_menu.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class SubmenuPrepaid extends StatefulWidget {
  final MenuModel menu;
  SubmenuPrepaid(this.menu);

  @override
  _SubmenuPrepaidState createState() => _SubmenuPrepaidState();
}

class _SubmenuPrepaidState extends State<SubmenuPrepaid> {
  Future<List<MenuModel>> getSubmenu() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/menu/${widget.menu.id}/child'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return datas.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      showToast(context, 'Terjadi kesalahan saat mengambil data dari server');
      return [];
    }
  }

  void onTapMenu(MenuModel menu) {
    if (menu.jenis == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PulsaMenu(),
        ),
      );
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PrepaidPage(menu),
          ),
        );
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostpaidDetailPage(menu),
          ),
        );
      } else if (menu.category_id.isEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubmenuPrepaid(menu),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu.name,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<MenuModel>>(
        future: getSubmenu(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 35,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Terjadi Kesalahan'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          if (snapshot.data.length == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Tidak ada data'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: snapshot.data.length,
            separatorBuilder: (_, __) => SizedBox(height: 5),
            itemBuilder: (_, i) {
              MenuModel menu = snapshot.data.elementAt(i);

              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(3, 3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    menu.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: Icon(Icons.navigate_next_rounded),
                  onTap: () => onTapMenu(menu),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
