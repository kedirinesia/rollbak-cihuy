// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';

class StepThreeForgotPIN extends StatefulWidget {
  final String token;
  StepThreeForgotPIN(this.token);

  @override
  _StepThreeForgotPINState createState() => _StepThreeForgotPINState();
}

class _StepThreeForgotPINState extends State<StepThreeForgotPIN> {
  final GlobalKey<FormState> _form = GlobalKey();
  TextEditingController pin = TextEditingController();
  TextEditingController confirmPin = TextEditingController();
  bool loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _form.currentState?.dispose();
    super.dispose();
  }

  void submit() async {
    int pinCount = configAppBloc.pinCount.valueWrapper?.value;
    if (!_form.currentState.validate()) return;

    if (pin.text.isEmpty || confirmPin.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ada field yang masih kosong')));
      return;
    } else if (pin.text != confirmPin.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PIN tidak cocok')));
      return;
    } else if (pin.text.length != pinCount ||
        confirmPin.text.length != pinCount) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN harus $pinCount karakter')));
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
            title: Text('Reset PIN', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black)),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 48),
                      padding: EdgeInsets.all(16),
                      child: Image.asset('assets/img/payku/newPin.png'),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 19, right: 19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat PIN Baru',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColor),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Buat PIN baru anda, sehingga anda dapat masuk ke akun anda. Pastikan anda mengingatnya.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff030303),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              height: 50,
                              child: TextFormField(
                                controller: pin,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(configAppBloc
                                      .pinCount.valueWrapper?.value),
                                ],
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                    isDense: true,
                                    labelText: 'PIN Baru',
                                    labelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: Color(0XFFDADADA))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 50,
                              child: TextFormField(
                                controller: confirmPin,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(configAppBloc
                                      .pinCount.valueWrapper?.value),
                                ],
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                    isDense: true,
                                    labelText: 'Konfirmasi PIN Baru',
                                    labelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: Color(0XFFDADADA))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 50,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(31)),
                        color: Theme.of(context).primaryColor,
                        onPressed: () => submit(),
                        child: Text(
                          'Ubah PIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
