// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin.dart';

abstract class GantiPinController extends State<GantiPin>
    with TickerProviderStateMixin {
    bool loading = false;
  TextEditingController pinLama = TextEditingController();
  TextEditingController pinBaru = TextEditingController();
  TextEditingController pinConfirm = TextEditingController();

  void ganti() async {
    if (pinLama.text.isEmpty || pinBaru.text.isEmpty || pinConfirm.text.isEmpty)
      return;

    if (pinBaru.text != pinConfirm.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PIN baru tidak cocok')));
      return;
    }

    setState(() {
      loading = true;
    });

    http.Response response =
        await http.post(Uri.parse('$apiUrl/user/pin/update'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'pinLama': int.parse(pinLama.text),
              'pinBaru': int.parse(pinBaru.text),
              'pinConfirm': int.parse(pinConfirm.text)
            }));

    if (response.statusCode == 200) {
      pinLama.text = "";
      pinBaru.text = "";
      pinConfirm.text = "";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("PIN berhasil diubah")));
    } else {
      String message = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      loading = false;
    });
  }
}
