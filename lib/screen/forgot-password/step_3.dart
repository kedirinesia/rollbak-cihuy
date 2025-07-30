// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';

class StepThreeForgotPIN extends StatefulWidget {
  final String token;
  StepThreeForgotPIN(this.token);

  @override
  _StepThreeForgotPINState createState() => _StepThreeForgotPINState();
}

class _StepThreeForgotPINState extends State<StepThreeForgotPIN> {
  TextEditingController pin = TextEditingController();
  TextEditingController confirmPin = TextEditingController();
  bool loading = false;

  void submit() async {
    if (pin.text.isEmpty || confirmPin.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ada field yang masih kosong')));
      return;
    } else if (pin.text != confirmPin.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PIN tidak cocok')));
      return;
    }

    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/forgot/reset'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': widget.token
      },
      body: json.encode(
        {
          'pin': pin.text,
        },
      ),
    );

    if (response.statusCode == 200) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Berhasil'),
          content: Text(
              'PIN berhasil di ubah, silahkan masuk menggunakan PIN anda yang baru'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: Navigator.of(ctx).pop,
            ),
          ],
        ),
      );
      Navigator.of(context).pop();
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kendala pada server';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Reset PIN',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              packageName == 'com.eralink.mobileapk'
                  ? TextFormField(
                      controller: pin,
                      keyboardType: TextInputType.number,
                      cursorColor: Theme.of(context).primaryColor,
                      maxLength: configAppBloc.pinCount.valueWrapper?.value,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          labelText: 'PIN Baru',
                          labelStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor)))
                  : TextFormField(
                      controller: pin,
                      keyboardType: TextInputType.number,
                      maxLength: configAppBloc.pinCount.valueWrapper?.value,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'PIN Baru')),
              SizedBox(height: 10),
              packageName == 'com.eralink.mobileapk'
                  ? TextFormField(
                      controller: confirmPin,
                      keyboardType: TextInputType.number,
                      cursorColor: Theme.of(context).primaryColor,
                      maxLength: configAppBloc.pinCount.valueWrapper?.value,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          labelText: 'Ulangi PIN Baru',
                          labelStyle: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          )))
                  : TextFormField(
                      controller: confirmPin,
                      keyboardType: TextInputType.number,
                      maxLength: configAppBloc.pinCount.valueWrapper?.value,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Ulangi PIN Baru')),
              SizedBox(height: 10),
              ButtonTheme(
                minWidth: double.infinity,
                buttonColor: Theme.of(context).primaryColor,
                textTheme: ButtonTextTheme.primary,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).primaryColor)),
                  child: Text('Ubah PIN'),
                  onPressed: () => submit(),
                ),
              )
            ]),
      ),
    );
  }
}
