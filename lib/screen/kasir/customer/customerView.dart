// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/customer.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// screen page
import 'package:mobile/screen/kasir/customer/customerAdd.dart';
import 'package:mobile/screen/kasir/customer/customerUpdate.dart';

class CustomerView extends StatefulWidget {
  @override
  createState() => CustomerViewState();
}

class CustomerViewState extends State<CustomerView> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _formKey = new GlobalKey<FormState>();
  TextEditingController query = TextEditingController();

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  String nama = '';
  List<CustomerModel> customers = [];
  List<CustomerModel> tmpCustomers = [];

  @override
  initState() {
    super.initState();

    getData();
  }

  void getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/master/customer/get?page=$page'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        List<dynamic> datas = responseData['data'];
        if (datas.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          datas.forEach((data) {
            customers.add(CustomerModel.fromJson(data));
            tmpCustomers.add(CustomerModel.fromJson(data));
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
      customers.clear();
      tmpCustomers.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });
    getData();
  }

  void deleteItem(CustomerModel customer) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content:
                  Text('Apakah anda yakin ingin menghapus pelanggan ini ?'),
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
                        var idCustomer = customer.id;
                        Map<String, dynamic> dataToSend = {
                          'id_customer': idCustomer
                        };

                        http.Response response = await http.post(
                            Uri.parse('$apiUrlKasir/master/customer/delete'),
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
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pelanggan"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            dynamic response = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => CustomerAdd()));

            if (response != null) {
              setState(() {
                customers.clear();
                tmpCustomers.clear();
                page = 0;
                loading = true;
                isEdge = false;
              });

              getData();
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
                  : customers.length == 0
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
                              itemCount: customers.length,
                              separatorBuilder: (_, i) => SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                var _customer = customers[i];
                                return InkWell(
                                  onTap: () async {
                                    dynamic response =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerUpdate(_customer)));

                                    if (response != null) {
                                      refreshData();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.1),
                                              offset: Offset(5, 10.0),
                                              blurRadius: 20)
                                        ]),
                                    child: ListTile(
                                      title: Text(_customer.nama,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700)),
                                      subtitle: Text(_customer.email,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade700)),
                                      trailing: InkWell(
                                        onTap: () => deleteItem(_customer),
                                        child: Icon(
                                          Icons.delete,
                                          size: 25.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
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
            hintText: 'Cari Nama Pelangan disini...',
            isDense: true,
            suffixIcon: InkWell(
                child: Icon(Icons.search),
                onTap: () {
                  var list = tmpCustomers
                      .where((m) => m.nama.toLowerCase().contains(query.text))
                      .toList();

                  setState(() {
                    customers = list;
                  });
                })),
        onEditingComplete: () {
          var list = tmpCustomers
              .where((item) => item.nama.toLowerCase().contains(query.text))
              .toList();

          setState(() {
            customers = list;
          });
        },
        onChanged: (value) {
          var list = tmpCustomers
              .where((item) => item.nama.toLowerCase().contains(query.text))
              .toList();
          setState(() {
            customers = list;
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
