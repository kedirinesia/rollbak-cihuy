// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:http/http.dart' as http;

class SelectKecamatanPage extends StatefulWidget {
  final Lokasi kota;
  SelectKecamatanPage(this.kota);

  @override
  _SelectKecamatanPageState createState() => _SelectKecamatanPageState();
}

class _SelectKecamatanPageState extends State<SelectKecamatanPage> {
  List<Lokasi> regions = [];
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

    http.Response response = await http
        .get(Uri.parse('$apiUrl/kabupaten/${widget.kota.kode}/kecamatan'));

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      regions.clear();
      filtered.clear();
      datas.forEach((el) => regions.add(Lokasi.fromJson(el)));
      filtered.addAll(regions);
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
          title: Text('Kecamatan'),
          centerTitle: true,
          elevation: 0,
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
                children: <Widget>[
                  TextFormField(
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          isDense: true,
                          icon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                          hintText: 'Cari Kecamatan',
                          hintStyle: TextStyle(
                              color: packageName == 'com.eralink.mobileapk'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor)),
                      onChanged: (value) {
                        filtered = regions
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
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                      size: 35)))
                          : regions.length == 0
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                      child: Text('TIDAK ADA DATA',
                                          style: TextStyle(
                                              color: packageName ==
                                                      'com.lariz.mobile'
                                                  ? Theme.of(context)
                                                      .secondaryHeaderColor
                                                  : Theme.of(context)
                                                      .primaryColor))))
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
