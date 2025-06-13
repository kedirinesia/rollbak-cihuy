// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/provider/analitycs.dart';

class SupplierAdd extends StatefulWidget {
  @override
  createState() => SupplierrAddState();
}

class SupplierrAddState extends State<SupplierAdd> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController namaController = TextEditingController();
  TextEditingController telpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  bool loading = false;
  String nama = "";
  String telp = "";
  String email = "";
  String alamat = "";

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/addSupplier/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tambah Supplier',
    });
  }

  void saveSupplier() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });

      try {
        Map<String, dynamic> dataToSend = {
          'nama': nama,
          'telp': telp,
          'email': email,
          'alamat': alamat,
          'aktif': true,
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrlKasir/master/supplier/add'),
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
        setState(() {
          loading = false;
        });

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
              title: Text('Tambah Supplier'), centerTitle: true),
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
                                labelText: 'Nama Supplier',
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
                                labelText: 'Nomor Telpon',
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
                                labelText: 'Email',
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
                                labelText: 'Alamat',
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
                  ),
          ]),
        ),
      ]),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
              onPressed: () => saveSupplier(),
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
