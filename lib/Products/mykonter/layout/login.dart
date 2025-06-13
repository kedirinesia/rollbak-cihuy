// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/screen/forgot-password/step_1.dart';
import 'package:mobile/screen/otp.dart';
import 'package:mobile/screen/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _hidePin = true;
  TextEditingController _phone = TextEditingController();
  TextEditingController _pin = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/login'),
      headers: {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor,
      },
      body: json.encode({
        'phone': _phone.text.trim(),
        'pin': _pin.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      String validateId = json.decode(response.body)['data']['validate_id'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpPage(_phone.text.trim(), validateId),
        ),
      );
    } else {
      String message;
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {
        message = 'Terjadi kesalahan saat mengambil data dari server';
      }

      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(.8),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    configAppBloc.iconApp.valueWrapper?.value['logo'] != null
                        ? CachedNetworkImage(
                            imageUrl: configAppBloc
                                .iconApp.valueWrapper?.value['logo'],
                            width: MediaQuery.of(context).size.width * .25,
                          )
                        : Text(
                            appName,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    SizedBox(height: MediaQuery.of(context).size.height * .1),
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SizedBox(height: 5),
                          // Text(
                          //   'Untuk dapat menggunakan layanan dari kami, silahkan masuk menggunakan akun $appName anda untuk melanjutkan proses masuk',
                          //   textAlign: TextAlign.justify,
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          SizedBox(height: 40),
                          TextField(
                            autofocus: true,
                            controller: _phone,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.phone_rounded,
                                color: Colors.white.withOpacity(.5),
                              ),
                              hintText: 'Nomor Telepon',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            autofocus: true,
                            controller: _pin,
                            obscureText: _hidePin,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_rounded,
                                color: Colors.white.withOpacity(.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hidePin
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white.withOpacity(.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _hidePin = !_hidePin;
                                  });
                                },
                              ),
                              hintText: 'Kode PIN',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          MaterialButton(
                            minWidth: double.infinity,
                            color: Colors.white,
                            elevation: 0,
                            shape: StadiumBorder(),
                            child: _loading
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black),
                                    ),
                                  )
                                : Text('Masuk'),
                            onPressed: login,
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lupa PIN?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StepOneForgotPIN(),
                                  ),
                                ),
                                child: Text(
                                  'Atur ulang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum mempunyai akun?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        configAppBloc.layoutApp.valueWrapper
                                            .value['register'] ??
                                        RegisterUser(),
                                  ),
                                ),
                                child: Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
