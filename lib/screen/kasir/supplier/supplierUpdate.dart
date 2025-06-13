// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/supplier.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/provider/analitycs.dart';

class SupplierUpdate extends StatefulWidget {
  SupplierModel supplier;

  SupplierUpdate(this.supplier);

  @override
  createState() => SupplierUpdateState();
}

class SupplierUpdateState extends State<SupplierUpdate> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController namaController = TextEditingController();
  TextEditingController telpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  bool loading = true;
  String id_supplier = "";
  String nama = "";
  String telp = "";
  String email = "";
  String alamat = "";

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/supplier/update/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Update Supplier Kasir',
    });
    setData();
  }

  void setData() async {
    namaController.text = widget.supplier.nama;
    telpController.text = widget.supplier.telp;
    emailController.text = widget.supplier.email;
    alamatController.text = widget.supplier.alamat;

    setState(() {
      id_supplier = widget.supplier.id;
      nama = widget.supplier.nama;
      telp = widget.supplier.telp;
      email = widget.supplier.email;
      alamat = widget.supplier.alamat;

      loading = false;
    });
  }

  void updateSupplier() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });

      try {
        Map<String, dynamic> dataToSend = {
          'id_supplier': id_supplier,
          'nama': nama,
          'telp': telp,
          'email': email,
          'alamat': alamat,
          'aktif': true,
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrlKasir/master/supplier/update'),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': bloc.token.valueWrapper?.value,
                },
                body: json.encode(dataToSend));

        setState(() {
          loading = false;
        });
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

        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Ubah'),
              onPressed: () => updateSupplier(),
            ),
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          iconTheme: IconThemeData(color: Colors.white),
          expandedHeight: 200.0,
          backgroundColor: Theme.of(context).primaryColor,
          pinned: true,
          flexibleSpace:
              FlexibleSpaceBar(title: Text('Ubah Supplier'), centerTitle: true),
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
                            controller: namaController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: 'Nama Supplier',
                              prefixIcon: Icon(Icons.person),
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            validator: (String value) {
                              if (value == "") {
                                return "nama tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                nama = value;
                              });
                            }),
                        SizedBox(height: 10.0),
                        TextFormField(
                            controller: telpController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: 'Nomor Telpon',
                              prefixIcon: Icon(Icons.contacts),
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              if (value == "") {
                                return "nomor telpon tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                telp = value;
                              });
                            }),
                        SizedBox(height: 10.0),
                        TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.mail),
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            validator: (String value) {
                              if (value == "") {
                                return "email tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                email = value;
                              });
                            }),
                        SizedBox(height: 10.0),
                        TextFormField(
                            controller: alamatController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              prefixIcon: Icon(Icons.home),
                              hintText: 'Alamat',
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.multiline,
                            validator: (String value) {
                              if (value == "") {
                                return "alamat tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                alamat = value;
                              });
                            }),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                )
        ])),
      ]),
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
