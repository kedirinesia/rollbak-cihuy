// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/satuan.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class SatuanPage extends StatefulWidget {
  @override
  createState() => SatuanPageState();
}

class SatuanPageState extends State<SatuanPage> {
  final _formKey = new GlobalKey<FormState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController satuanController = TextEditingController();

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  String satuan = '';
  List<SatuanModel> satuans = [];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/satuan/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Satuan',
    });
    getData();
  }

  Future<void> getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/master/satuan/get?page=$page'),
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
            satuans.add(SatuanModel.fromJson(data));
          });
          setState(() {
            page++;
            satuanController.text = '';
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
      satuans.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });
    await getData();
  }

  void submitSatuan() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });

      try {
        Map<String, dynamic> dataToSend = {
          'nama': satuan,
          'aktif': true,
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrlKasir/master/satuan/add'),
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
                      'Terjadi kesalahan saat mengirim data ke server\nError: ${err.toString()}'),
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
  }

  void deleteItem(SatuanModel _satuan) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('Apakah anda yakin ingin menghapus satuan ini ?'),
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
                  var idSatuan = _satuan.id;
                  Map<String, dynamic> dataToSend = {'id_satuan': idSatuan};

                  http.Response response = await http.post(
                      Uri.parse('$apiUrlKasir/master/satuan/delete'),
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
                                        color: Theme.of(context).primaryColor,
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
                                        color: Theme.of(context).primaryColor,
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
                                'Terjadi kesalahan saat mengirim data ke server\nError: ${err.toString()}'),
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
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satuan'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            formInput(),
            SizedBox(height: 10.0),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : satuans.length == 0
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
                              itemCount: satuans.length,
                              separatorBuilder: (_, i) => SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                var _satuan = satuans[i];
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(.1),
                                            offset: Offset(5, 10.0),
                                            blurRadius: 20)
                                      ]),
                                  child: ListTile(
                                    title: Text(_satuan.nama,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700)),
                                    subtitle: Text(
                                        formatDate(_satuan.created_at,
                                                "d MMMM yyyy HH:mm:ss") ??
                                            ' ',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey.shade700)),
                                    trailing: InkWell(
                                      onTap: () => deleteItem(_satuan),
                                      child: Icon(
                                        Icons.delete,
                                        size: 25.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget formInput() {
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
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  controller: satuanController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tambah Satuan',
                    isDense: true,
                  ),
                  validator: (String value) {
                    if (value == "") {
                      return "satuan tidak boleh kosong";
                    }
                  },
                  onSaved: (String value) {
                    setState(() {
                      satuan = value;
                    });
                  }),
            ),
            SizedBox(width: 5.0),
            InkWell(
              onTap: () => submitSatuan(),
              child: Icon(
                Icons.add,
                size: 30.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
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
