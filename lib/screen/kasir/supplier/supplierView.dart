// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/supplier.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// screen page
import 'package:mobile/screen/kasir/supplier/supplierAdd.dart';
import 'package:mobile/screen/kasir/supplier/supplierUpdate.dart';

class SupplierView extends StatefulWidget {
  @override
  createState() => SupplierViewState();
}

class SupplierViewState extends State<SupplierView> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _formKey = new GlobalKey<FormState>();
  TextEditingController query = TextEditingController();

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  String nama = '';
  List<SupplierModel> suppliers = [];
  List<SupplierModel> tmpSuppliers = [];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/supplier/view/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Supplier Vie Kasir',
    });
    getData();
  }

  void getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/master/supplier/get?page=$page'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        List<dynamic> datas = responseData['data'];
        if (datas.length == 0) isEdge = true;
        if (status == 200) {
          datas.forEach((data) {
            suppliers.add(SupplierModel.fromJson(data));
            tmpSuppliers.add(SupplierModel.fromJson(data));
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
                content:
                    Text('Terjadi kesalahan saat mengambil data dari server'),
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
      suppliers.clear();
      tmpSuppliers.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });
    getData();
  }

  void deleteItem(SupplierModel supplier) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Apakah anda yakin ingin menghapus supplier ini ?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text('TIDAK')),
                TextButton(
                    child: Text('YA'),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      Navigator.of(context, rootNavigator: true).pop();

                      try {
                        var idSupplier = supplier.id;
                        Map<String, dynamic> dataToSend = {
                          'id_supplier': idSupplier
                        };

                        http.Response response = await http.post(
                            Uri.parse('$apiUrlKasir/master/supplier/delete'),
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
        title: Text("Supplier"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            dynamic response = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SupplierAdd()));

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
                    : suppliers.length == 0
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
                                itemCount: suppliers.length,
                                separatorBuilder: (_, i) =>
                                    SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  var _supplier = suppliers[i];
                                  return InkWell(
                                    onTap: () async {
                                      dynamic response = await Navigator.of(
                                              context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  SupplierUpdate(_supplier)));

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
                                        title: Text(_supplier.nama,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700)),
                                        subtitle: Text(_supplier.email,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey.shade700)),
                                        trailing: InkWell(
                                          onTap: () => deleteItem(_supplier),
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
                                }),
                          )),
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
            hintText: 'Cari Nama Supplier disini...',
            isDense: true,
            suffixIcon: InkWell(
                child: Icon(Icons.search),
                onTap: () {
                  var list = tmpSuppliers
                      .where((m) => m.nama.toLowerCase().contains(query.text))
                      .toList();

                  setState(() {
                    suppliers = list;
                  });
                })),
        onEditingComplete: () {
          var list = tmpSuppliers
              .where((item) => item.nama.toLowerCase().contains(query.text))
              .toList();

          setState(() {
            suppliers = list;
          });
        },
        onChanged: (value) {
          var list = tmpSuppliers
              .where((item) => item.nama.toLowerCase().contains(query.text))
              .toList();
          setState(() {
            suppliers = list;
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
