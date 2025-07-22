// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/mykonterr/layout/transaksi/postpaid.dart';
import 'package:mobile/Products/mykonterr/layout/transaksi/prepaid.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListSubMenu extends StatefulWidget {
  final MenuModel menuModel;

  ListSubMenu(this.menuModel);

  @override
  _ListSubMenuState createState() => _ListSubMenuState();
}

class _ListSubMenuState extends State<ListSubMenu> {
  bool loading = true;
  MenuModel currentMenu;
  List<MenuModel> listMenu = [];
  List<MenuModel> tempMenu = [];
  TextEditingController query = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentMenu = widget.menuModel;
    getData();
  }

  getData() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse(apiUrl + '/menu/' + currentMenu.id + '/child'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<MenuModel> lm = (json.decode(response.body)['data'] as List)
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
          .push(MaterialPageRoute(builder: (_) => PrepaidPage(menu)));
    } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => PostpaidPage(menu)));
    } else if (menu.category_id.isEmpty) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(currentMenu.name), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .2,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).canvasColor
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          currentMenu.type == 2
              ? Container(
                  padding: EdgeInsets.all(20),
                  child: TextFormField(
                    controller: query,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Cari disini...',
                        isDense: true,
                        suffixIcon: InkWell(
                            child: Icon(Icons.search),
                            onTap: () {
                              List<MenuModel> list = tempMenu
                                  .where((menu) => menu.name
                                      .toLowerCase()
                                      .contains(query.text))
                                  .toList();
                              setState(() {
                                listMenu = list;
                              });
                            })),
                    onEditingComplete: () {
                      List<MenuModel> list = tempMenu
                          .where((menu) =>
                              menu.name.toLowerCase().contains(query.text))
                          .toList();
                      setState(() {
                        listMenu = list;
                      });
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          listMenu = tempMenu;
                        });
                      }
                    },
                  ))
              : Container(),
          Flexible(
            flex: 1,
            child: loading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                        child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor, size: 35)))
                : ListView.separated(
                    padding: EdgeInsets.all(20),
                    itemCount: listMenu.length,
                    separatorBuilder: (_, i) => SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      MenuModel menu = listMenu[i];
                      return InkWell(
                        onTap: () => onTapMenu(menu),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    offset: Offset(5, 10.0),
                                    blurRadius: 20)
                              ]),
                          child: ListTile(
                            leading: CircleAvatar(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.1),
                              child: currentMenu.icon != ''
                                  ? Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      child: CachedNetworkImage(
                                          imageUrl: currentMenu.icon))
                                  : Icon(Icons.list),
                            ),
                            title: Text(menu.name,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                            subtitle: Text(menu.description ?? ' ',
                                style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
