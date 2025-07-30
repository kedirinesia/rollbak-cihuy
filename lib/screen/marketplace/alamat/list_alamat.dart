// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_alamat.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/marketplace/alamat/tambah_alamat.dart';
import 'package:mobile/screen/marketplace/alamat/ubah_alamat.dart';

class ListAlamatPage extends StatefulWidget {
  @override
  _ListAlamatPageState createState() => _ListAlamatPageState();
}

class _ListAlamatPageState extends State<ListAlamatPage> {
  bool loading = true;
  Future<List<AlamatModel>> fetchAlamat() async {
    List<AlamatModel> items = [];
    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/shipping'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> addresses = json.decode(response.body)['data'];
      addresses.forEach((el) => items.add(AlamatModel.fromJson(el)));
    }

    return items;
  }

  // Future<void> deleteShipping(String id) async {
  //   http.Response response = await http.post(
  //     Uri.parse('$apiUrl/market/shipping/delete'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': bloc.token.valueWrapper?.value,
  //     },
  //     body: json.encode({
  //       'id': id,
  //     }),
  //   );
  //   if (response.statusCode == 200) setState(() {});
  // }

  Future<void> deleteShipping(AlamatModel _alamat) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Apakah anda yakin ingin menghapus alamat ini ?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'TIDAK',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                TextButton(
                  child: Text(
                    'YA',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    Navigator.of(context, rootNavigator: true).pop();

                    try {
                      var idAlamat = _alamat.id;
                      Map<String, dynamic> dataToSend = {'id': idAlamat};

                      http.Response response = await http.post(
                          Uri.parse('$apiUrl/market/shipping/remove'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': bloc.token.valueWrapper?.value,
                          },
                          body: json.encode(dataToSend));

                      var responseData = json.decode(response.body);
                      int status = responseData['status'];
                      String message = responseData['message'] ??
                          'Terjadi kesalahan saat mengambil data dari server';
                      if (response.statusCode == 200) {
                        List<dynamic> datas = responseData['data'];

                        if (status == 200) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('Berhasil'),
                                    content: Text(message),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ));

                          // refreshData();
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('Gagal'),
                                    content: Text(message),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ));
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('Gagal'),
                                  content: Text(message),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    )
                                  ],
                                ));
                      }
                    } catch (err) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('Gagal'),
                                content: Text(
                                    'Terjadi kesalahan saat mengirim data ke server\nError: ${err.toString()}'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  )
                                ],
                              ));
                    } finally {
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                )
              ],
            ));
  }

  Future<void> showOptions(AlamatModel alamat) async {
    int option = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              elevation: 0,
              child: Text('Ubah Alamat'),
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: double.infinity,
            ),
            SizedBox(height: 10),
            MaterialButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              elevation: 0,
              child: Text('Hapus Alamat'),
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
    if (option == null) return;
    if (option == 1) {
      bool state = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UbahAlamatPage(alamat),
        ),
      );
      if (state) fetchAlamat();
      setState(() {});
    }
    if (option == 2) deleteShipping(alamat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Alamat'), actions: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TambahAlamatPage()));
              setState(() {});
            })
      ]),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<AlamatModel>>(
            future: fetchAlamat(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData)
                return Center(
                    child: SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor, size: 35));

              return ListView.separated(
                padding: EdgeInsets.all(20),
                itemCount: snapshot.data.length,
                separatorBuilder: (_, i) => SizedBox(height: 10),
                itemBuilder: (_, i) {
                  AlamatModel alamat = snapshot.data[i];

                  return InkWell(
                    onTap: () => Navigator.of(context).pop(alamat),
                    onLongPress: () => showOptions(alamat),
                    child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.grey.withOpacity(.3), width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alamat.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text(alamat.phone),
                              SizedBox(height: 5),
                              Text(
                                  '${alamat.address1}, ${alamat.address2}, ${alamat.kecamatan.name}, ${alamat.kota.type} ${alamat.kota.name}, ${alamat.provinsi.name} - ${alamat.postalCode}')
                            ])),
                  );
                },
              );
            }),
      ),
    );
  }
}
