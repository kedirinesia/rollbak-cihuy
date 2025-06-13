// @dart=2.9

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/category.dart';
import 'package:mobile/models/kasir/satuan.dart';
import 'package:mobile/models/kasir/supplier.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// SCREEN
import 'package:mobile/screen/select_state/category.dart';
import 'package:mobile/screen/select_state/satuan.dart';
import 'package:mobile/screen/select_state/supplier.dart';

class BarangAdd extends StatefulWidget {
  @override
  createState() => BarangAddState();
}

class BarangAddState extends State<BarangAdd> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _namaBarangController = TextEditingController();
  TextEditingController _kodeBarangController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _hargaBeliController = TextEditingController();
  TextEditingController _hargaJualController = TextEditingController();
  TextEditingController _satuanController = TextEditingController();
  TextEditingController _kategoriController = TextEditingController();
  TextEditingController _supplierController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();

  bool loading = false;
  File imgUrl;
  String kodeBarang = "";
  String nama = "";
  String stock = "";
  String hargaBeli = "";
  String hargaJual = "";
  String keterangan = "";
  CategoryModel category;
  SatuanModel satuan;
  SupplierModel supplier;

  @override
  initState() {
    super.initState();
  }

  void getPicture() async {
    File image = await getPhoto();
    if (image != null) {
      setState(() {
        imgUrl = image;
      });
    }
  }

  void clearForm() {
    _namaBarangController.text = "";
    _kodeBarangController.text = "";
    _stockController.text = "";
    _hargaBeliController.text = "";
    _hargaBeliController.text = "";
    _hargaJualController.text = "";
    _satuanController.text = "";
    _kategoriController.text = "";
    _keteranganController.text = "";

    setState(() {
      kodeBarang = "";
      nama = "";
      stock = "";
      hargaBeli = "";
      hargaBeli = "";
      keterangan = "";
      imgUrl = null;
      category = null;
      satuan = null;
    });
  }

  void saveBarang() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (int.parse(stock) > 100000) {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text('Stok barang maksimal 100.000'),
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

      print(
          'category --> ${category.nama}, satuan --> ${satuan.nama}, supplier --> ${supplier.nama}');
      setState(() {
        loading = true;
      });

      try {
        http.MultipartRequest request = http.MultipartRequest(
            'POST', Uri.parse('$apiUrlKasir/master/barang/save'));
        request.headers['authorization'] = bloc.token.valueWrapper?.value;

        request.fields['sku'] = kodeBarang;
        request.fields['nama_barang'] = nama;
        request.fields['stock'] = stock;
        request.fields['harga_beli'] = hargaBeli;
        request.fields['harga_jual'] = hargaJual;
        request.fields['keterangan'] = keterangan;
        request.fields['id_kategori'] = category.id;
        request.fields['id_satuan'] = satuan.id;
        request.fields['id_supplier'] = supplier != null ? supplier.id : null;
        if (imgUrl != null) {
          request.files
              .add(await http.MultipartFile.fromPath('imgUrl', imgUrl.path));
        }

        http.StreamedResponse response = await request.send();
        Map<String, dynamic> responseData =
            json.decode(await response.stream.bytesToString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Tambah Barang'),
        centerTitle: true,
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
              onPressed: () => saveBarang(),
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
        padding: EdgeInsets.all(15),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                viewImg(),
                SizedBox(height: 20.0),
                TextFormField(
                    controller: _namaBarangController,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'nama barang tidak boleh kosong';
                      }
                    },
                    onSaved: (String value) {
                      setState(() {
                        nama = value;
                      });
                    }),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                          controller: _stockController,
                          decoration: InputDecoration(
                            labelText: 'Stok',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'stok barang tidak boleh kosong';
                            }
                          },
                          onChanged: (value) {
                            // if (value.isEmpty) {
                            //   setState(() {
                            //     _textStokError = false;
                            //   });
                            // }
                          },
                          onSaved: (String value) {
                            setState(() {
                              stock = value;
                            });
                          }),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                          controller: _kodeBarangController,
                          decoration: InputDecoration(
                            labelText: 'Kode Barang',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'kode barang tidak boleh kosong';
                            }
                          },
                          onChanged: (value) {
                            // if (value.isEmpty) {
                            //   setState(() {
                            //     _textKodeBarangError = false;
                            //   });
                            // }
                          },
                          onSaved: (String value) {
                            setState(() {
                              kodeBarang = value;
                            });
                          }),
                    ),
                    SizedBox(width: 5.0),
                    InkWell(
                      onTap: () async {
                        print('scan qr code');
                        var barcode = await BarcodeScanner.scan();
                        print('kode ${barcode.rawContent}');
                        if (barcode.rawContent.isNotEmpty) {
                          setState(() {
                            _kodeBarangController.text = barcode.rawContent;
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          controller: _hargaBeliController,
                          decoration: InputDecoration(
                            labelText: 'Harga Beli',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'harga beli tidak boleh kosong';
                            }
                          },
                          onChanged: (value) {
                            // if (value.isEmpty) {
                            //   setState(() {
                            //     _textHargaBeliError = false;
                            //   });
                            // }
                          },
                          onSaved: (String value) {
                            setState(() {
                              hargaBeli = value;
                            });
                          }),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                          controller: _hargaJualController,
                          decoration: InputDecoration(
                            labelText: 'Harga Jual',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'harga jual tidak boleh kosong';
                            }
                          },
                          onChanged: (value) {
                            // if (value.isEmpty) {
                            //   setState(() {
                            //     _textHargaJualError = false;
                            //   });
                            // }
                          },
                          onSaved: (String value) {
                            setState(() {
                              hargaJual = value;
                            });
                          }),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _satuanController,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Satuan',
                  ),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'satuan tidak boleh kosong';
                    }
                    return null; // Return null to handle error manually.
                  },
                  onTap: () async {
                    print('klik satuan');
                    SatuanModel response = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SelectSatuan()),
                    );

                    if (response == null) return;
                    _satuanController.text = response.nama;
                    setState(() {
                      satuan = response;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _kategoriController,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                  ),
                  validator: (String value) {
                    if (value == "") {
                      return "kategori tidak boleh kosong";
                    }
                  },
                  onTap: () async {
                    print('klik kategori');
                    CategoryModel response = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SelectCategory()),
                    );

                    if (response == null) return;
                    _kategoriController.text = response.nama;
                    setState(() {
                      category = response;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _supplierController,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Supplier',
                  ),
                  validator: (String value) {
                    if (value == "") {
                      return "supplier tidak boleh kosong";
                    }
                  },
                  onTap: () async {
                    print('klik supplier');
                    SupplierModel response = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SelectSupplier()),
                    );

                    if (response == null) return;
                    _supplierController.text = response.nama;
                    setState(() {
                      supplier = response;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                    controller: _keteranganController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    onSaved: (String value) {
                      setState(() {
                        keterangan = value;
                      });
                    }),
                SizedBox(height: 50.0),
              ],
            )));
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
            child: imgUrl == null
                ? Center(
                    child: Text(
                      'FOTO ITEM',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  )
                : Image.file(imgUrl, fit: BoxFit.contain),
          ),
        ));
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
