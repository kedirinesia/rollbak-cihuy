// import 'dart:convert';
// import 'package:http/http.dart' as http;
// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';

Future<void> confirmPin(
    BuildContext context, String kodeProduk, String tujuan, int counter) async {
  TextEditingController pin = TextEditingController();

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan PIN'),
          content: TextFormField(
            controller: pin,
            keyboardType: TextInputType.number,
            maxLength: configAppBloc.pinCount.valueWrapper?.value,
            obscureText: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
