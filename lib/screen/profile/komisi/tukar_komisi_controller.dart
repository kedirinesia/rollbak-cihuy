// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/user.dart';
import 'package:mobile/screen/profile/komisi/tukar_komisi.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'dart:convert';

abstract class TukarKomisiController extends State<TukarKomisi>
    with TickerProviderStateMixin {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  @override
  void initState() {
    nominal.text = widget.nominal.toString();
    super.initState();
  }

  void tukar() async {
    setState(() {
      loading = true;
    });
    try {
      http.Response response =
          await http.post(Uri.parse('$apiUrl/komisi/tukar'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': bloc.token.valueWrapper?.value
              },
              body: json.encode({'jumlah': int.parse(nominal.text)}));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        await UserProvider().getProfile();
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Berhasil'),
                  content: Text(
                      'Berhasil menukar komisi. Saldo kamu menjadi ${formatRupiah(data['saldo_akhir'])}'),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                ));
        Navigator.of(context).pop();
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text(data['message']),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                ));
        Navigator.of(context).pop();
      }
    } catch (err) {
      print(err.toString());
    }
    setState(() {
      loading = false;
    });
  }

  Widget loadingWidget() {
    return Flexible(
      flex: 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor, size: 35)),
      ),
    );
  }
}
