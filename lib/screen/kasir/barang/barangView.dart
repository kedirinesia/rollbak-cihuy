// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/barang.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// screen page
import 'package:mobile/screen/kasir/barang/barangAdd.dart';
import 'package:mobile/screen/kasir/barang/barangUpdate.dart';

class BarangView extends StatefulWidget {
  @override
  createState() => BarangViewState();
}

class BarangViewState extends State<BarangView> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController query = TextEditingController();

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  String nama = '';
  List<BarangModel> barangs = [];
  List<BarangModel> tmpBarangs = [];

  @override
  initState() {
    super.initState();

    getData();
  }

  void getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/master/barang/get?page=$page'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        List<dynamic> datas = responseData['data'];
        if (datas.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          datas.forEach((data) {
            barangs.add(BarangModel.fromJson(data));
            tmpBarangs.add(BarangModel.fromJson(data));
          });

          setState(() {
            page++;
          });
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
                        onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: () => Navigator.of(context).pop(),
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
                    'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void refreshData() async {
    setState(() {
      barangs.clear();
      tmpBarangs.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });
    getData();
  }

  void deleteItem(BarangModel barang) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Apakah anda yakin ingin menghapus barang ini ?'),
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
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      Navigator.of(context, rootNavigator: true).pop();

                      try {
                        var idBarang = barang.id;
                        Map<String, dynamic> dataToSend = {
                          'id_barang': idBarang
                        };

                        http.Response response = await http.post(
                            Uri.parse('$apiUrlKasir/master/barang/delete'),
                            headers: {
                              'Content-Type': 'application/json',
                              'authorization': bloc.token.valueWrapper?.value,
                            },
                            body: json.encode(dataToSend));

                        var responseData = json.decode(response.body);
                        String message = responseData['message'] ??
                            'Terjadi kesalahan saat mengambil data dari server';
                        if (response.statusCode == 200) {
                          int status = responseData['status'];
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      ],
                                    ));

                            refreshData();
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
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                    }),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Master Barang"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            dynamic response = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => BarangAdd()));

            if (response != null) {
              refreshData();
            }
          }),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            formSearch(),
            Flexible(
                flex: 1,
                child: loading
                    ? LoadWidget()
                    : barangs.length == 0
                        ? buildEmpty()
                        : SmartRefresher(
                            controller: _refreshController,
                            enablePullUp: true,
                            enablePullDown: true,
                            onRefresh: () async {
                              refreshData();
                              _refreshController.refreshCompleted();
                            },
                            onLoading: () async {
                              getData();
                              _refreshController.loadComplete();
                            },
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: EdgeInsets.all(10.0),
                                itemCount: barangs.length,
                                separatorBuilder: (_, i) =>
                                    SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  var _barang = barangs[i];
                                  return InkWell(
                                    onTap: () async {
                                      dynamic response =
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BarangUpdate(_barang)));

                                      if (response != null) {
                                        refreshData();
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                offset: Offset(5, 10.0),
                                                blurRadius: 20)
                                          ]),
                                      child: ListTile(
                                        title: Text(_barang.namaBarang,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700)),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(_barang.sku,
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                        Colors.grey.shade700)),
                                            SizedBox(width: 5.0),
                                            Text('-'),
                                            SizedBox(width: 5.0),
                                            Text(
                                                formatRupiah(_barang.hargaJual),
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                        Colors.grey.shade700)),
                                          ],
                                        ),
                                        trailing: InkWell(
                                          onTap: () => deleteItem(_barang),
                                          child: Icon(
                                            Icons.delete,
                                            size: 25.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }))),
          ],
        ),
      ),
    );
  }

  Widget formSearch() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: query,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Cari Nama Barang disini...',
          isDense: true,
          suffixIcon: InkWell(
              child: Icon(Icons.search),
              onTap: () {
                var list = tmpBarangs
                    .where(
                        (m) => m.namaBarang.toLowerCase().contains(query.text))
                    .toList();

                setState(() {
                  barangs = list;
                });
              }),
        ),
        onEditingComplete: () {
          var list = tmpBarangs
              .where(
                  (item) => item.namaBarang.toLowerCase().contains(query.text))
              .toList();

          setState(() {
            barangs = list;
          });
        },
        onChanged: (value) {
          var list = tmpBarangs
              .where(
                  (item) => item.namaBarang.toLowerCase().contains(query.text))
              .toList();
          setState(() {
            barangs = list;
          });
        },
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
