// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kecamatan.dart';
import 'package:mobile/models/mp_kota.dart';
import 'package:mobile/models/mp_provinsi.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/alamat/select_kecamatan.dart';
import 'package:mobile/screen/marketplace/alamat/select_kota.dart';
import 'package:mobile/screen/marketplace/alamat/select_provinsi.dart';

class TambahAlamatPage extends StatefulWidget {
  @override
  _TambahAlamatPageState createState() => _TambahAlamatPageState();
}

class _TambahAlamatPageState extends State<TambahAlamatPage> {
  bool isLoading = false;
  TextEditingController nama = TextEditingController();
  TextEditingController telepon = TextEditingController();
  TextEditingController alamat1 = TextEditingController();
  TextEditingController alamat2 = TextEditingController();
  TextEditingController kodePos = TextEditingController();
  TextEditingController provinsi = TextEditingController();
  TextEditingController kota = TextEditingController();
  TextEditingController kecamatan = TextEditingController();
  MarketplaceProvinsi _provinsi;
  MarketplaceKota _kota;
  MarketplaceKecamatan _kecamatan;

  Future<void> insertAddress() async {
    if (nama.text.isEmpty ||
        telepon.text.isEmpty ||
        alamat1.text.isEmpty ||
        kodePos.text.isEmpty ||
        _provinsi == null ||
        _kota == null ||
        _kecamatan == null) {
      showToast(context, "Ada field yang masih kosong");

      return;
    }

    setState(() {
      isLoading = true;
    });

    http.Response response =
        await http.post(Uri.parse('$apiUrl/market/shipping'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': bloc.token.valueWrapper?.value
            },
            body: json.encode({
              "name": nama.text,
              "nomor_hp": telepon.text,
              "address1": alamat1.text,
              "address2": alamat2.text,
              "state": _provinsi.id,
              "city": _kota.id,
              "subdistrict": _kecamatan.id,
              "zipcode": kodePos.text
            }));

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      showToast(
          context,
          json.decode(response.body)['message'] ??
              'Terjadi kesalahan saat terhubung dengan server');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    nama.dispose();
    telepon.dispose();
    alamat1.dispose();
    alamat2.dispose();
    kodePos.dispose();
    provinsi.dispose();
    kota.dispose();
    kecamatan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Alamat Baru')),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: isLoading
              ? Center(
                  child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor, size: 35))
              : ListView(padding: EdgeInsets.all(15), children: [
                  TextFormField(
                    controller: nama,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Nama Penerima'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: telepon,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Nomor Telepon'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: alamat1,
                    keyboardType: TextInputType.text,
                    minLines: 3,
                    maxLines: 3,
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Alamat 1'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: alamat2,
                    keyboardType: TextInputType.text,
                    minLines: 3,
                    maxLines: 3,
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Alamat 2'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: kodePos,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Kode POS'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: provinsi,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    onTap: () async {
                      MarketplaceProvinsi item = await Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (_) => SelectProvinsiPage()));

                      if (item == null) return;

                      provinsi.text = item.name;
                      _provinsi = item;
                      kota.clear();
                      _kota = null;
                      kecamatan.clear();
                      _kecamatan = null;

                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Provinsi'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: kota,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    onTap: () async {
                      if (_provinsi == null) return;
                      MarketplaceKota item = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => SelectKotaPage(_provinsi.code)));

                      if (item == null) return;

                      kota.text = '${item.type} ${item.name}';
                      _kota = item;
                      kecamatan.clear();
                      _kecamatan = null;

                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Kota'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: kecamatan,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    onTap: () async {
                      if (_kota == null) return;
                      MarketplaceKecamatan item = await Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (_) => SelectKecamatanPage(_kota.code)));

                      if (item == null) return;

                      kecamatan.text = item.name;
                      _kecamatan = item;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Kecamatan'),
                  ),
                ])),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: insertAddress),
    );
  }
}
