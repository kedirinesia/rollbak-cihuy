// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/Products/mykonterr/layout/forgot-password/step_3.dart';
import 'package:http/http.dart' as http;

class StepTwoForgotPIN extends StatefulWidget {
  final String phone;
  final String id;
  StepTwoForgotPIN(this.phone, this.id);

  @override
  _StepTwoForgotPINState createState() => _StepTwoForgotPINState();
}

class _StepTwoForgotPINState extends State<StepTwoForgotPIN> {
  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();
  bool loading = false;

  void verify() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/login/validate'),
      headers: {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor,
      },
      body: json.encode({
        'phone': widget.phone,
        'otp': otp1.text + otp2.text + otp3.text + otp4.text,
        'validate_id': widget.id,
      }),
    );

    if (response.statusCode == 200) {
      String token = json.decode(response.body)['data'];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StepThreeForgotPIN(token),
        ),
      );
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kendala pada server';
      showToast(context, message);
      otp1.clear();
      otp2.clear();
      otp3.clear();
      otp4.clear();
    }

    setState(() {
      loading = false;
    });
  }

  Widget loadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SpinKitThreeBounce(
          color: Theme.of(context).primaryColor,
          size: 35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text('Verifikasi OTP', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black)),
        body: loading
            ? loadingWidget()
            : Stack(
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
                            child: Image.asset('assets/img/payku/otp.png'),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 19, right: 19),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Masukkan OTP',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Kami telah mengirimkan anda pesan Whatsapp berupa kode OTP, silahkan masukkan ${configAppBloc.otpCount.valueWrapper?.value} digit kode OTP untuk melanjutkan proses reset PIN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff030303),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          Form(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 61,
                                  width: 60,
                                  child: TextFormField(
                                    controller: otp1,
                                    onChanged: (value) {
                                      if (value.length == 1) {
                                        FocusScope.of(context).nextFocus();
                                      }
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    decoration: InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 61,
                                  width: 60,
                                  child: TextFormField(
                                    controller: otp2,
                                    onChanged: (value) {
                                      if (value.length == 1) {
                                        FocusScope.of(context).nextFocus();
                                      }
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    decoration: InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 61,
                                  width: 60,
                                  child: TextFormField(
                                    controller: otp3,
                                    onChanged: (value) {
                                      if (value.length == 1) {
                                        FocusScope.of(context).nextFocus();
                                      }
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    decoration: InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 61,
                                  width: 60,
                                  child: TextFormField(
                                    controller: otp4,
                                    onChanged: (value) {
                                      verify();
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    decoration: InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ));
  }
}
