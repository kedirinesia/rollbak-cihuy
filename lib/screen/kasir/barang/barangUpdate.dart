// @dart=2.9

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

// model
import 'package:mobile/models/kasir/barang.dart';
import 'package:mobile/models/kasir/category.dart';
import 'package:mobile/models/kasir/satuan.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// SCREEN
import 'package:mobile/screen/select_state/category.dart';
import 'package:mobile/screen/select_state/satuan.dart';

class BarangUpdate extends StatefulWidget {
  BarangModel barang;

  BarangUpdate(this.barang);

  @override
  createState() => BarangUpdateState();
}

class BarangUpdateState extends State<BarangUpdate> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController kodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();

  bool loading = true;
  File imgLocal;
  String id_barang = "";
  String kodeBarang = "";
  String nama = "";
  String imgUrl = "";
  var hargaJual = "";
  CategoryModel category;
  SatuanModel satuan;

  @override
  initState() {
    setData();

    super.initState();
  }

  void setData() async {
    try {
      kodeController.text = widget.barang.sku;
      namaController.text = widget.barang.namaBarang;
      hargaJualController.text = widget.barang.hargaJual.toString();
      satuanController.text = widget.barang.satuanModel.nama;
      kategoriController.text = widget.barang.categoryModel.nama;

      setState(() {
        id_barang = widget.barang.id;
        kodeBarang = widget.barang.sku;
        nama = widget.barang.namaBarang;
        imgUrl = widget.barang.imgUrl;
        hargaJual = widget.barang.hargaJual.toString();
        category = widget.barang.categoryModel;
        satuan = widget.barang.satuanModel;

        loading = false;
      });
    } catch (err) {
      setState(() {
        loading = false;
      });

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Gagal'),
                content: Text(
                    'Terjadi kesalahan saat mengirim data ke server saat mengambil data'),
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

  void getPicture() async {
    File image = await getPhoto();
    if (image != null) {
      print(image);
      setState(() {
        imgLocal = image;
      });
    }
  }

  void updateBarang() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      print('category --> ${category.nama}, satuan --> ${satuan.nama}');
      if (category == null || satuan == null) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Ada field yang masih kosong'),
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
      } else {
        setState(() {
          loading = true;
        });

        try {
          http.MultipartRequest request = http.MultipartRequest(
              'POST', Uri.parse('$apiUrlKasir/master/barang/update'));
          request.headers['authorization'] = bloc.token.valueWrapper?.value;

          request.fields['id_barang'] = id_barang;
          request.fields['sku'] = kodeBarang;
          request.fields['nama_barang'] = nama;
          request.fields['harga_jual'] = hargaJual;
          request.fields['id_kategori'] = category.id;
          request.fields['id_satuan'] = satuan.id;
          if (imgLocal != null) {
            request.files.add(
                await http.MultipartFile.fromPath('imgUrl', imgLocal.path));
          }

          http.StreamedResponse response = await request.send();
          Map<String, dynamic> responseData =
              json.decode(await response.stream.bytesToString());

          print(responseData);
          if (response.statusCode == 200) {
            if (responseData['status'] == 200) {
              await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Berhasil'),
                        content: Text(responseData['message']),
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

              Navigator.of(context).pop("sukses");
            } else {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Gagal'),
                        content: Text(responseData['message']),
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
                      content: Text(responseData['message']),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Ubah Barang'),
        centerTitle: true,
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
              onPressed: () => updateBarang(),
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
      padding: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            viewImg(),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                      controller: kodeController,
                      decoration: InputDecoration(
                        hintText: 'Kode Barang',
                        errorStyle: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      validator: (String value) {
                        if (value == "") {
                          return "kode barang tidak boleh kosong";
                        }
                      },
                      onSaved: (String value) {
                        setState(() {
                          kodeBarang = value;
                        });
                      }),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () async {
                    print('scan qr code');
                    var barcode = await BarcodeScanner.scan();
                    print('kode ${barcode.rawContent}');
                    if (barcode.rawContent.isNotEmpty) {
                      setState(() {
                        kodeController.text = barcode.rawContent;
                        kodeBarang = barcode.rawContent;
                      });
                    }
                  },
                  child: Image(
                      image: AssetImage('assets/img/kasir/qr-code.png'),
                      width: 30.0,
                      height: 30.0),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Nama Barang',
                  errorStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                validator: (String value) {
                  if (value == "") {
                    return "nama barang tidak boleh kosong";
                  }
                },
                onSaved: (String value) {
                  setState(() {
                    nama = value;
                  });
                }),
            SizedBox(height: 10.0),
            TextFormField(
                controller: hargaJualController,
                decoration: InputDecoration(
                  hintText: 'Harga Jual',
                  errorStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (String value) {
                  if (value == "") {
                    return "harga jual tidak boleh kosong";
                  }
                },
                onSaved: (String value) {
                  setState(() {
                    hargaJual = value;
                  });
                }),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: satuanController,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Satuan',
                    ),
                    onTap: () async {
                      print('klik satuan');
                      SatuanModel response = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SelectSatuan()),
                      );

                      if (response == null) return;
                      satuanController.text = response.nama;
                      setState(() {
                        satuan = response;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                    controller: kategoriController,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                    ),
                    onTap: () async {
                      print('klik kategori');
                      CategoryModel response = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SelectCategory()),
                      );

                      if (response == null) return;
                      kategoriController.text = response.nama;
                      setState(() {
                        category = response;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget viewImg() {
    return InkWell(
      onTap: () => getPicture(),
      child: AspectRatio(
        aspectRatio: 2.5 / 1.2,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8)),
          child: imgLocal == null
              ? imgUrl == ""
                  ? Center(
                      child: Text(
                        'FOTO ITEM',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imgUrl,
                    )
              : Image.file(imgLocal, fit: BoxFit.contain),
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
