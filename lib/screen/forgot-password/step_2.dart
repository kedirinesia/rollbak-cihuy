// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/forgot-password/step_3.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:http/http.dart' as http;

class StepTwoForgotPIN extends StatefulWidget {
  final String phone;
  final String id;
  StepTwoForgotPIN(this.phone, this.id);

  @override
  _StepTwoForgotPINState createState() => _StepTwoForgotPINState();
}

class _StepTwoForgotPINState extends State<StepTwoForgotPIN> {
  TextEditingController otp = TextEditingController();
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
        'otp': otp.text,
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
      otp.clear();
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
            title: Text('Verifikasi OTP',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor)),
        body: loading
            ? loadingWidget()
            : Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset('assets/img/sent.svg',
                          width: MediaQuery.of(context).size.width * .35),
                      SizedBox(height: 25),
                      Text(
                        'Kami telah mengirimkan anda pesan ${packageName == "com.talentapay.android" ? "SMS" : "Whatsapp"} berupa kode OTP, silahkan masukkan ${configAppBloc.otpCount.valueWrapper?.value} digit kode OTP untuk melanjutkan proses reset PIN',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      PinInputTextField(
                        controller: otp,
                        pinLength: configAppBloc.otpCount.valueWrapper?.value,
                        autoFocus: true,
                        decoration: UnderlineDecoration(
                            colorBuilder: PinListenColorBuilder(
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor)),
                        onChanged: (value) {
                          if (value.length ==
                              configAppBloc.otpCount.valueWrapper?.value) {
                            verify();
                          }
                        },
                      )
                    ]),
              ));
  }
}
