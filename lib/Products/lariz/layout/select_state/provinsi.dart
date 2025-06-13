// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:http/http.dart' as http;

class SelectProvinsiPage extends StatefulWidget {
  @override
  _SelectProvinsiPageState createState() => _SelectProvinsiPageState();
}

class _SelectProvinsiPageState extends State<SelectProvinsiPage> {
  List<Lokasi> provinces = [];
  List<Lokasi> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    getList();
    super.initState();
  }

  Future<void> getList() async {
    setState(() {
      isLoading = true;
    });

    http.Response response = await http.get(Uri.parse('$apiUrl/propinsi/list'));

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      provinces.clear();
      filtered.clear();
      datas.forEach((el) => provinces.add(Lokasi.fromJson(el)));
      filtered.addAll(provinces);
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Provinsi'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          isDense: true,
                          icon: Icon(Icons.search),
                          hintText: 'Cari Provinsi',
                          hintStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor)),
                      onChanged: (value) {
                        filtered = provinces
                            .where((el) => el.nama
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();

                        setState(() {});
                      }),
                  SizedBox(height: 20),
                  Flexible(
                      flex: 1,
                      child: isLoading
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Center(
                                  child: SpinKitThreeBounce(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      size: 35)))
                          : provinces.length == 0
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                      child: Text('TIDAK ADA DATA',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor))))
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) {
                                    Lokasi provinsi = filtered[i];

                                    return ListTile(
                                        dense: true,
                                        onTap: () =>
                                            Navigator.of(context).pop(provinsi),
                                        contentPadding: EdgeInsets.all(0),
                                        title: Text(provinsi.nama));
                                  }))
                ])));
  }
}
