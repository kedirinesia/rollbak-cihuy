// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/Products/centralbayar/layout/downline/tambah_downline.dart';

abstract class TambahDownlineController extends State<TambahDownline>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  TextEditingController alamat = TextEditingController();
  TextEditingController nama = TextEditingController();
  TextEditingController nomor = TextEditingController();
  TextEditingController pin = TextEditingController();
  TextEditingController markup = TextEditingController();
  TextEditingController namaToko = TextEditingController();
  TextEditingController alamatToko = TextEditingController();
  TextEditingController provinsiText = TextEditingController();
  TextEditingController kotaText = TextEditingController();
  TextEditingController kecamatanText = TextEditingController();
  Lokasi provinsi;
  Lokasi kota;
  Lokasi kecamatan;
  bool loading = false;

  Widget loadingWidget() {
    return Center(
      child:
          SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
    );
  }

  void registerDownline() async {
    if (!formKey.currentState.validate()) return;

    if (pin.text.startsWith('0')) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Gagal'),
          content: const Text('Nomor PIN Tidak Boleh Diawali Dengan Angka 0'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'TUTUP'),
              child: const Text('TUTUP'),
            ),
          ],
        ),
      );

      return;
    }

    if (packageName == 'com.mocipay.app' && int.parse(markup.text) > 50) {
      return showToast(context, 'Markup tidak boleh lebih dari Rp 50');
    }

    if (int.parse(markup.text) <= 0) {
      return showToast(context, 'Markup harus lebih dari 0');
    }

    setState(() {
      loading = true;
    });

    try {
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor
      };
      Map<String, dynamic> body = {
        'name': nama.text,
        'phone': nomor.text,
        'pin': int.parse(pin.text),
        'id_propinsi': provinsi.id,
        'id_kabupaten': kota.id,
        'id_kecamatan': kecamatan.id,
        'alamat': alamat.text,
        'kode_upline': bloc.userId.valueWrapper?.value,
        'markup': int.parse(markup.text),
        'nama_toko': namaToko.text,
        'alamat_toko': alamatToko.text
      };
      http.Response response = await http.post(
          Uri.parse('$apiUrl/user/register'),
          headers: header,
          body: json.encode(body));

      dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Berhasil'),
                  content: Text('Registrasi downline berhasil'),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
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
                  content: Text(data['message']),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
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
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
    setState(() {
      loading = false;
    });
  }
}
