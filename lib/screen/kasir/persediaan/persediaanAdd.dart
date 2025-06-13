// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/persediaan.dart';
import 'package:mobile/models/kasir/barang.dart';
import 'package:mobile/models/kasir/supplier.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/provider/analitycs.dart';

// SCREEN
import 'package:mobile/screen/select_state/barang.dart';
import 'package:mobile/screen/select_state/supplier.dart';

class PersediaanAdd extends StatefulWidget {
  @override
  createState() => PersediaanAddState();
}

class PersediaanAddState extends State<PersediaanAdd> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController stockController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();
  TextEditingController barangController = TextEditingController();
  TextEditingController supplierController = TextEditingController();

  bool loading = true;
  String stock = "";
  String hargaBeli = "";
  String keterangan = "";
  BarangModel barang;
  SupplierModel supplier;

  int page = 0;
  int radioValue = 0; // --> [0] tambah, [1] kurang
  bool isEdge = false;
  List<PersediaanModel> persediaans = [];
  List<PersediaanModel> tmpPersediaans = [];

  @override
  void initState() {
    super.initState();
    getData();
    analitycs.pageView('/addPersediaan/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tambah Persediaan',
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

  void saveProduk() async {
    int stokPersediaan = 0;
    persediaans.forEach((e) => stokPersediaan = e.stock);

    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (int.parse(stock) > 100000) {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text('Penambahan stok barang maksimal 100.000'),
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

      int jumlahStok = int.parse(stock) + stokPersediaan;

      if (jumlahStok > 100000) {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content:
                      Text('Tidak bisa menambah stok barang maksimal 100.000'),
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

      setState(() {
        loading = true;
      });

      try {
        Map<String, dynamic> dataToSend = {
          'stock': stock,
          'harga_beli': hargaBeli,
          'id_barang': barang.id,
          'id_supplier': supplier != null ? supplier.id : null,
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrlKasir/persediaan/addProduct'),
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
            await showDialog(
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
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ));
            Navigator.of(context).pop("success");
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
                      'Terjadi kesalahan saat mengirim data ke server\n Error: ${err.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Tambah Persediaan Produk'),
        centerTitle: true,
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
              onPressed: () => saveProduk(),
            ),
      body: loading
          ? loadingWidget()
          : SingleChildScrollView(
              child: formInput(),
            ),
    );
  }

  Widget formInput() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: stockController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Stok',
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
                  setState(() {
                    stock = value;
                  });
                }),
            SizedBox(height: 20.0),
            TextFormField(
                controller: hargaBeliController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Harga Beli',
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
            SizedBox(height: 20.0),
            TextFormField(
              controller: barangController,
              keyboardType: TextInputType.text,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Barang',
              ),
              validator: (String value) {
                if (value == "") {
                  return "barang tidak boleh kosong";
                }
              },
              onTap: () async {
                BarangModel response = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SelectBarang()),
                );

                if (response == null) return;
                barangController.text = response.namaBarang;
                setState(() {
                  barang = response;
                });
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: supplierController,
              keyboardType: TextInputType.text,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Supplier',
              ),
              validator: (String value) {
                if (value == "") {
                  return "supplier tidak boleh kosong";
                }
              },
              onTap: () async {
                SupplierModel response = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SelectSupplier()),
                );

                if (response == null) return;
                supplierController.text = response.nama;
                setState(() {
                  supplier = response;
                });
              },
            ),
            SizedBox(height: 50.0),
          ],
        ),
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
