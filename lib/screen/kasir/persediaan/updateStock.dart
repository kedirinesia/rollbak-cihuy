// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// component

// model
import 'package:mobile/models/kasir/persediaan.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

class UpdateStock extends StatefulWidget {
  PersediaanModel persediaan;

  UpdateStock(
    this.persediaan,
  );

  @override
  createState() => UpdateStockState();
}

class UpdateStockState extends State<UpdateStock> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController stockUpdateController =
      TextEditingController(text: '0');

  bool loaded = false;
  int radioValue = 0; // --> [0] tambah, [1] kurang
  String stockUpdate = "";
  String hargaBeli = "";

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/updateStok/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Update Stok Kasir',
    });
  }

  void updateStock() async {
    try {
      Map<String, dynamic> dataToSend = {
        'stock': stockUpdate,
        'harga_beli': hargaBeli,
        'statusAction': radioValue,
        'id_gudang': widget.persediaan.id,
      };

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
          Navigator.of(context).pop();
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
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
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
        loaded = false;
      });
    }
  }

  void viewUpdateStock(context) async {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return loaded
                  ? loadingWidget(context)
                  : Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'EDIT STOCK',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Radio(
                                          value: 0,
                                          groupValue: radioValue,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (value) {
                                            setState(() {
                                              radioValue = value;
                                            });
                                          }),
                                      SizedBox(height: 5.0),
                                      Text('Tambah'),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Radio(
                                          value: 1,
                                          groupValue: radioValue,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (value) {
                                            setState(() {
                                              radioValue = value;
                                            });
                                          }),
                                      SizedBox(height: 5.0),
                                      Text('Kurang'),
                                    ],
                                  ),
                                ),
                              ],
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
                                        setState(() {
                                          stockUpdate = value;
                                        });
                                      }),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.0),
                            Row(
                              children: [
                                TextButton(
                                    child: Text(
                                      'TUTUP',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                TextButton(
                                    child: Text(
                                      'SIMPAN',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loaded = true;
                                      });
                                      updateStock();
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AKSI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.0),
          ListTile(
            title: Text(widget.persediaan.barangModel.namaBarang,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                )),
            subtitle: Text(widget.persediaan.barangModel.sku,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey,
                )),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${widget.persediaan.stock}',
                    style: TextStyle(
                      fontSize: 13.0,
                    )),
                SizedBox(height: 5.0),
                Text(formatRupiah(widget.persediaan.barangModel.hargaJual),
                    style:
                        TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          InkWell(
            onTap: () {
              hargaBeliController.text = widget.persediaan.hargaBeli.toString();
              setState(() {
                hargaBeli = widget.persediaan.hargaBeli.toString();
              });
              Navigator.of(context).pop();
              viewUpdateStock(context);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        offset: Offset(5.0, 10.0),
                        blurRadius: 8.0),
                  ]),
              child: ListTile(
                title: Text(
                  'Tambah / Kurang Stok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          InkWell(
            onTap: () {
              print('detail stok produk');
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        offset: Offset(5.0, 10.0),
                        blurRadius: 8.0),
                  ]),
              child: ListTile(
                title: Text(
                  'Lihat Stok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Widget loadingWidget(context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child:
            SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
