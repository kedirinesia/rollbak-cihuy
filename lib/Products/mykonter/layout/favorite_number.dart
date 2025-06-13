// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/favorite_number.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class FavoriteNumberPage extends StatefulWidget {
  final String type;
  FavoriteNumberPage({this.type = 'prepaid'});

  @override
  _FavoriteNumberPageState createState() => _FavoriteNumberPageState();
}

class _FavoriteNumberPageState extends State<FavoriteNumberPage> {
  bool _loading = true;
  List<FavoriteNumberModel> _base = [];
  List<FavoriteNumberModel> _temp = [];
  TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    getNumbers();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> getNumbers() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/favorite/get?type=${widget.type}'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      _base = datas.map((e) => FavoriteNumberModel.fromJson(e)).toList();
      _temp = _base;
    } else {
      showToast(context, 'Gagal saat mengambil nomor tersimpan dari server');
      Navigator.of(context).pop();
    }

    setState(() {
      _loading = false;
    });
  }

  void search(String text) {
    setState(() {
      _temp = _base.where((el) {
        bool searchName =
            el.nama.trim().toLowerCase().contains(text.trim().toLowerCase());
        bool searchNumber = el.tujuan.trim().contains(text.trim());

        return (searchName || searchNumber);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nomor Tersimpan',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before_rounded),
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
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _search,
                    keyboardType: TextInputType.name,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cari nama atau nomor',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(Icons.clear_rounded),
                              onPressed: () {
                                setState(() {
                                  _search.clear();
                                  _temp = _base;
                                });
                              },
                            ),
                    ),
                    onChanged: search,
                    onSubmitted: search,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(15),
                    itemCount: _temp.length,
                    separatorBuilder: (_, __) => SizedBox(height: 5),
                    itemBuilder: (_, i) {
                      FavoriteNumberModel fav = _temp.elementAt(i);

                      return ListTile(
                        dense: true,
                        onTap: () => Navigator.of(context).pop(fav),
                        title: Text(
                          fav.nama,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          fav.tujuan,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade800),
                        ),
                        trailing: Icon(Icons.navigate_next_rounded),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
