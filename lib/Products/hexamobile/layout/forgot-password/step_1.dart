// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/Products/hexamobile/layout/forgot-password/step_2.dart';

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
        title: Text('Lupa PIN', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
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
                    child: Image.asset('assets/img/payku/reset.png'),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 19, right: 19), // memberi jarak di sisi kiri
                    child: Column(
                      // gunakan Column untuk menampung teks-teks
                      crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
                      children: [
                        Text(
                          'Reset PIN',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Kami akan mengirim kode verifikasi untuk memastikan bahwa nomor yang anda gunakan untuk login adalah milik anda sendiri.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff030303),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                  controller: nomor,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'No. Handphone',
                                      border: UnderlineInputBorder())),
                            ],
                          ),
                        ),
                      ],
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
                        onPressed: loading ? null : () => login(),
                        child: loading
                            ? SpinKitThreeBounce(
                                color: Theme.of(context).primaryColor,
                                size: 20.0,
                              )
                            : const Text(
                                'Kirim Kode OTP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
