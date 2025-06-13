// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/supplier.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// SCREEN
import 'package:mobile/screen/select_state/supplier.dart';

class TambahHutang extends StatefulWidget {
  @override
  createState() => TambahHutangState();
}

class TambahHutangState extends State<TambahHutang> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nominalController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController tglController = TextEditingController();

  // FORMAT TANGGAL
  DateTime selectedDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  // END

  bool loading = false;
  String nominal = "";
  String namaSupplier = "";
  String keterangan = "";
  SupplierModel supplier;

  @override
  initState() {
    super.initState();
  }

  // SELECT DATE
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.utc(1965, 1, 1),
      lastDate: new DateTime(2500),
      locale: Locale('id', 'ID'),
    );

    if (picked != null) {
      String value = formatter.format(picked);

      setState(() {
        selectedDate = picked;
        tglController.text = value;
      });
    }
  }

  void simpanHutang() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (int.parse(nominal) >= 0) {
        setState(() {
          loading = true;
        });

        Map<String, dynamic> dataToSend = {
          'nominal': nominal,
          'tanggal': tglController.text,
          'keterangan': keteranganController.text,
          'id_supplier': supplier != null ? supplier.id : null,
          'type_piutang': 3
        };

        try {
          http.Response response = await http.post(
              Uri.parse('$apiUrlKasir/transaksi/piutang/saveHutang'),
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
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text(
                      'Nominal tidak boleh bernilai negatif atau kurang dari 0'),
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
              title: Text(
                'Tambah Hutang Baru',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              centerTitle: true),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          loading
              ? loadingWidget()
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            controller: nominalController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Nominal',
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              if (value == "") {
                                return "nominal tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                nominal = value;
                              });
                            }),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: supplierController,
                          keyboardType: TextInputType.text,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Supplier',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          validator: (String value) {
                            if (value == "") {
                              return "supplier tidak boleh kosong";
                            }
                          },
                          onSaved: (String value) {
                            setState(() {
                              namaSupplier = value;
                            });
                          },
                          onTap: () async {
                            SupplierModel response =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => SelectSupplier()),
                            );

                            if (response == null) return;
                            supplierController.text = response.nama;
                            setState(() {
                              supplier = response;
                            });
                          },
                        ),
                        SizedBox(height: 10.0),
                        GestureDetector(
                          onTap: () => _selectDate(),
                          child: AbsorbPointer(
                            child: FocusScope(
                              node: new FocusScopeNode(),
                              child: TextFormField(
                                controller: tglController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Tanggal',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: keteranganController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Keterangan',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                )
        ]))
      ]),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
              onPressed: () => simpanHutang(),
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
