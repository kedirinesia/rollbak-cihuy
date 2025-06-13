// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/persediaan.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

class PersediaanDetail extends StatefulWidget {
  PersediaanModel persediaan;

  PersediaanDetail(this.persediaan);
  @override
  createState() => PersediaanDetailState();
}

class PersediaanDetailState extends State<PersediaanDetail> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController stockUpdateController =
      TextEditingController(text: '0');
  PersediaanModel persediaan;

  bool loading = true;
  bool formShow = false;
  int totalModal = 0;
  int radioValue = 0; // --> [0] tambah, [1] kurang
  String stockUpdate = "";
  String hargaBeli = "";

  @override
  void initState() {
    getData();
    super.initState();
    analitycs.pageView('/persediaanDetail/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Persediaan',
    });
  }

  void getData() async {
    try {
      Map<String, dynamic> dataToSend = {
        'id_gudang': widget.persediaan.id,
      };

      http.Response response =
          await http.post(Uri.parse('$apiUrlKasir/persediaan/getDetail'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': bloc.token.valueWrapper?.value,
              },
              body: json.encode(dataToSend));

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        var data = responseData['data'];

        if (status == 200) {
          setState(() {
            persediaan = PersediaanModel.fromJson(data);
            totalModal = persediaan.stock * persediaan.hargaBeli;
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

  void updateStock() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (stockUpdate != "") {
        try {
          setState(() {
            loading = true;
          });

          Map<String, dynamic> dataToSend = {
            'stock': stockUpdate,
            'harga_beli': hargaBeli,
            'statusAction': radioValue,
            'id_gudang': persediaan.id,
          };

          print('stockUpdate --> ${stockUpdateController.text}');
          print(dataToSend);
          http.Response response =
              await http.post(Uri.parse('$apiUrlKasir/persediaan/updateStock'),
                  headers: {
                    'Content-Type': 'application/json',
                    'authorization': bloc.token.valueWrapper?.value,
                  },
                  body: json.encode(dataToSend));

          String message = json.decode(response.body)['message'] ??
              'Terjadi kesalahan saat mengambil data dari server';
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            int status = responseData['status'];
            List<dynamic> datas = responseData['data'];

            if (status == 200) {
              setState(() {
                formShow = false;
                hargaBeliController.text = '';
                hargaBeli = '';
              });

              getData();
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
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text('Jumlah Stok Tidak Boleh Kosong'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          iconTheme: IconThemeData(color: Colors.white),
          expandedHeight: 200.0,
          backgroundColor: Theme.of(context).primaryColor,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: formShow
                  ? Text('Edit Produk')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Total Modal', textAlign: TextAlign.center),
                        SizedBox(height: 10.0),
                        Text('${formatNominal(totalModal)}',
                            textAlign: TextAlign.center),
                      ],
                    ),
              centerTitle: true),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          loading
              ? loadingWidget()
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
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
                        child: !formShow
                            ? ListTile(
                                title: Text(
                                  '${persediaan != null ? persediaan.barangModel.namaBarang : '-'}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${persediaan != null ? persediaan.barangModel.sku : '-'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      child: Text(
                                          '${persediaan != null ? persediaan.stock : '0'}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Harga Beli ${persediaan != null ? formatNominal(persediaan.hargaBeli) : '0'}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : FormInput(),
                      ),
                    ],
                  ),
                )
        ])),
      ]),
      floatingActionButton: !formShow
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.create),
              label: Text('Edit'),
              onPressed: () {
                setState(() {
                  formShow = true;
                  hargaBeliController.text =
                      persediaan != null ? persediaan.hargaBeli.toString() : '';
                  hargaBeli =
                      persediaan != null ? persediaan.hargaBeli.toString() : '';
                });
              },
            )
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Update'),
              onPressed: () => updateStock(),
            ),
    );
  }

  Widget FormInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 20.0),
          Container(
            child: Row(
              children: [
                Expanded(
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        onPressed: () {
                          setState(() {
                            radioValue = 0;
                          });
                        },
                        child: Text("TAMBAH"),
                        color: radioValue == 0 ? Colors.green : Colors.grey,
                        textColor: Colors.white)),
                Expanded(
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        onPressed: () {
                          setState(() {
                            radioValue = 1;
                          });
                        },
                        child: Text("KURANG"),
                        color: radioValue == 1 ? Colors.red : Colors.grey,
                        textColor: Colors.white)),
              ],
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                    controller: hargaBeliController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Harga Beli',
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      if (value == "") {
                        return "harga beli tidak boleh kosong";
                      }
                    },
                    onSaved: (String value) {
                      setState(() {
                        hargaBeli = value;
                      });
                    }),
              ),
              SizedBox(width: 5.0),
              Expanded(
                flex: 1,
                child: TextFormField(
                    controller: stockUpdateController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Stok',
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      if (value == "") {
                        return "stok tidak boleh kosong";
                      }
                    },
                    onSaved: (String value) {
                      print(value);
                      setState(() {
                        stockUpdate = value;
                      });
                    }),
              ),
            ],
          ),
          SizedBox(height: 30.0),
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child:
          SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
