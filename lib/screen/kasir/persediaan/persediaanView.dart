// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/persediaan.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// screen page
import 'package:mobile/screen/kasir/persediaan/persediaanDetail.dart';
import 'package:mobile/screen/kasir/persediaan/persediaanAdd.dart';

class PersediaanView extends StatefulWidget {
  @override
  createState() => PersediaanViewState();
}

class PersediaanViewState extends State<PersediaanView> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _formKey = GlobalKey<FormState>();
  TextEditingController query = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController stockUpdateController =
      TextEditingController(text: '0');

  int page = 0;
  int radioValue = 0; // --> [0] tambah, [1] kurang
  bool isEdge = false;
  bool loading = true;
  // String nama = '';
  String stockUpdate = "";
  String hargaBeli = "";
  List<PersediaanModel> persediaans = [];
  List<PersediaanModel> tmpPersediaans = [];

  @override
  void initState() {
    getData();
    super.initState();
    analitycs.pageView('/persediaanView/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'View Persediaan',
    });
  }

  Future<void> getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http
          .get(Uri.parse('$apiUrlKasir/persediaan/get?page=$page'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        var datas = responseData['data'];
        if (datas.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });

        if (status == 200) {
          datas.forEach((data) {
            persediaans.add(PersediaanModel.fromJson(data));
            tmpPersediaans.add(PersediaanModel.fromJson(data));
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
      setState(() {
        loading = false;
      });

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
    }
  }

  void refreshData() async {
    setState(() {
      persediaans.clear();
      tmpPersediaans.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });

    await getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Persediaan Stok"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            int stokPersediaan = 0;
            persediaans.forEach((e) => stokPersediaan = e.stock);

            if (stokPersediaan >= 100000) {
              return showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                        title: Text('Gagal'),
                        content: Text('Stok mencapai batas maksimum'),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'TUTUP',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ));
            }

            dynamic response = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => PersediaanAdd()));

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
                    : persediaans.length == 0
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
                              await getData();
                              _refreshController.loadComplete();
                            },
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: EdgeInsets.all(10.0),
                                itemCount: persediaans.length,
                                separatorBuilder: (_, i) =>
                                    SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  var _persediaan = persediaans[i];
                                  return InkWell(
                                    onTap: () async {
                                      dynamic response =
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PersediaanDetail(
                                                          _persediaan)));

                                      refreshData();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
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
                                        title: Text(
                                            '${_persediaan.barangModel.namaBarang} - ${_persediaan.barangModel.sku}',
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5.0),
                                            Text(
                                                'Supplier : ${_persediaan.supplierModel.nama}',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                        Colors.grey.shade700)),
                                            SizedBox(height: 3.0),
                                            Text(
                                                'Harga Beli : ${formatNominal(_persediaan.hargaBeli)}',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                        Colors.grey.shade700)),
                                            SizedBox(height: 3.0),
                                            Text(
                                                'Harga Jual : ${formatNominal(_persediaan.barangModel.hargaJual)}',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                        Colors.grey.shade700)),
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: Text(
                                              '${formatNominal(_persediaan.stock)}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                              )),
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
                var list = tmpPersediaans
                    .where((m) => m.barangModel.namaBarang
                        .toLowerCase()
                        .contains(query.text))
                    .toList();

                setState(() {
                  persediaans = list;
                });
              }),
        ),
        onEditingComplete: () {
          var list = tmpPersediaans
              .where((item) => item.barangModel.namaBarang
                  .toLowerCase()
                  .contains(query.text))
              .toList();

          setState(() {
            persediaans = list;
          });
        },
        onChanged: (value) {
          var list = tmpPersediaans
              .where((item) => item.barangModel.namaBarang
                  .toLowerCase()
                  .contains(query.text))
              .toList();
          setState(() {
            persediaans = list;
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
