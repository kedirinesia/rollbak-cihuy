// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// model
import 'package:mobile/models/kasir/barang.dart';

class SelectBarang extends StatefulWidget {
  @override
  createState() => SelectBarangState();
}

class SelectBarangState extends State<SelectBarang> {
  List<BarangModel> barangs = [];
  List<BarangModel> filtered = [];
  bool isLoading = true;

  @override
  initState() {
    getList();

    super.initState();
  }

  void getList() async {
    try {
      http.Response response =
          await http.get(Uri.parse('$apiUrlKasir/master/barang/all'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var datas = responseData['data'];
        barangs.clear();
        filtered.clear();

        datas.forEach((data) {
          barangs.add(BarangModel.fromJson(data));
          filtered.add(BarangModel.fromJson(data));
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
      appBar: AppBar(title: Text('Barang'), centerTitle: true, elevation: 0),
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
                    hintText: 'Cari Nama Barang'),
                onChanged: (value) {
                  filtered = barangs
                      .where((el) => el.namaBarang
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
                            color: Theme.of(context).primaryColor, size: 35),
                      ),
                    )
                  : barangs.length == 0
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'TIDAK ADA DATA',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            BarangModel barang = filtered[i];

                            return ListTile(
                                dense: true,
                                onTap: () {
                                  Navigator.of(context).pop(barang);
                                },
                                contentPadding: EdgeInsets.all(0),
                                title: Text(barang.namaBarang));
                          }),
            ),
          ],
        ),
      ),
    );
  }
}
