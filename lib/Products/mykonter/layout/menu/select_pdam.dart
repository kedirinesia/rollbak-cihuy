// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';

class SelectPdamArea extends StatefulWidget {
  final MenuModel menu;
  SelectPdamArea(this.menu);

  @override
  _SelectPdamAreaState createState() => _SelectPdamAreaState();
}

class _SelectPdamAreaState extends State<SelectPdamArea> {
  TextEditingController _search = TextEditingController();
  bool _loading = true;
  List<MenuModel> menus = [];
  List<MenuModel> temp = [];

  @override
  void initState() {
    super.initState();
    getSubmenu();
  }

  Future<void> getSubmenu() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/menu/${widget.menu.id}/child'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      menus = datas.map((e) => MenuModel.fromJson(e)).toList();
      temp = menus;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Area',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 35,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: TextField(
                    controller: _search,
                    keyboardType: TextInputType.text,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Pencarian...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      suffixIcon: _search.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded),
                              onPressed: () {
                                setState(() {
                                  temp = menus;
                                  _search.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        temp = menus
                            .where((e) => e.name
                                .toLowerCase()
                                .contains(value.trim().toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: temp.length,
                    itemBuilder: (_, i) {
                      MenuModel menu = temp.elementAt(i);

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          menu.name,
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.navigate_next),
                        onTap: () => Navigator.of(context).pop(menu),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
