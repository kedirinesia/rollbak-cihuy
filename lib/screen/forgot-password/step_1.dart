// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/forgot-password/step_2.dart';

class StepOneForgotPIN extends StatefulWidget {
  @override
  _StepOneForgotPINState createState() => _StepOneForgotPINState();
}

class _StepOneForgotPINState extends State<StepOneForgotPIN> {
  TextEditingController nomor = TextEditingController();
  bool loading = false;

  void login() async {
    if (nomor.text.length < 10 || !nomor.text.startsWith('08')) {
      showToast(context, 'Nomor yang anda masukkan tidak valid');
      return;
    }

    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/forgot/otp'),
      headers: {'Content-Type': 'application/json', 'merchantCode': sigVendor},
      body: json.encode(
        configAppBloc.brandId.valueWrapper?.value == null
            ? {
                'phone': nomor.text,
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
              }
            : {
                'phone': nomor.text,
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
                'wl_id': configAppBloc.brandId.valueWrapper?.value,
              },
      ),
    );

    if (response.statusCode == 200) {
      String id = json.decode(response.body)['data']['validate_id'];
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StepTwoForgotPIN(nomor.text, id)));
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kendala pada server';
      showToast(context, message);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Lupa PIN',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: loading
            ? Center(
                child: SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor, size: 35))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      'Kami akan mengirim kode verifikasi untuk memastikan bahwa nomor yang anda gunakan untuk login adalah milik anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 25),
                  packageName == 'com.eralink.mobileapk'
                      ? TextFormField(
                          controller: nomor,
                          keyboardType: TextInputType.number,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              labelText: 'Nomor HP',
                              labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                              isDense: true))
                      : TextFormField(
                          controller: nomor,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nomor HP',
                              isDense: true)),
                  SizedBox(height: 10),
                  ButtonTheme(
                    minWidth: double.infinity,
                    buttonColor: Theme.of(context).primaryColor,
                    textTheme: ButtonTextTheme.primary,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).primaryColor)),
                      child: Text('Kirim Kode'),
                      onPressed: () => login(),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
