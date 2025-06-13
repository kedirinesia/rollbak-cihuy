// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/paymobileku/layout/downline/tambah_downline_controller.dart';
import 'package:mobile/screen/select_state/kecamatan.dart';
import 'package:mobile/screen/select_state/kota.dart';
import 'package:mobile/screen/select_state/provinsi.dart';

class TambahDownline extends StatefulWidget {
  @override
  _TambahDownlineState createState() => _TambahDownlineState();
}

class _TambahDownlineState extends TambahDownlineController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/tambah/downline', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tambah Downline',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text('Tambah Downline'), centerTitle: true),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                loading
                    ? loadingWidget()
                    : Container(
                        padding: EdgeInsets.all(15),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: nama,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nama Downline',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Nama tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: nomor,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nomor HP Downline',
                                  prefixIcon: Icon(Icons.phone),
                                  hintText: packageName == "com.emobile.app"
                                      ? "Nomor harus terdaftar di WhatsApp"
                                      : null,
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Nomor HP tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: namaToko,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nama Toko',
                                  prefixIcon: Icon(Icons.store),
                                ),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: alamatToko,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Alamat Toko',
                                    prefixIcon: Icon(Icons.location_on)),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: provinsiText,
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Provinsi',
                                    prefixIcon: Icon(Icons.map)),
                                onTap: () async {
                                  Lokasi lokasi = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) =>
                                              SelectProvinsiPage()));
                                  if (lokasi == null) return;
                                  provinsi = lokasi;
                                  provinsiText.text = lokasi.nama;
                                  setState(() {});
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Provinsi tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: kotaText,
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Kota',
                                    prefixIcon: Icon(Icons.map)),
                                onTap: () async {
                                  if (provinsi == null) return;
                                  Lokasi lokasi = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) =>
                                              SelectKotaPage(provinsi)));
                                  if (lokasi == null) return;
                                  kota = lokasi;
                                  kotaText.text = lokasi.nama;
                                  setState(() {});
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Kota tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: kecamatanText,
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Kecamatan',
                                    prefixIcon: Icon(Icons.map)),
                                onTap: () async {
                                  if (kota == null) return;
                                  Lokasi lokasi = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) =>
                                              SelectKecamatanPage(kota)));
                                  if (lokasi == null) return;
                                  kecamatan = lokasi;
                                  kecamatanText.text = lokasi.nama;
                                  setState(() {});
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Kecamatan tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: alamat,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Alamat',
                                  prefixIcon: Icon(Icons.home),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Alamat tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: pin,
                                keyboardType: TextInputType.number,
                                maxLength:
                                    configAppBloc.pinCount.valueWrapper?.value,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'PIN Downline',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'PIN tidak boleh kosong';
                                  else
                                    return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: markup,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Markup',
                                    prefixIcon: Icon(Icons.monetization_on),
                                    prefixText: 'Rp '),
                              ),
                              SizedBox(height: 15)
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Kirim'),
              onPressed: () => registerDownline(),
            ),
    );
  }
}
