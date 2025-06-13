// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// PACKAGE INSTALL
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
// BLOC
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
// MODEL
import 'package:mobile/models/favorite_number.dart';

class FavoriteNumber extends StatefulWidget {
  final String type;

  FavoriteNumber(this.type);

  @override
  createState() => FavoriteNumberState();
}

class FavoriteNumberState extends State<FavoriteNumber> {
  List<FavoriteNumberModel> favorites = [];
  List<FavoriteNumberModel> filtered = [];
  bool isLoading = true;

  @override
  initState() {
    super.initState();

    getList();
  }

  Future<void> getList() async {
    try {
      http.Response response = await http
          .get(Uri.parse('$apiUrl/favorite/get?type=${widget.type}'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        favorites.clear();
        filtered.clear();

        datas.forEach((data) {
          favorites.add(FavoriteNumberModel.fromJson(data));
          filtered.add(FavoriteNumberModel.fromJson(data));
        });
      } else {
        String message = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (err) {
      String message =
          'Terjadi kesalahan saat mengambil data dari server, ${err.toString()}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Favorite Number'),
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.search),
                    hintText: 'Cari Favorite Number'),
                onChanged: (value) {
                  filtered = favorites
                      .where((el) =>
                          el.tujuan.contains(value) ||
                          el.nama.toLowerCase().contains(value.toLowerCase()))
                      .toList();

                  setState(() {});
                }),
            SizedBox(height: 20.0),
            Flexible(
              flex: 1,
              child: isLoading
                  ? buildLoading()
                  : favorites.length == 0
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'TIDAK ADA DATA',
                              style: TextStyle(
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemBuilder: (_, i) {
                            FavoriteNumberModel favorite = filtered[i];

                            return ListTile(
                                dense: true,
                                onTap: () {
                                  Navigator.of(context).pop(favorite);
                                },
                                contentPadding: EdgeInsets.all(0),
                                title: Text(
                                  favorite.tujuan,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  favorite.nama,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400),
                                ));
                          }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(15),
      child: Center(
        child: SpinKitThreeBounce(
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            size: 35),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
