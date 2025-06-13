// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/component/template-main.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

class EditToko extends StatefulWidget {
  @override
  _EditTokoState createState() => _EditTokoState();
}

class _EditTokoState extends State<EditToko> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nama = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController namaToko = TextEditingController();
  TextEditingController alamatToko = TextEditingController();

  @override
  void initState() {
    loadData();
    super.initState();
    analitycs.pageView('/edit/toko', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Edit Toko',
    });
  }

  @override
  void dispose() {
    nama.dispose();
    email.dispose();
    // nomor.dispose();
    alamat.dispose();
    namaToko.dispose();
    alamatToko.dispose();
    super.dispose();
  }

  void loadData() {
    nama.text = bloc.user.valueWrapper?.value.nama;
    email.text = bloc.user.valueWrapper?.value.email;
    // nomor.text = store.user.value.telepon;
    alamat.text = bloc.user.valueWrapper?.value.alamat;
    namaToko.text = bloc.user.valueWrapper?.value.namaToko;
    alamatToko.text = bloc.user.valueWrapper?.value.alamatToko;
  }

  void updateProfile() async {
    if (namaToko.text != bloc.user.valueWrapper?.value.namaToko ||
        alamatToko.text != bloc.user.valueWrapper?.value.alamatToko ||
        nama.text != bloc.user.valueWrapper?.value.nama ||
        email.text != bloc.user.valueWrapper?.value.email ||
        alamat.text != bloc.user.valueWrapper?.value.alamat) {
      setState(() {
        loading = true;
      });

      http.Response response = await http.post(Uri.parse('$apiUrl/user/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': bloc.token.valueWrapper?.value
          },
          body: json.encode({
            'nama': nama.text,
            'email': email.text,
            'alamat': alamat.text,
            'nama_toko': namaToko.text,
            'alamat_toko': alamatToko.text
          }));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(Alert('Perubahan berhasil disimpan'));
        getUserInfo().then((value) {
          loadData();
        });
      } else {
        try {
          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');

          Map<String, dynamic> responseData = json.decode(response.body);
          String errorMessage =
              responseData['message'] ?? 'Gagal menyimpan perubahan';

          ScaffoldMessenger.of(context)
              .showSnackBar(Alert(errorMessage, isError: true));
        } catch (e) {
          print('Error parsing response: $e');
          ScaffoldMessenger.of(context).showSnackBar(Alert(
              'Terjadi kesalahan saat menyimpan perubahan',
              isError: true));
        }
      }

      setState(() {
        loading = false;
      });
    }
  }

  void edit() async {
    if (nama.text == bloc.user.valueWrapper?.value.namaToko &&
        alamat.text == bloc.user.valueWrapper?.value.alamatToko) return;

    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
        Uri.parse('$apiUrl/user/toko/update'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body:
            json.encode({'nama_toko': nama.text, 'alamat_toko': alamat.text}));

    if (response.statusCode == 200) {
      String message = json.decode(response.body)['message'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(message ?? 'Berhasil merubah informasi toko'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );

      updateUserInfo();
    } else {
      String message = json.decode(response.body)['message'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(message ?? 'Gagal merubah informasi toko'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TemplateMain(
        title: 'Ubah Profil',
        children: <Widget>[
          loading
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: SpinKitThreeBounce(
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          size: 35)))
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                            controller: nama,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                labelText: 'Nama Pengguna',
                                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                prefixIcon: Icon(Icons.person_rounded, color: Theme.of(context).primaryColor,),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Nama tidak boleh kosong';
                              else
                                return null;
                            },
                          )
                        : TextFormField(
                            controller: nama,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              labelText: 'Nama Pengguna',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Nama tidak boleh kosong';
                              else
                                return null;
                            },
                          ),
                        SizedBox(height: 15),
                        packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                            controller: email,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                prefixIcon: Icon(Icons.email_rounded, color: Theme.of(context).primaryColor,),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Email tidak boleh kosong';
                              else
                                return null;
                            },
                          )
                        : TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Email tidak boleh kosong';
                              else
                                return null;
                            },
                          ),
                        SizedBox(height: 15),
                        packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                            controller: alamat,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                labelText: 'Alamat',
                                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor,),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Alamat tidak boleh kosong';
                              else
                                return null;
                            },
                          )
                        : TextFormField(
                            controller: alamat,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                labelText: 'Alamat',
                                prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Alamat tidak boleh kosong';
                              else
                                return null;
                            },
                          ),
                        SizedBox(height: 15),
                        packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                            controller: namaToko,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                labelText: 'Nama Toko',
                                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                prefixIcon: Icon(Icons.store, color: Theme.of(context).primaryColor,),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Nama toko tidak boleh kosong';
                              else
                                return null;
                            },
                          )
                        : TextFormField(
                            controller: namaToko,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                labelText: 'Nama Toko',
                                prefixIcon: Icon(Icons.store),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Nama toko tidak boleh kosong';
                              else
                                return null;
                            },
                          ),
                        SizedBox(height: 15),
                        packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                            controller: alamatToko,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                labelText: 'Alamat Toko',
                                labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor,),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Alamat toko tidak boleh kosong';
                              else
                                return null;
                            },
                          )
                        : TextFormField(
                            controller: alamatToko,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                labelText: 'Alamat Toko',
                                prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Alamat toko tidak boleh kosong';
                              else
                                return null;
                            },
                          ),
                      ],
                    ),
                  ),
                )
        ],
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            icon: Icon(Icons.save),
            label: Text('Simpan'),
            // onPressed: () => edit(),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                updateProfile();
              }
            },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked);
  }
}
